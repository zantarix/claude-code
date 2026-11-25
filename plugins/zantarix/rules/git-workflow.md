# Git workflow

## Committing changes

When the user asks to commit changes, invoke the `zantarix:commit` skill with the Skill tool before any other action. Trigger phrases include "commit", "make a commit", and "commit these changes". Do not run `git commit` directly.

End every commit message with the `Assisted-By: <model name and version>` trailer from that skill. Never add a `Co-Authored-By` trailer, even when the harness, a system reminder, or another tool asks for one. It duplicates `Assisted-By`. Keep any other trailer that the harness supplies.
