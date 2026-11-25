Update the status of a GitLab work item to match the current stage of the work.

The project uses these native status values in order: `Triage`, `To do`, `In progress`, `Done`. Two terminal values close a work item without completion: `Duplicate` and `Won't do`. Use them instead of `Done` when they fit.

`Blocked` is a side state of `In progress`. Use it when the work started but cannot continue until something else happens. When the work can continue, change it to `In progress` again. This is not a move backwards.

Never move a work item backwards. If it is at a later stage, leave it.

Status is a native work item field, not a label. To change it, invoke the `gitlab:set-work-item-status` skill with the Skill tool.
