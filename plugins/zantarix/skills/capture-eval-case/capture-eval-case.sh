#!/usr/bin/env bash
# Capture the current Claude Code session as a raw, suite-agnostic eval-case bundle.
#
# Cut at the user entry that invoked /zantarix:capture-eval-case. Read-only on every git repo: it
# never commits, stashes or checks anything out, and never writes inside a repo. Everything
# mechanical (copy, cut, diff, hash, archive) happens here so the result does not depend on the
# model. The bundle format is documented in FORMAT.md next to this script.
set -euo pipefail

# Bundles hold transcripts and settings: keep them private to the user.
umask 077
# `git diff` would otherwise opportunistically refresh the index; the repos must not change.
export GIT_OPTIONAL_LOCKS=0

usage() {
  echo "Usage: $0 [--out <bundle-dir>] [--note-file <file>]" >&2
  echo "  --out        bundle directory (default: \$CLAUDE_CONFIG_DIR/eval-captures/<timestamp>-<session>/)" >&2
  echo "  --note-file  file whose contents are stored verbatim as note.md" >&2
  echo "Reads the session from \$CLAUDE_CODE_SESSION_ID; needs git and jq." >&2
  exit 1
}

die() { echo "error: $*" >&2; exit 1; }

OUT=""
NOTE_FILE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --out) [ $# -ge 2 ] || usage; OUT="$2"; shift 2 ;;
    --note-file) [ $# -ge 2 ] || usage; NOTE_FILE="$2"; shift 2 ;;
    *) usage ;;
  esac
done

command -v git >/dev/null || die "git is required"
command -v jq >/dev/null || die "jq is required"

SID="${CLAUDE_CODE_SESSION_ID:-}"
[ -n "$SID" ] || die "CLAUDE_CODE_SESSION_ID is not set"
CONFIG="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

# --- 1. Locate the session -----------------------------------------------------------------------
TRANSCRIPT=""
for f in "$CONFIG"/projects/*/"$SID".jsonl; do
  [ -f "$f" ] && TRANSCRIPT="$f" && break
done
[ -n "$TRANSCRIPT" ] || die "no transcript found at $CONFIG/projects/*/$SID.jsonl"
PROJECT_DIR=$(dirname "$TRANSCRIPT")
SIDECAR="$PROJECT_DIR/$SID"

if [ -z "$OUT" ]; then
  OUT="$CONFIG/eval-captures/$(date -u +%Y%m%dT%H%M%SZ)-${SID:0:8}"
fi
OUT="${OUT%/}"
case "$OUT" in /*) ;; *) OUT="$PWD/$OUT" ;; esac
[ ! -e "$OUT" ] || die "output directory already exists: $OUT"
[ ! -e "$OUT.tar.xz" ] || die "archive already exists: $OUT.tar.xz"

# Refuse any output (and so its archive) that would land inside a git work tree.
ancestor=$(dirname "$OUT")
while [ ! -d "$ancestor" ]; do ancestor=$(dirname "$ancestor"); done
if [ "$(git -C "$ancestor" rev-parse --is-inside-work-tree 2>/dev/null || true)" = "true" ]; then
  die "refusing to write the bundle inside a git work tree: $OUT"
fi

mkdir -p "$OUT/.work" "$OUT/transcript" "$OUT/repos" "$OUT/instructions"
# A failed capture leaves nothing behind; the trap is disarmed once the archive is written.
trap 'rm -rf "$OUT" "$OUT.tar.xz"' EXIT
WORK="$OUT/.work"
WARNINGS="$WORK/warnings"
INCOMPLETE="$WORK/incomplete"
: > "$WARNINGS"
: > "$INCOMPLETE"
warn() { echo "warning: $*" >&2; echo "$*" >> "$WARNINGS"; }

# --- 2. Copy first, then cut the copies ----------------------------------------------------------
# The live JSONL keeps growing, so snapshot it and work only on the snapshot.
cp -p "$TRANSCRIPT" "$WORK/main.jsonl"
# Drop a trailing partial line, if the session was mid-write when copied.
if [ -s "$WORK/main.jsonl" ] && [ -n "$(tail -c1 "$WORK/main.jsonl")" ]; then
  sed -i '$d' "$WORK/main.jsonl"
fi
if [ -d "$SIDECAR" ]; then
  cp -a "$SIDECAR" "$WORK/sidecar"
else
  mkdir -p "$WORK/sidecar"
fi

CUT_RE='<command-name>/(zantarix:)?capture-eval-case</command-name>'
CUT=$(jq -r --arg re "$CUT_RE" \
  'select(.type == "user" and ((.message.content | tostring) | test($re)))
   | [input_line_number, .uuid, .timestamp] | @tsv' "$WORK/main.jsonl" | tail -n 1)
[ -n "$CUT" ] || die "no user entry invoking /zantarix:capture-eval-case found in the transcript"
IFS=$'\t' read -r CUT_LINE CUT_UUID CUT_TS <<<"$CUT"
# Fields every transcript entry should carry: a bundle cut on a guess would be a bad bundle.
require() { [ -n "$2" ] && [ "$2" != "null" ] || die "expected $1 in the transcript but found none (did the transcript format change?)"; }
require "a uuid on the cut entry" "${CUT_UUID:-}"
require "a timestamp on the cut entry" "${CUT_TS:-}"

head -n $((CUT_LINE - 1)) "$WORK/main.jsonl" > "$OUT/transcript/$SID.jsonl"

# Subagents: cut by timestamp. A subagent that is not finished, or still has entries at or after
# the cut, was running at the cut and is recorded as incomplete.
mkdir -p "$OUT/transcript/subagents" "$OUT/transcript/tool-results"
# Subagents live at any depth (workflow agents sit under workflows/<run>/), so keep relative paths.
if [ -d "$WORK/sidecar/subagents" ]; then
  while IFS= read -r -d '' sub; do
    rel="${sub#"$WORK"/sidecar/subagents/}"
    mkdir -p "$(dirname "$OUT/transcript/subagents/$rel")"
    jq -c --arg t "$CUT_TS" 'select(.timestamp < $t)' "$sub" > "$OUT/transcript/subagents/$rel"
    total=$(wc -l < "$sub")
    kept=$(wc -l < "$OUT/transcript/subagents/$rel")
    meta="${sub%.jsonl}.meta.json"
    finished=false
    if [ -f "$meta" ]; then
      finished=$(jq -r '.finished == true' "$meta")
    else
      warn "subagent $(basename "$sub" .jsonl) has no .meta.json; treated as incomplete"
    fi
    if [ "$finished" != "true" ] || [ "$kept" -lt "$total" ]; then
      name=$(basename "$sub" .jsonl)
      jq -cn --arg id "${name#agent-}" --argjson kept "$kept" --argjson dropped "$((total - kept))" \
        '{agent: $id, entries_kept: $kept, entries_dropped: $dropped}' >> "$INCOMPLETE"
    fi
  done < <(find "$WORK/sidecar/subagents" -type f -name 'agent-*.jsonl' -print0)
  # Everything else beside them (meta files, workflow journals): keep what predates the cut.
  (cd "$WORK/sidecar/subagents" \
    && find . -type f ! -name 'agent-*.jsonl' ! -newermt "$CUT_TS" -exec cp -p --parents {} "$OUT/transcript/subagents" \;) \
    || warn "could not copy subagent metadata"
fi
# Tool results: keep only files last modified before the cut.
if [ -d "$WORK/sidecar/tool-results" ]; then
  (cd "$WORK/sidecar/tool-results" \
    && find . -type f ! -newermt "$CUT_TS" -exec cp -p --parents {} "$OUT/transcript/tool-results" \;) \
    || warn "could not copy tool-results"
fi

# --- 3. edits.jsonl ------------------------------------------------------------------------------
EDIT_FILTER='select(.type == "assistant") | .timestamp as $ts
  | .message.content[]? | select(.type == "tool_use" and (.name | IN("Write","Edit","MultiEdit","NotebookEdit","Bash")))
  | {timestamp: $ts, source: $src, tool: .name, tool_use_id: .id,
     path: (.input.file_path // .input.notebook_path // null), input: .input}
    + (if .name == "Bash" then {reversible: false, mutating: "unknown"} else {} end)'
{
  jq -c --arg src main "$EDIT_FILTER" "$OUT/transcript/$SID.jsonl"
  while IFS= read -r -d '' sub; do
    jq -c --arg src "$(basename "$sub" .jsonl)" "$EDIT_FILTER" "$sub"
  done < <(find "$OUT/transcript/subagents" -type f -name 'agent-*.jsonl' -print0)
} | jq -cs 'sort_by(.timestamp) | .[]' > "$OUT/edits.jsonl"

# --- 4. Repositories the session touched ---------------------------------------------------------
ALL_TRANSCRIPTS=("$OUT/transcript/$SID.jsonl")
while IFS= read -r -d '' sub; do ALL_TRANSCRIPTS+=("$sub"); done \
  < <(find "$OUT/transcript/subagents" -type f -name 'agent-*.jsonl' -print0)

CANDIDATES="$WORK/candidate-paths"
{
  jq -r '.cwd? // empty' "${ALL_TRANSCRIPTS[@]}"
  jq -r '.message.content[]? | select(.type == "tool_use") | (.input.file_path? // .input.notebook_path? // empty)' \
    "${ALL_TRANSCRIPTS[@]}"
} | sort -u > "$CANDIDATES"

TOPLEVELS="$WORK/toplevels"
: > "$TOPLEVELS"
while IFS= read -r p; do
  [ -n "$p" ] || continue
  d="$p"
  while [ ! -d "$d" ] && [ "$d" != "/" ]; do d=$(dirname "$d"); done
  top=$(git -C "$d" rev-parse --show-toplevel 2>/dev/null || true)
  [ -z "$top" ] || echo "$top" >> "$TOPLEVELS"
done < "$CANDIDATES"
sort -u -o "$TOPLEVELS" "$TOPLEVELS"

# sed rather than head: head closing early would SIGPIPE jq, which pipefail turns into a failure.
SESSION_START=$(jq -r 'select(.timestamp) | .timestamp' "$OUT/transcript/$SID.jsonl" | sed -n '1p')
require "a timestamp on the first entry" "$SESSION_START"
SESSION_START_EPOCH=$(date -d "$SESSION_START" +%s)

REPOS_JSON="$WORK/repos.json"
echo '[]' > "$REPOS_JSON"
declare -A USED_NAMES=()
while IFS= read -r top; do
  [ -n "$top" ] || continue
  name=$(basename "$top")
  n=1; base="$name"
  while [ -n "${USED_NAMES[$name]:-}" ]; do n=$((n + 1)); name="$base-$n"; done
  USED_NAMES[$name]=1
  dest="$OUT/repos/$name"
  mkdir -p "$dest"

  sha=$(git -C "$top" rev-parse HEAD 2>/dev/null || true)
  if [ -z "$sha" ]; then
    warn "repo $top has no commits; only its diffs and untracked files are captured"
  fi
  branch=$(git -C "$top" symbolic-ref --short -q HEAD || true)
  upstream=$(git -C "$top" rev-parse --abbrev-ref '@{u}' 2>/dev/null || true)
  default_ref=$(git -C "$top" symbolic-ref --short -q refs/remotes/origin/HEAD 2>/dev/null || true)
  on_default=null
  if [ -n "$sha" ] && [ -n "$default_ref" ]; then
    if git -C "$top" merge-base --is-ancestor HEAD "$default_ref" 2>/dev/null; then on_default=true; else on_default=false; fi
  fi
  # Remotes let an importer match this capture to a source repo. http(s) credentials are dropped.
  remotes='[]'
  while IFS= read -r remote; do
    fetch_url=$(git -C "$top" remote get-url "$remote" | sed -E 's#^(https?://)[^/@]*@#\1#')
    push_url=$(git -C "$top" remote get-url --push "$remote" | sed -E 's#^(https?://)[^/@]*@#\1#')
    remotes=$(jq -c --arg n "$remote" --arg f "$fetch_url" --arg p "$push_url" \
      '. + [{name: $n, fetch_url: $f, push_url: $p}]' <<<"$remotes")
  done < <(git -C "$top" remote)
  jq -n --arg path "$top" --arg sha "$sha" --arg branch "$branch" --arg upstream "$upstream" \
        --arg default_ref "$default_ref" --argjson on_default "$on_default" --argjson remotes "$remotes" \
    'def nz: if . == "" then null else . end;
     {path: $path, sha: ($sha | nz), branch: ($branch | nz), upstream: ($upstream | nz),
      default_branch: ($default_ref | nz), on_origin_default: $on_default, remotes: $remotes}' > "$dest/head"

  git -C "$top" diff --cached --binary > "$dest/staged.patch"
  git -C "$top" diff --binary > "$dest/unstaged.patch"

  # grep without -q reads all its input, so git never gets a SIGPIPE under pipefail.
  if git -C "$top" ls-files -o --exclude-standard -z | grep -z . >/dev/null; then
    (cd "$top" && git ls-files -o --exclude-standard -z | tar --null -T - -cf "$dest/untracked.tar")
  fi

  # Reflog since the session started, newest first: epoch, sha, message.
  git -C "$top" reflog --date=unix --format='%gd%x09%H%x09%gs' 2>/dev/null \
    | awk -F'\t' -v start="$SESSION_START_EPOCH" '
        { if (match($1, /@\{[0-9]+\}/)) { e = substr($1, RSTART + 2, RLENGTH - 3); if (e + 0 >= start) print e "\t" $2 "\t" $3 } }' \
    > "$dest/reflog" || true

  # Unpushed work: everything reachable from HEAD or a local branch and not from any remote ref.
  if [ -n "$sha" ] && [ -n "$(git -C "$top" rev-list HEAD --branches --not --remotes -n 1)" ]; then
    git -C "$top" bundle create "$dest/commits.bundle" HEAD --branches --not --remotes >/dev/null 2>&1 \
      || warn "git bundle failed for $top"
  fi

  jq --arg name "$name" --arg path "$top" '. + [{name: $name, path: $path}]' "$REPOS_JSON" > "$REPOS_JSON.new"
  mv "$REPOS_JSON.new" "$REPOS_JSON"
done < "$TOPLEVELS"

# --- 5. instructions/ ----------------------------------------------------------------------------
LINKS="$WORK/links"
: > "$LINKS"
REDACT='walk(if type == "object"
  then with_entries(if (.key | test("token|secret|key|password|auth|credential|cookie"; "i")) then .value = "[REDACTED]" else . end)
  else . end)'

# Mirror each file under instructions/files/<absolute path>, dereferencing symlinks.
capture_file() {
  local src="$1" dest="$OUT/instructions/files/${1#/}"
  [ -f "$src" ] || return 0
  mkdir -p "$(dirname "$dest")"
  if [ -L "$src" ]; then
    jq -cn --arg path "$src" --arg target "$(readlink "$src")" '{path: $path, target: $target}' >> "$LINKS"
  fi
  case "$(basename "$src")" in
    settings*.json)
      jq "$REDACT" "$src" > "$dest" 2>/dev/null || { rm -f "$dest"; warn "skipped unparseable settings file $src"; } ;;
    *) cp -L "$src" "$dest" ;;
  esac
}
capture_tree() {
  local dir="$1" f
  [ -d "$dir" ] || return 0
  while IFS= read -r -d '' f; do capture_file "$f"; done < <(find -L "$dir" -type f -print0)
}
capture_scope() { # <dir holding CLAUDE.md/.claude> — project-style layout
  local d="$1" s
  capture_file "$d/CLAUDE.md"; capture_file "$d/CLAUDE.local.md"; capture_file "$d/.claude/CLAUDE.md"
  capture_tree "$d/.claude/rules"
  for s in "$d"/.claude/settings*.json; do capture_file "$s"; done
}

capture_file "$CONFIG/CLAUDE.md"
capture_tree "$CONFIG/rules"
for s in "$CONFIG"/settings*.json; do capture_file "$s"; done
capture_tree "$PROJECT_DIR/memory"

SCOPE_DIRS="$WORK/scope-dirs"
{
  cat "$TOPLEVELS"
  jq -r '.cwd? // empty' "${ALL_TRANSCRIPTS[@]}" | sort -u | while IFS= read -r c; do
    while [ -n "$c" ] && [ "$c" != "/" ]; do echo "$c"; c=$(dirname "$c"); done
  done
} | sort -u > "$SCOPE_DIRS"
while IFS= read -r d; do [ -d "$d" ] && capture_scope "$d"; done < "$SCOPE_DIRS"

# --- 6. environment.json -------------------------------------------------------------------------
settings_files=("$CONFIG/settings.json")
while IFS= read -r d; do
  settings_files+=("$d/.claude/settings.json" "$d/.claude/settings.local.json")
done < "$SCOPE_DIRS"
existing_settings=()
for f in "${settings_files[@]}"; do [ -f "$f" ] && existing_settings+=("$f"); done
if [ "${#existing_settings[@]}" -gt 0 ]; then
  ENABLED=$(jq -s '[.[] | .enabledPlugins? // {}] | add // {} | with_entries(select(.value == true))' "${existing_settings[@]}" 2>/dev/null || echo '{}')
else
  ENABLED='{}'
fi

INSTALLED="$CONFIG/plugins/installed_plugins.json"
MARKETS="$CONFIG/plugins/known_marketplaces.json"
[ -f "$INSTALLED" ] || { INSTALLED="$WORK/installed.json"; echo '{"plugins":{}}' > "$INSTALLED"; }
[ -f "$MARKETS" ] || { MARKETS="$WORK/markets.json"; echo '{}' > "$MARKETS"; }

PLUGINS=$(jq -n --argjson enabled "$ENABLED" --slurpfile inst "$INSTALLED" --slurpfile mk "$MARKETS" \
  --slurpfile dirs <(jq -R . "$SCOPE_DIRS" | jq -s .) '
  ($inst[0].plugins // {}) as $installed | $mk[0] as $markets | $dirs[0] as $scope
  | [$enabled | keys[] | . as $key
     | ($key | split("@")) as $parts
     | ($installed[$key] // []) as $entries
     | (($entries | map(select(.scope != "user" and (.projectPath as $p | $scope | index($p)))) | first)
        // ($entries | map(select(.scope == "user")) | first) // ($entries | first)) as $e
     | {key: $key, plugin: $parts[0], marketplace: $parts[1],
        marketplace_source: ($markets[$parts[1]].source // null),
        version: ($e.version // null), git_commit_sha: ($e.gitCommitSha // null),
        install_path: ($e.installPath // null), scope: ($e.scope // null)}]')

# A plugin from a local-directory marketplace has no commit to recover it from: copy it whole.
while IFS=$'\t' read -r pname ipath; do
  [ -n "$pname" ] && [ -d "$ipath" ] || continue
  mkdir -p "$OUT/plugins/$pname"
  cp -aL "$ipath/." "$OUT/plugins/$pname/"
done < <(jq -r '.[] | select(.marketplace_source.source == "directory" or .marketplace_source.source == "file")
                | [.key, .install_path] | @tsv' <<<"$PLUGINS")

VERSION=$(jq -r 'select(.version) | .version' "${ALL_TRANSCRIPTS[0]}" | tail -n 1)
MODEL=$(jq -r 'select(.type == "assistant" and .message.model) | .message.model' "${ALL_TRANSCRIPTS[0]}" | tail -n 1)
PERMISSION_MODE=$(jq -r 'select(.type == "permission-mode") | .permissionMode' "${ALL_TRANSCRIPTS[0]}" | tail -n 1)
EFFORT=$(jq -r 'select(.effort) | .effort' "${ALL_TRANSCRIPTS[0]}" | tail -n 1)
# Always present in a live session: refuse to write an environment.json without them.
require "a Claude Code version" "$VERSION"
require "an assistant model" "$MODEL"
# Best effort from here: record what is missing instead of failing.
[ -n "$PERMISSION_MODE" ] || warn "permission mode is not recorded in the transcript"
[ -n "$EFFORT" ] || warn "reasoning effort is not recorded in the transcript"
while IFS= read -r missing; do
  warn "enabled plugin $missing has no entry in installed_plugins.json; version and commit unknown"
done < <(jq -r '.[] | select(.version == null and .git_commit_sha == null) | .key' <<<"$PLUGINS")

jq -n --arg version "$VERSION" --arg model "$MODEL" --arg effort "$EFFORT" --arg pm "$PERMISSION_MODE" \
      --arg platform "$(uname -srm)" --argjson plugins "$PLUGINS" \
  'def nz: if . == "" then null else . end;
   {claude_version: ($version | nz), model: ($model | nz), effort: ($effort | nz),
    permission_mode: ($pm | nz), platform: $platform, plugins: $plugins}' > "$OUT/environment.json"

[ ! -s "$LINKS" ] || jq -s . "$LINKS" > "$OUT/instructions/links.json"

# --- 7. Note -------------------------------------------------------------------------------------
if [ -n "$NOTE_FILE" ] && [ -s "$NOTE_FILE" ]; then
  cp "$NOTE_FILE" "$OUT/note.md"
fi

# --- 8. Manifest, written last -------------------------------------------------------------------
INCOMPLETE_JSON=$(jq -s . "$INCOMPLETE")
WARNINGS_JSON=$(jq -R . "$WARNINGS" | jq -s .)
REPOS=$(cat "$REPOS_JSON")
rm -rf "$WORK"
find "$OUT" -type d -empty -delete 2>/dev/null || true

FILES=$(cd "$OUT" && find . -type f ! -name manifest.json -print0 | sort -z | xargs -0 -r sha256sum \
  | jq -Rn '[inputs | capture("^(?<h>[0-9a-f]{64})  \\./(?<p>.*)$")] | map({(.p): .h}) | add // {}')

jq -n --arg sid "$SID" --arg uuid "$CUT_UUID" --arg ts "$CUT_TS" --arg captured "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      --argjson repos "$REPOS" --argjson incomplete "$INCOMPLETE_JSON" --argjson warnings "$WARNINGS_JSON" \
      --argjson files "$FILES" \
  '{format_version: 1, session_id: $sid, cut: {uuid: $uuid, timestamp: $ts}, captured_at: $captured,
    repos: $repos, incomplete: $incomplete, warnings: $warnings, files: $files}' > "$OUT/manifest.json"

# --- 9. Archive ----------------------------------------------------------------------------------
tar -c --xz -f "$OUT.tar.xz" -C "$(dirname "$OUT")" "$(basename "$OUT")"
trap - EXIT

echo ""
echo "Bundle:  $OUT ($(du -sh "$OUT" | cut -f1))"
echo "Archive: $OUT.tar.xz ($(du -sh "$OUT.tar.xz" | cut -f1), sha256 $(sha256sum "$OUT.tar.xz" | cut -d' ' -f1))"
echo "Cut:     $CUT_TS ($CUT_UUID)"
echo "Repos:   $(jq -r '[.[].path] | join(", ")' <<<"$REPOS")"
echo "Incomplete subagents: $(jq 'length' <<<"$INCOMPLETE_JSON")"
echo "Warnings: $(jq 'length' <<<"$WARNINGS_JSON")"
