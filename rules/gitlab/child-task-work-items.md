When a GitLab work item (see `terminology`) lists "work that needs to happen before the main implementation can start" — write an ADR, decide between options, spike research, dependency upgrades — create that pre-work as child **Task** work items parented to the ticket. Do not bury it in the description.

**Why:** Preparatory work described in prose is invisible on boards and untrackable. Child Tasks render as a list inside the parent and as separate work items on boards. (Other tickets *blocking* this one are a different relationship — use `work-item-links`.)

**How to apply:**

Whenever pre-work would otherwise be a bullet list in a ticket's description, invoke the `gitlab:create-child-task` skill via the Skill tool — it handles the MCP create, the GraphQL fallback, and the Task-type/parent resolution. Task titles should name a deliverable ("Draft ADR for X"), not pose a question.

See also: `work-item-links`, `custom-work-item-types`.
