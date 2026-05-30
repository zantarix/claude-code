When the user asks to create/open/raise a pull request, invoke the `github:create-pull-request` skill via the Skill tool before any other action — do not reach for `gh pr create` directly.

**Why:** The skill encodes an opinionated workflow (check for existing PR, collect commit diff, read review.md, post review comment) that bare `gh` calls don't reproduce. The system rules make this a blocking requirement when a skill matches the request.

**How to apply:** Any time the user says "create a pr", "open a pull request", "raise a PR", or similar on a GitHub project — stop, invoke the skill first, then follow that workflow.
