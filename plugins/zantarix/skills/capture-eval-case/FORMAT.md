# Eval-case capture bundle, format version 1

Written by `capture-eval-case.sh`. A bundle is a directory, plus a `<dir>.tar.xz` archive of it beside the directory. The bundle is raw: it carries no task, brief, target event, tags, probes or grading. The importing suite decides what to replay and how to judge it.

The bundle is cut at the user entry that invoked `/zantarix:capture-eval-case`. That entry and everything after it is excluded.

## Layout

| Path | Contents |
| ------ | ---------- |
| `manifest.json` | Index of the bundle; written last |
| `transcript/<session-id>.jsonl` | Main transcript, entries before the cut |
| `transcript/subagents/` | `agent-*.jsonl` cut by timestamp, at their sidecar-relative paths (workflow agents sit under `workflows/<run>/`), with the `.meta.json` and workflow journals that predate the cut |
| `transcript/tool-results/` | Tool result files last modified before the cut |
| `repos/<name>/head` | JSON: `path`, `sha`, `branch`, `upstream`, `default_branch`, `on_origin_default` (recorded, not required), `remotes` (`[{name, fetch_url, push_url}]`, empty for a repo with none; `http(s)` userinfo is dropped) |
| `repos/<name>/staged.patch` | `git diff --cached --binary` |
| `repos/<name>/unstaged.patch` | `git diff --binary` |
| `repos/<name>/untracked.tar` | Untracked, non-ignored files; absent when there are none |
| `repos/<name>/reflog` | TSV of `epoch`, `sha`, `message` for HEAD reflog entries since the session started, newest first |
| `repos/<name>/commits.bundle` | `git bundle` of `HEAD` and local branches, excluding everything on a remote; absent when nothing is unpushed |
| `edits.jsonl` | File-modifying tool calls, see below |
| `environment.json` | `claude_version`, `model`, `effort`, `permission_mode`, `platform` and `plugins` |
| `plugins/<name>/` | Whole copy of an enabled plugin from a local-directory marketplace |
| `instructions/files/<absolute path>` | `CLAUDE.md`, `CLAUDE.local.md`, rules, settings and auto-memory files, mirrored by absolute path |
| `instructions/links.json` | `{path, target}` for each symlink that was resolved |
| `note.md` | The user's note, verbatim; absent when skipped |

There is one `repos/<name>/` per git repo the session touched: every working directory and every `file_path` or `notebook_path` in a tool call, mapped to its repo root. A name collision gets a `-2` suffix.

## Recreating a repo's state at the cut

Clone at `head.sha`, fetch `commits.bundle`, then apply `git apply --index staged.patch`, `git apply unstaged.patch` and extract `untracked.tar`. `--index`, not `--cached`: staged changes are in the working tree too.

## `edits.jsonl`

One JSON object per `Write`, `Edit`, `MultiEdit`, `NotebookEdit` or `Bash` tool call before the cut, in timestamp order: `timestamp`, `source` (`main` or `agent-<id>`), `tool`, `tool_use_id`, `path` (or `null`) and `input`.

`Bash` entries carry `reversible: false` and `mutating: "unknown"`: whether a shell command changed files cannot be told reliably, so the importer decides. An importer reads these with the `pending.manifest.json` vocabulary: an **anchor** is a point whose state is recorded, a **gap** is a span between anchors, and an **unreversed** edit is one that cannot be undone from its input, such as any Bash call.

## `manifest.json`

| Field | Meaning |
| ------- | --------- |
| `format_version` | `1` |
| `session_id` | Session the bundle came from |
| `cut` | `{uuid, timestamp}` of the invoking entry |
| `captured_at` | UTC capture time |
| `repos` | `[{name, path}]` |
| `incomplete` | Subagents running at the cut, as `{agent, entries_kept, entries_dropped}`; they keep what they had written |
| `warnings` | Free-text warnings, such as effort not being recorded |
| `files` | Path to sha256 for every file except `manifest.json`. The archive is not listed, because it contains the manifest |

## Required and best-effort fields

The capture fails, leaving nothing behind, when a field that should always exist is missing: the cut entry's `uuid` and `timestamp`, the first entry's timestamp, the Claude Code version, and the assistant model. Everything else is best effort. A missing permission mode, effort, subagent `.meta.json` or installed-plugin record is written as `null` or treated as incomplete, and noted in `warnings`.

## Redaction

`settings*.json` values are replaced with `"[REDACTED]"` where the key name matches `token|secret|key|password|auth|credential|cookie`, case-insensitive. Redaction is by key name only. Transcripts and instruction files are copied as they are, so a bundle can still hold secrets that appeared in the session.

## Not captured

- Anything outside the repos listed above.
- File contents that neither the transcript nor a repo holds, such as files written outside any repo or ignored files.
- Commits made during the session that are reachable from neither `HEAD` nor a local branch; they appear in `reflog` but not in `commits.bundle`.
- Plugins from a remote marketplace: `environment.json` records their version and cache commit instead.
- Reasoning effort, when the transcript does not record it (`effort` is `null`).
