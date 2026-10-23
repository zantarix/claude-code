# Closing a ticket from a commit

When a commit completes the work for a `#N`-referenced GitLab work item — an Issue, Task, or
custom type like Bug — add a `Closes #N` footer line to the commit message (above the
`Assisted-By` trailer), not just a `(#N)` reference in the subject. A `(#N)` subject reference
alone does not close the item; the `Closes #N` footer auto-closes it when the change reaches
the default branch.

Epics are referenced `&N`, not `#N`, and are not closed by a `Closes` footer; close them
manually via the `gitlab:set-work-item-status` skill.

For a mid-phase commit that does not complete the item, keep the `(#N)` reference but omit
`Closes`.

See also `git-workflow`.
