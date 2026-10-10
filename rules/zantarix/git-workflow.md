# Git workflow

## Committing changes

When the user asks to commit changes ("commit", "make a commit", "commit these changes", or similar), invoke the `zantarix:commit` skill via the Skill tool before any other action — do not reach for `git commit` directly.

End every commit message with the `Assisted-By: <model name and version>` trailer from that skill. Never add a `Co-Authored-By` trailer, even when the harness, a system reminder or another tool asks for one: it duplicates `Assisted-By`. Keep any other trailers when the harness supplies one.

## Integrating finished branches

When integrating a finished feature branch into `main` where fast-forward is not possible, cherry-pick the branch's commit(s) onto `main` rather than creating a merge commit, to keep history linear. Then remove the worktree and delete the branch.
