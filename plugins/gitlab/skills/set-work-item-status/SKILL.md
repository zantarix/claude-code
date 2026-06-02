---
name: set-work-item-status
description: |-
  Set the native status field of a GitLab work item — Triage, To do, In progress,
  Done, Duplicate, or Won't do. Use when moving a ticket's stage of work, e.g.
  marking it In progress before starting or Done when finished.
---

Set a GitLab work item's native status. Status is a native field, not a label, and the GitLab MCP (`mcp__gitlab__manage_work_item`) cannot write the `statusWidget` field — use `glab api graphql`.

Status values: `Triage` → `To do` → `In progress` → `Done`, plus terminal `Duplicate` and `Won't do`.

```sh
# 1. Look up status IDs (once per session)
glab api graphql -f query='query { workItemAllowedStatuses { nodes { id name } } }'

# 2. Resolve the work item GID from its iid, then mutate (replace PROJECT, IID, STATUS_GID)
WORK_ITEM_ID=$(glab api graphql -f query='query { project(fullPath: "PROJECT") { workItems(iid: "IID") { nodes { id } } } }' | jq -r '.data.project.workItems.nodes[0].id')
glab api graphql -f query="mutation { workItemUpdate(input: { id: \"$WORK_ITEM_ID\", statusWidget: { status: \"STATUS_GID\" } }) { errors } }"
```
