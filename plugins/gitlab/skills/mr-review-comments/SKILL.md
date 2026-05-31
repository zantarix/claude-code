---
name: mr-review-comments
description: Fetch open MR review comments with resolution status for the current branch.
---

Fetch all review comments and discussion threads for the current branch's MR, grouped by
resolved/unresolved. Captures both diff-attached comments and general MR-level threads.

## Steps

### 1. Get the current branch name

```bash
git branch --show-current
```

### 2. Find the MR IID for this branch

```bash
glab mr list --source-branch <branch> -F json | jq '.[0].iid'
```

If the array is empty, report that no open MR exists for this branch and stop.

### 3. Fetch all discussion threads

Use `mcp__gitlab__browse_mr_discussions` (action: list) to retrieve all discussions for the MR.

Fallback — fetch via REST API:

```bash
glab api "projects/:fullpath/merge_requests/<iid>/discussions" --paginate
```

Filter to discussions where at least one note has `system == false`. Discard discussions composed
entirely of system-generated notes (e.g. "changed this line in version 2").

For each qualifying discussion, extract the following from the **first note where `system == false`**:

| Field | Source |
|---|---|
| Resolution status | `.resolved` on the discussion object |
| Comment type | diff if `note.position != null`; general otherwise |
| File path | `note.position.new_path` (diff comments only) |
| Line number | `note.position.new_line`, fallback to `note.position.old_line` (diff only) |
| Body | `note.body` |
| Author | `note.author.username` |

### 4. Group and display

Split into **unresolved** (`resolved == false`) and **resolved** (`resolved == true`). Show
unresolved first.

## Output format

```
## Open review comments (N)

1. [path/to/file.rs:42] username: <diff comment body>
2. username: <general comment body>
...

## Resolved (N)

- [path/to/file.rs:10] username: <resolved diff comment> ✓
- username: <resolved general comment> ✓
```

Diff comments include a `[file:line]` prefix. General comments (null position) have no file/line
prefix. Use `new_line` for the line number; fall back to `old_line` when `new_line` is `null`.
