Update GitLab work item status to reflect the current stage of work.

The project uses these native status values: `Triage` → `To do` → `In progress` → `Done`, plus terminal `Duplicate` and `Won't do` for closing without completion (use these instead of `Done` when appropriate).

- Before planning or implementing a ticket: set status to `In progress` (unless it's already there or further along).
- Never move a ticket backwards — if it's at a later stage, leave it.

Status is a native work item field, not a label, and the GitLab MCP cannot write it. To change it, invoke the `gitlab:set-work-item-status` skill via the Skill tool (it handles the `glab api graphql` lookup and `statusWidget` mutation).
