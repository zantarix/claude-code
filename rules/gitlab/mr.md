When the user asks to create/open/raise a merge request, invoke the gitlab:create-merge-request skill via the Skill tool before any other action — do not reach for `mcp__gitlab__manage_merge_request` or `glab mr create` directly.

**Why:** The skill encodes an opinionated workflow (check for existing MR, collect commit diff, read review.md, post review comment) that bare MCP/bash calls don't reproduce. The system rules make this a blocking requirement when a skill matches the request. User corrected this when I reached for the MCP instead of the skill.

**How to apply:** Any time the user says "create a mr", "create a merge request", "open a merge request", "raise a merge request", or similar — stop, invoke the skill first, then follow that workflow. Note: "open a PR" and "create a PR" are GitHub-specific phrasings covered by the github:pr rule; do not invoke the GitLab skill for those. Don't treat "sequence execution mode" as a reason to skip the skill lookup step.
