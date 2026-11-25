---
name: custom-work-item-types
description: |-
  Create a GitLab work item of a custom type that the MCP enum doesn't support —
  Bug, Ticket, or Tracker — or convert an existing work item to another type. Use when
  creating one of these types or changing an existing item's type.
---

Create GitLab work items of custom types, or change the type of a work item. The `workItemType` enum of `mcp__gitlab__manage_work_item` accepts only built-in types (`ISSUE`, `TASK`, `EPIC`, `INCIDENT`, …). Use the MCP for those. Custom types and type changes need `glab api graphql`.

## Look up type GIDs

```sh
glab api graphql -f query='query { namespace(fullPath: "NAMESPACE_PATH") { workItemTypes { nodes { id name } } } }'
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

After the create, use the MCP for all other changes: description, labels, links, and comments.

## Change an existing work item's type

Use `workItemConvert`, not `workItemUpdate`. `WorkItemUpdateInput` does not accept `workItemTypeId`.

```sh
glab api graphql -f query='mutation { workItemConvert(input: {
  id: "gid://gitlab/WorkItem/NUMERIC_ID",
  workItemTypeId: "gid://gitlab/WorkItems::Type/1114"
}) { errors workItem { workItemType { name } } } }'
```

GitLab refuses some conversions. Read `errors` and report the refusal to the user. Known refusals:

- A work item with a parent cannot become a `Bug`. Ask the user whether to remove the parent or keep the type.
- A conversion to `Ticket` failed from an `Incident` with "Work items cannot be converted to Ticket".
