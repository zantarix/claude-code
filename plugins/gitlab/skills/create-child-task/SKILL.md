---
name: create-child-task
description: |-
  Create preparatory work as child Task work items under a GitLab work item — e.g.
  "draft an ADR", "decide between options", spike research, dependency upgrades.
  Use when a work item's pre-work should be tracked as sub-tasks rather than buried
  in the description.
---

Create child `Task` work items under a GitLab work item. Name a deliverable in each Task title ("Draft ADR for X", "Decide between A and B"). Do not pose a question.

1. Get the numeric ID of the parent with `mcp__gitlab__browse_work_items` (action `get`, with `namespace` and `iid`).
2. Create each Task:

```
mcp__gitlab__manage_work_item
  action: create
  namespace: group/project   # PROJECT path (not group) for Tasks
  workItemType: TASK
  title: "Draft ADR for X"
  description: "Short body."
  parentId: "<numeric-id-of-parent>"
```

## Gotchas

- `Task` is a project-scoped work item type. `Epic` and `Objective` have their own creation flows.
- `parentId` takes the numeric ID or the `gid://gitlab/WorkItem/<id>` form. It does not take the iid.
- Do not mention the parent iid in the description. The hierarchy widget records the relationship and shows it in the UI.
