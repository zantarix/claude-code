# Changeset policy

Add a changeset for any change that needs to be released to be useful — including internal refactors, dependency updates, and build fixes. "No user-facing changes" is acceptable text for a changeset, but not a reason to omit one entirely. A change merged to `main` without a changeset will not trigger a release PR.

When adding a changeset, invoke the `zantarix:changeset` skill via the Skill tool — do not reach for `cursus change` directly or write changeset files manually.

**Why:** The skill handles change-type classification and the `cursus change` invocation correctly. Bypassing it risks wrong format or missing metadata.

**How to apply:** Any time a changeset is needed — standalone or as part of a commit workflow — invoke the skill first.
