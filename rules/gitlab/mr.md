When the user asks to create/open/raise a merge request, invoke the gitlab:create-merge-request skill via the Skill tool before any other action — do not reach for `mcp__plugin_gitlab_gitlab__create_merge_request` or `glab mr create` directly.

**Why:** The skill encodes an opinionated workflow (check for existing MR, collect commit diff, read review.md, post review comment) that bare MCP/bash calls don't reproduce. The system rules make this a blocking requirement when a skill matches the request. User corrected this when I reached for the MCP instead of the skill.

**How to apply:** Any time the user says "create a mr", "open a pr", "raise a merge request", or similar — stop, invoke the skill first, then follow that workflow. Don't treat "sequence execution mode" as a reason to skip the skill lookup step.
