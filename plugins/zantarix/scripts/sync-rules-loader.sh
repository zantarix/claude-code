#!/usr/bin/env bash
# Copies the canonical rules loader (plugins/zantarix/hooks/rules-loader/) into every
# other plugin that ships rules. A hooks module can only import files inside its own
# plugin, so each plugin carries a copy. With --check, exits non-zero on drift instead
# of copying. Tests are not copied.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
src="$root/plugins/zantarix/hooks/rules-loader"
mode="${1:-sync}"
status=0

for plugin in github gitlab rescript rust; do
  dest="$root/plugins/$plugin/hooks"
  for file in index.ts rule.ts; do
    if [ "$mode" = "--check" ]; then
      if ! cmp -s "$src/$file" "$dest/rules-loader/$file"; then
        echo "drift: plugins/$plugin/hooks/rules-loader/$file (run plugins/zantarix/scripts/sync-rules-loader.sh)" >&2
        status=1
      fi
    else
      mkdir -p "$dest/rules-loader"
      cp "$src/$file" "$dest/rules-loader/$file"
    fi
  done
done

exit "$status"
