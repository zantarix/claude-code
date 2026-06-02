---
name: custom-work-item-types
description: |-
  Create or convert a GitLab work item to a custom type that the MCP enum doesn't
  support — Bug, Incident, Ticket, or Tracker — via glab api graphql. Use when
  creating one of these types or changing an existing item's type.
---

Create or convert GitLab work items of custom types. The `mcp__gitlab__manage_work_item` enum only accepts built-in types (`ISSUE`, `TASK`, `EPIC`, …); custom types require `glab api graphql`.

## Look up type GIDs

```sh
glab api graphql -f query='query { group(fullPath: "GROUP_PATH") { workItemTypes { nodes { id name } } } }'
```

Known GIDs for this organisation (valid across all projects):

- `Bug` → `gid://gitlab/WorkItems::Type/1114`
- `Epic` → `gid://gitlab/WorkItems::Type/8`
- `Incident` → `gid://gitlab/WorkItems::Type/2`
- `Issue` → `gid://gitlab/WorkItems::Type/1`
- `Task` → `gid://gitlab/WorkItems::Type/5`
- `Ticket` → `gid://gitlab/WorkItems::Type/9`
- `Tracker` → `gid://gitlab/WorkItems::Type/1100`

## Create a custom-typed work item

```sh
glab api graphql -f query='mutation { workItemCreate(input: {
  namespacePath: "NAMESPACE",
  workItemTypeId: "gid://gitlab/WorkItems::Type/1114",
  title: "Title here"
}) { errors workItem { iid workItemType { name } } } }'
```

## Change an existing work item's type

Use `workItemConvert`, not `workItemUpdate` — `workItemTypeId` is not accepted by `WorkItemUpdateInput`:

```sh
glab api graphql -f query='mutation { workItemConvert(input: {
  id: "gid://gitlab/WorkItem/NUMERIC_ID",
  workItemTypeId: "gid://gitlab/WorkItems::Type/1114"
}) { errors workItem { workItemType { name } } } }'
```
