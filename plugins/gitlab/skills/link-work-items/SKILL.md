---
name: link-work-items
description: |-
  Create, change, or remove a relationship link between two GitLab work items —
  related, blocks, or blocked-by. Use whenever the user wants one work item marked as
  blocking, blocked by, or related to another (e.g. "block api#16 on api#20",
  "mark these as related") rather than describing the relationship in prose.
---

Link two GitLab work items through the relationship API. Prose such as "blocked by #N" is invisible to the GitLab board and to the "Linked items" widget. The formal link is the source of truth.

`linkType` is uppercase: `RELATED | BLOCKS | BLOCKED_BY`. The direction is from the source: `BLOCKED_BY` on source #16 means "#16 is blocked by the target".

1. Get the numeric ID of each work item with `mcp__gitlab__browse_work_items` (action `get`, with `namespace` and `iid`).
2. Create the link:

```
mcp__gitlab__manage_work_item
  action: add_link
  id: "<numeric-id-of-source>"
  targetId: "<numeric-id-of-target>"
  linkType: BLOCKED_BY
```

To delete a link, use `action: remove_link` with the same `id` and `targetId`.

## Gotchas

- `id` and `targetId` take numeric IDs, not iids.
- The API cannot change the type of an existing link. To change the direction, remove the link and add it again.
