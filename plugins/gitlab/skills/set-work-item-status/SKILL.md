---
name: set-work-item-status
description: |-
  Set the native status field of a GitLab work item — Triage, To do, In progress,
  Blocked, Done, Duplicate, or Won't do. Use when moving a work item's stage of work,
  e.g. marking it In progress before starting or Done when finished.
---

Set the native status of a GitLab work item. Status is a native field, not a label.

Status values: `Triage` → `To do` → `In progress` → `Done`, plus the side state `Blocked` and the terminal values `Duplicate` and `Won't do`.

## Done: use the MCP

1. Get the numeric ID of the work item with `mcp__gitlab__browse_work_items` (action `get`, with `namespace` and `iid`). Do not pass the iid as `id`.
2. Close the work item. GitLab sets the status to `Done` automatically:

```
mcp__gitlab__manage_work_item
  action: update
  id: "<numeric-id>"
  state: CLOSE
```

## Other values: use glab

The MCP cannot read or set other status values. Use `glab api graphql`.

First, read the current status:

```sh
glab api graphql -f query='query { project(fullPath: "PROJECT") { workItems(iid: "IID") { nodes { widgets { ... on WorkItemWidgetStatus { status { name } } } } } } }'
```

If the current status is at a later stage than the target, stop. `Blocked` → `In progress` is not a move backwards. `Blocked` → `To do` is.

Then set the status:

```sh
# 1. Look up status IDs (once per session)
glab api graphql -f query='query { workItemAllowedStatuses { nodes { id name } } }'

# 2. Resolve the work item GID from its iid, then mutate (replace PROJECT, IID, STATUS_GID)
WORK_ITEM_ID=$(glab api graphql -f query='query { project(fullPath: "PROJECT") { workItems(iid: "IID") { nodes { id } } } }' | jq -r '.data.project.workItems.nodes[0].id')
glab api graphql -f query="mutation { workItemUpdate(input: { id: \"$WORK_ITEM_ID\", statusWidget: { status: \"STATUS_GID\" } }) { errors } }"
```
