# Git workflow

## Committing changes

When the user asks to commit changes, invoke the `base:commit` skill via the Skill tool before any other action — do not reach for `git commit` directly.

**Why:** The skill runs verify-code, accepts pending ADRs, creates the changeset, stages files safely, and enforces commit message conventions. Bypassing it skips those gates.

**How to apply:** Any time the user says "commit", "make a commit", "commit these changes", or similar — invoke the skill first.

## Integrating finished branches

When integrating a finished feature branch into `main` where fast-forward is not possible, cherry-pick the branch's commit(s) onto `main` rather than creating a merge commit. This keeps `main`'s history linear. Then remove the worktree and delete the branch.
