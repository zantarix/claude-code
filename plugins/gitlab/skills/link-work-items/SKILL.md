---
name: link-work-items
description: |-
  Create, change, or remove a relationship link between two GitLab work items —
  related, blocks, or blocked-by. Use whenever the user wants one ticket marked as
  blocking, blocked by, or related to another (e.g. "block api#16 on api#20",
  "mark these as related") rather than describing the relationship in prose.
---

Link two GitLab work items via the relationship API. Prose like "blocked by #N" is invisible to GitLab's board and "Linked items" widget — the formal link is the source of truth.

`linkType` is uppercase in both APIs: `RELATED | BLOCKS | BLOCKED_BY`. Direction is from the source: `BLOCKED_BY` on source #16 means "#16 is blocked by the target".

## Preferred: GitLab MCP

Use `mcp__gitlab__manage_work_item` with `action: add_link`. `id` and `targetId` both take the numeric work item ID from `mcp__gitlab__browse_work_items` results. Use `action: remove_link` to delete a link.

## Fallback: glab api graphql

```sh
# 1. Resolve iid → global ID (the linked-items API takes GIDs, not iids)
SRC=$(glab api graphql -f query='query { project(fullPath: "PROJECT") { workItems(iid: "SRC_IID") { nodes { id } } } }' | jq -r '.data.project.workItems.nodes[0].id')
TGT=$(glab api graphql -f query='query { project(fullPath: "PROJECT") { workItems(iid: "TGT_IID") { nodes { id } } } }' | jq -r '.data.project.workItems.nodes[0].id')

# 2. Create the link
glab api graphql -f query="mutation { workItemAddLinkedItems(input: { id: \"$SRC\", workItemsIds: [\"$TGT\"], linkType: BLOCKED_BY }) { errors workItem { iid } } }"

# 3. Remove (e.g. wrong direction):
glab api graphql -f query="mutation { workItemRemoveLinkedItems(input: { id: \"$SRC\", workItemsIds: [\"$TGT\"] }) { errors workItem { iid } } }"
```

## Gotchas

- `workItemsIds` is plural (max 10 per call) in the GraphQL fallback.
- Neither the MCP nor the GraphQL API can update an existing link type. To change direction, remove and re-add.
