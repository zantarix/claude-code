Link related GitLab work items rather than describing relationships in prose (see `terminology` for the work-item distinction). Prose mentions don't appear in board views, the work-item graph, or the "Linked items" widget.

**Why:** Two-class problem: (a) prose like "blocked by #N" is invisible to GitLab's relationship UI, and (b) the GraphQL link API requires global IDs and uppercase enum values, both of which bite if not documented. This rule captures the working incantation so callers don't reverse-engineer it each time.

**How to apply:**

Whenever a description would say "blocks #N", "blocked by #N", "related to #N", or "see #N", create the link via the API. Keep prose explanation if it adds context, but the formal link is the source of truth.

- **Preferred:** GitLab MCP `mcp__plugin_gitlab_gitlab__link_work_items` — `link_type` is lowercase: `relates_to | blocks | blocked_by`. Requires MCP auth via `/mcp`.
- **Fallback (MCP not available):** `glab api graphql` with `workItemAddLinkedItems`. **Enum casing differs from the MCP** — GraphQL uses `RELATED | BLOCKS | BLOCKED_BY`. Direction is from the source: `linkType: BLOCKED_BY` on source #16 means "#16 is blocked by target".

```sh
# 1. Resolve iid → global ID (linked-items API takes GIDs, not iids)
SRC=$(glab api graphql -f query='query { project(fullPath: "PROJECT") { workItems(iid: "SRC_IID") { nodes { id } } } }' | jq -r '.data.project.workItems.nodes[0].id')
TGT=$(glab api graphql -f query='query { project(fullPath: "PROJECT") { workItems(iid: "TGT_IID") { nodes { id } } } }' | jq -r '.data.project.workItems.nodes[0].id')

# 2. Create the link
glab api graphql -f query="mutation { workItemAddLinkedItems(input: { id: \"$SRC\", workItemsIds: [\"$TGT\"], linkType: BLOCKED_BY }) { errors workItem { iid } } }"

# 3. To remove (e.g. wrong direction):
glab api graphql -f query="mutation { workItemRemoveLinkedItems(input: { id: \"$SRC\", workItemsIds: [\"$TGT\"] }) { errors workItem { iid } } }"
```

**Gotchas:**

- Mentioning `#N` in a description sometimes auto-creates a `relates_to` link but does **not** infer direction. A description saying "blocked by #9" can produce a `blocks → #9` link (backwards). Always verify with a query after a mention.
- `workItemsIds` is plural (max 10 per call).
- The MCP cannot update an existing link type. To change direction, remove and re-add.

See also: `prefer-gitlab-mcp`, `status` (uses the same iid→GID pattern).
