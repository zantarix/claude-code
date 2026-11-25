# Closing a work item from a commit

When a commit completes a `#N`-referenced GitLab work item, add a `Closes #N` footer line to the commit message. Place it above the `Assisted-By` trailer. The work item can be an Issue, a Task, or a custom type such as Bug. A `(#N)` reference in the subject does not close the work item. The `Closes #N` footer closes it automatically when the change reaches the default branch.

Epics use `&N`, not `#N`. A `Closes` footer does not close an Epic. Close an Epic manually with the `gitlab:set-work-item-status` skill.

When a mid-phase commit does not complete the work item, keep the `(#N)` reference. Omit `Closes`.
