---
name: create-child-task
description: |-
  Create preparatory work as child Task work items under a GitLab ticket — e.g.
  "draft an ADR", "decide between options", spike research, dependency upgrades.
  Use when a ticket's pre-work should be tracked as sub-tasks rather than buried
  in the description.
---

Create child `Task` work items parented to a GitLab ticket. Task titles should name a deliverable ("Draft ADR for X", "Decide between A and B"), not pose a question.

## Preferred: GitLab MCP

First look up the parent's numeric ID via `mcp__gitlab__browse_work_items` (action: get), then:

```
mcp__gitlab__manage_work_item
  action: create
  namespace: group/project   # PROJECT path (not group) for Tasks
  workItemType: TASK
  title: "Draft ADR for X"
  description: "Short body."
  parentId: "<numeric-id-of-parent>"
```

## Fallback: glab api graphql

```sh
# Resolve Task type GID (verify per-project if uncertain):
#   glab api graphql -f query='query { project(fullPath: "PROJECT") { workItemTypes { nodes { id name } } } }'
TASK_TYPE="gid://gitlab/WorkItems::Type/5"

# Resolve parent GID from its iid
PARENT=$(glab api graphql -f query='query { project(fullPath: "PROJECT") { workItems(iid: "PARENT_IID") { nodes { id } } } }' | jq -r '.data.project.workItems.nodes[0].id')

glab api graphql -f query="mutation { workItemCreate(input: {
  namespacePath: \"PROJECT_PATH\",
  workItemTypeId: \"$TASK_TYPE\",
  title: \"Draft ADR for X\",
  descriptionWidget: { description: \"Short body.\" },
  hierarchyWidget: { parentId: \"$PARENT\" }
}) { errors workItem { iid webUrl } } }"
```

## Gotchas

- `Task` is a project-scoped work item type. `Epic` and `Objective` have their own creation flows.
- In the GraphQL fallback, embedded double quotes in the description break parsing of the `-f query=...` form. Pass input via `-F variables=@vars.json` with a parameterised mutation.
- Do not mention the parent iid in the description — the `hierarchyWidget` already records the relationship and surfaces it in the UI.
