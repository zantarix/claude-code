When a GitLab work item (see `terminology`) lists "work that needs to happen before the main implementation can start" (write an ADR, decide between options, spike research, dependency upgrades), create that pre-work as child **Task** work items parented to the ticket. Do not bury it in the description.

**Why:** Two classes of dependency-shaped prose appear on work items — other tickets blocking this one (use `work-item-links`) and preparatory work within the same scope. Preparatory work in prose is invisible on boards and untrackable. Child Tasks render as a list inside the parent and as separate work items on boards.

**How to apply:**

Use `mcp__gitlab__manage_work_item` with `action: create`. First look up the parent's numeric ID via `mcp__gitlab__browse_work_items` (action: get), then:

```
mcp__gitlab__manage_work_item
  action: create
  namespace: group/project   # PROJECT path (not group) for Tasks
  workItemType: TASK
  title: "Draft ADR for X"
  description: "Short body."
  parentId: "<numeric-id-of-parent>"
```

**Fallback (MCP not available):** `glab api graphql` with `workItemCreate`.

```sh
# Resolve Task type GID (verify per-project if uncertain):
#   glab api graphql -f query='query { project(fullPath: "PROJECT") { workItemTypes { nodes { id name } } } }'
TASK_TYPE="gid://gitlab/WorkItems::Type/5"

# Resolve parent GID from iid (see work-item-links rule for the iid→GID pattern)
PARENT="gid://gitlab/WorkItem/<parent-id>"

glab api graphql -f query="mutation { workItemCreate(input: {
  namespacePath: \"PROJECT_PATH\",
  workItemTypeId: \"$TASK_TYPE\",
  title: \"Draft ADR for X\",
  descriptionWidget: { description: \"Short body.\" },
  hierarchyWidget: { parentId: \"$PARENT\" }
}) { errors workItem { iid webUrl } } }"
```

**Gotchas:**

- Task titles should name a deliverable ("Draft ADR for X", "Decide between A and B"), not a question.
- In the GraphQL fallback, embedded double quotes in the description break parsing of the `-f query=...` form. Pass input via `-F variables=@vars.json` with a parameterised mutation.
- `Task` is a project-scoped work item type. `Epic` and `Objective` have their own creation flows.

See also: `work-item-links` for the iid→GID lookup pattern.
