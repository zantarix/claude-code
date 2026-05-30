# Git workflow

## Integrating finished branches

When integrating a finished feature branch into `main` where fast-forward is not possible, cherry-pick the branch's commit(s) onto `main` rather than creating a merge commit. This keeps `main`'s history linear. Then remove the worktree and delete the branch.
