# Creating and converting GitLab work items with custom types

The `mcp__gitlab__manage_work_item` tool only accepts built-in GitLab work item types via its enum (`ISSUE`, `TASK`, `EPIC`, etc.). Custom types like `Bug`, `Incident`, `Ticket`, `Tracker` require `glab api graphql`.

### Look up type GIDs

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

### Create a custom-typed work item

```sh
glab api graphql -f query='mutation { workItemCreate(input: {
  namespacePath: "NAMESPACE",
  workItemTypeId: "gid://gitlab/WorkItems::Type/1114",
  title: "Title here"
}) { errors workItem { iid workItemType { name } } } }'
```

### Change an existing work item's type

Use `workItemConvert`, not `workItemUpdate` — `workItemTypeId` is not accepted by `WorkItemUpdateInput`:

```sh
glab api graphql -f query='mutation { workItemConvert(input: {
  id: "gid://gitlab/WorkItem/NUMERIC_ID",
  workItemTypeId: "gid://gitlab/WorkItems::Type/1114"
}) { errors workItem { workItemType { name } } } }'
```
