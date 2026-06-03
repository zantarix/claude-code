# Git workflow

## Committing changes

When the user asks to commit changes ("commit", "make a commit", "commit these changes", or similar), invoke the `zantarix:commit` skill via the Skill tool before any other action — do not reach for `git commit` directly.

## Integrating finished branches

When integrating a finished feature branch into `main` where fast-forward is not possible, cherry-pick the branch's commit(s) onto `main` rather than creating a merge commit, to keep history linear. Then remove the worktree and delete the branch.
