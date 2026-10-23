# Changeset policy

Add a changeset for any change that needs to be released to be useful — including internal refactors, dependency updates, and build fixes. "No user-facing changes" is acceptable changeset text, but not a reason to omit one: a change merged to `main` without a changeset will not trigger a release PR.

Any time a changeset is needed — standalone or as part of a commit — invoke the `zantarix:changeset` skill via the Skill tool. Do not reach for `cursus change` directly or write changeset files manually.
