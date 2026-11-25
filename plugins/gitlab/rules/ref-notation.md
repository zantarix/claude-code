Respect the sigil in a GitLab reference exactly. `#N`, `!N`, and `&N` are distinct objects that can share a number:

- `#N` is a work item. Use `mcp__gitlab__browse_work_items` (action `get`, with `namespace` and `iid`).
- `!N` is a merge request. Use `mcp__gitlab__browse_merge_requests` (action `get`, with `merge_request_iid`).
- `&N` is an epic. Use `mcp__gitlab__browse_work_items` (action `get`, with the group `namespace` and `iid`).

Never substitute one sigil for another, even when the numbers match.
