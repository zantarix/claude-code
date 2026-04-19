---
name: changeset
description: Use to draft and record a release changelog entry for the current changes.
---

Draft and record a changeset entry for the current changes. Perform the steps below in order.

1. **Draft** a changeset message and determine the change type:
   - Run `git diff HEAD` (or `git diff <base>` if a base ref is provided via `$ARGUMENTS`) to understand what changed.
   - Focus on **user-facing impact**: what the user can now do, what was fixed, or what broke compatibility. Do not summarise the implementation internals or the *why*.
   - Use plain, present-tense language (e.g. "Adds", "Fixes", "Removes"). Avoid jargon.
   - Keep the message concise — one sentence for simple changes, a short paragraph for larger ones.
   - Determine the change type:
     - `major` — breaking changes (removes or alters existing behaviour incompatibly)
     - `minor` — new user-facing features that are backwards-compatible
     - `patch` — bug fixes, performance improvements, or other non-breaking changes

2. **Record** the changeset using a HEREDOC to preserve formatting:

   ```bash
   cursus change --change-type "<patch|minor|major>" -m "$(cat <<'EOF'
   <message>
   EOF
   )"
   ```
