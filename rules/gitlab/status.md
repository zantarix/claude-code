Update GitLab issue status to reflect the current stage of work.

**Why:** Keeping issue status current lets the team see what's actively being worked on without asking.

**How to apply:**

The project uses these native work item status values: `Triage` → `To do` → `In progress` → `Done`. There are also terminal statuses `Duplicate` and `Won't do` for closing without completion — set these when appropriate instead of `Done`.

- Before planning or implementing a ticket: set status to `In progress` (unless it's already there).
- Do not move a ticket backwards — if it's already at a later stage, leave it.
- Status is a native GitLab work item field, not a label. The GitLab MCP (`mcp__gitlab__manage_work_item`) cannot update the `statusWidget` field, so use `glab api graphql`. Resolve the global ID from the project path and iid, then mutate:

```sh
# 1. Look up status IDs (do this once per session)
glab api graphql -f query='query { workItemAllowedStatuses { nodes { id name } } }'

# 2. Update by iid (replace PROJECT, IID, and STATUS_GID)
WORK_ITEM_ID=$(glab api graphql -f query='query { project(fullPath: "PROJECT") { workItems(iid: "IID") { nodes { id } } } }' | jq -r '.data.project.workItems.nodes[0].id')
glab api graphql -f query="mutation { workItemUpdate(input: { id: \"$WORK_ITEM_ID\", statusWidget: { status: \"STATUS_GID\" } }) { errors } }"
```
