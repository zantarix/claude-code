#!/usr/bin/env bash
# Materialise a review-workflow.js result onto disk.
#
# The Workflow tool cannot touch the filesystem, so review-workflow.js returns its
# { reviewMd, auditFiles, findings, failed } result as plain data. When a Workflow run completes,
# its <task-notification> carries an <output-file> path that already holds this data on disk (as
# { result: { reviewMd, auditFiles, findings, failed }, ... } — the Task tool's envelope) — pass
# that path straight in, no need to re-write it first. This script accepts either that enveloped
# shape or a bare { reviewMd, auditFiles, findings, failed } object, and writes every
# auditFiles[i].content to auditFiles[i].path plus reviewMd to <session>review.md. Doing this in
# the model by hand risks transcription drift (dropped files, mangled checklists); this script
# makes it deterministic.
set -euo pipefail

usage() {
  echo "Usage: $0 <review-session-folder> <workflow-output-file>" >&2
  echo "  review-session-folder  repo-relative session path, e.g. .reviews/2026-08-01-153000/ (must end in /)" >&2
  echo "  workflow-output-file   JSON file holding the review-workflow.js return value — either the" >&2
  echo "                         task's <output-file> ({ result: { reviewMd, auditFiles, ... } })" >&2
  echo "                         or a bare { reviewMd, auditFiles, findings, failed } object" >&2
  exit 1
}

[ $# -eq 2 ] || usage

SESSION="$1"
OUTPUT_FILE="$2"

case "$SESSION" in
  .reviews/*/) ;;
  *)
    echo "error: <review-session-folder> must look like .reviews/<session>/ (with trailing slash), got: $SESSION" >&2
    exit 1
    ;;
esac

[ -f "$OUTPUT_FILE" ] || { echo "error: workflow output file not found: $OUTPUT_FILE" >&2; exit 1; }

# Unwrap the Task tool's { result: {...} } envelope when present; otherwise use the file as-is.
ROOT='(.result // .)'

jq -e "${ROOT} as \$r | (\$r | has(\"reviewMd\")) and ((\$r.auditFiles // []) | type == \"array\") and ((\$r.failed // []) | type == \"array\")" \
  "$OUTPUT_FILE" >/dev/null 2>&1 \
  || { echo "error: $OUTPUT_FILE has no (optionally .result-wrapped) reviewMd/auditFiles/failed fields" >&2; exit 1; }

mkdir -p "$SESSION"

AUDIT_COUNT=0
while IFS= read -r row; do
  path=$(jq -r '.path' <<<"$row")
  mkdir -p "$(dirname "$path")"
  jq -r '.content' <<<"$row" > "$path"
  echo "wrote $path"
  AUDIT_COUNT=$((AUDIT_COUNT + 1))
done < <(jq -c "${ROOT}.auditFiles // []  | .[]" "$OUTPUT_FILE")

jq -r "${ROOT}.reviewMd" "$OUTPUT_FILE" > "${SESSION}review.md"
echo "wrote ${SESSION}review.md"

FAILED_COUNT=$(jq "(${ROOT}.failed // []) | length" "$OUTPUT_FILE")
if [ "$FAILED_COUNT" -gt 0 ]; then
  echo ""
  echo "FAILED (not reviewed):"
  jq -r "(${ROOT}.failed // [])[] | \"  - \(.reviewer) / \(.chunk)\"" "$OUTPUT_FILE"
fi

echo ""
echo "Session materialised: ${SESSION} (${AUDIT_COUNT} audit file(s), review.md)"
