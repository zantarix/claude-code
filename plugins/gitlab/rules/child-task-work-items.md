A GitLab work item can list pre-work that must happen before the main implementation. Create that pre-work as child **Task** work items, parented to the work item. Do not write it as prose in the description. Examples of pre-work are writing an ADR, deciding between options, spike research, and dependency upgrades.

A work item that *blocks* this one is a different relationship. For that, use `work-item-links`.

Invoke the `gitlab:create-child-task` skill with the Skill tool. The skill handles the MCP create and the resolution of the parent. Name a deliverable in each Task title ("Draft ADR for X"). Do not pose a question.
