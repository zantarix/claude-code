Respect the sigil in a GitLab reference exactly. `#N`, `!N`, and `&N` are distinct objects that can share a number:

- `#N` is a work item. Use `get_issue` or the work-item notes for that iid.
- `!N` is a merge request. Use `get_merge_request`.
- `&N` is an epic.

Never substitute one sigil for another, even when the numbers match.
