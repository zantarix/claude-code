When a GitLab work item (see `terminology`) lists pre-work that must happen before the main implementation — write an ADR, decide between options, spike research, dependency upgrades — create that pre-work as child **Task** work items parented to the ticket, not prose in the description. (Tickets *blocking* this one are a different relationship — use `work-item-links`.)

Invoke the `gitlab:create-child-task` skill via the Skill tool (it handles the MCP create, the GraphQL fallback, and the Task-type/parent resolution). Task titles should name a deliverable ("Draft ADR for X"), not pose a question.

See also: `work-item-links`, `custom-work-item-types`.
