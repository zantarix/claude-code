# Changeset policy

Add a changeset for every change that needs a release to be useful. This includes internal refactors, dependency updates, and build fixes. "No user-facing changes" is acceptable changeset text. It is not a reason to omit a changeset. A change merged to `main` without a changeset does not trigger a release PR.

When you need a changeset, standalone or as part of a commit, invoke the `zantarix:changeset` skill with the Skill tool. Do not write changeset files manually.
