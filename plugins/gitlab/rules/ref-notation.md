Honour the sigil in a GitLab reference exactly — `#N`, `!N`, and `&N` are distinct objects that can share a number:

- `#N` → issue / work item: use `get_issue` or work-item notes for that iid
- `!N` → merge request: use `get_merge_request`
- `&N` → epic

Never substitute one sigil for another, even when the numbers coincide. Note: `get_workitem_notes` with a given iid resolves the *issue* work item, not the MR.
