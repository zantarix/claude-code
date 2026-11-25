Update the status of a GitLab work item to match the current stage of the work.

The project uses these native status values in order: `Triage`, `To do`, `In progress`, `Done`. Two terminal values close a work item without completion: `Duplicate` and `Won't do`. Use them instead of `Done` when they fit.

Never move a work item backwards. If it is at a later stage, leave it.

Status is a native work item field, not a label. The GitLab MCP cannot write it. To change it, invoke the `gitlab:set-work-item-status` skill with the Skill tool. The skill handles the `glab api graphql` lookup and the `statusWidget` mutation.
