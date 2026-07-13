# Closing a ticket from a commit

When a commit completes the work for a GitLab ticket, add a `Closes #N` footer line to the
commit message (above the `Assisted-By` trailer) — not just a `(#N)` reference in the
subject. A `(#N)` subject reference alone does not close the ticket; the `Closes #N` footer
auto-closes it when the change reaches the default branch.

For a mid-phase commit that does not complete the ticket, keep the `(#N)` reference but omit
`Closes`.

See also `git-workflow`.
