When a GitLab work item (see `terminology`) lists "work that needs to happen before the main implementation can start" (write an ADR, decide between options, spike research, dependency upgrades), create that pre-work as child **Task** work items parented to the ticket. Do not bury it in the description.

**Why:** Two classes of dependency-shaped prose appear on work items — other tickets blocking this one (use `work-item-links`) and preparatory work within the same scope. Preparatory work in prose is invisible on boards and untrackable. Child Tasks render as a checklist inside the parent and as separate work items on boards.

**How to apply:**

The GitLab MCP has `create_issue` but no `create_workitem` (cannot pick the `Task` type), so this requires `glab api graphql` with `workItemCreate`.

```sh
# Task type GID on gitlab.com (verify per-project if uncertain):
#   glab api graphql -f query='query { project(fullPath: "PROJECT") { workItemTypes { nodes { id name } } } }'
TASK_TYPE="gid://gitlab/WorkItems::Type/5"

# Parent GID (resolve from iid — see work-item-links rule):
PARENT="gid://gitlab/WorkItem/<parent-id>"

glab api graphql -f query="mutation { workItemCreate(input: {
  namespacePath: \"PROJECT_PATH\",
  workItemTypeId: \"$TASK_TYPE\",
  title: \"Draft ADR for X\",
  descriptionWidget: { description: \"Short body. Parent: #<iid>.\" },
  hierarchyWidget: { parentId: \"$PARENT\" }
}) { errors workItem { iid webUrl } } }"
```

**Gotchas:**

- Task titles should name a deliverable ("Draft ADR for X", "Decide between A and B"), not a question.
- Embedded double quotes in the description string break GraphQL parsing of the `-f query=...` form. Either avoid them or pass the input as a variable via `-F variables=@vars.json` with a parameterised mutation.
- `Task` is a project-scoped work item type. `Epic` and `Objective` have their own creation flows.

See also: `work-item-links` for the iid→GID lookup pattern.
