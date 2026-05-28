---
name: mr-review-comments
description: Fetch open MR review comments with resolution status for the current branch.
---

Fetch all diff-thread review comments for the current branch's MR, grouped by resolved/unresolved.

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

### 3. Fetch diff discussion threads

```bash
glab mr note list <iid> --type diff -F json
```

This returns an array of discussion objects. Filter to discussions that contain at least one note where `system == false` (the `--type diff` flag targets `DiffNote` threads, but system-generated follow-up notes — e.g. "changed this line in version 2" — can appear in the same thread and must be skipped).

For each qualifying discussion, all fields are extracted from the **first note where `system == false`**:

| Field | Path (relative to that note) |
|---|---|
| Resolution status | `.resolved` (boolean) |
| File path | `.position.new_path` |
| Line (new side) | `.position.new_line` (may be `null` for comments on removed lines) |
| Line (old side) | `.position.old_line` (use as fallback when `new_line` is `null`) |
| Comment body | `.body` |
| Author | `.author.username` |

### 4. Group and display

Split discussions into **unresolved** (`resolved == false`) and **resolved** (`resolved == true`). Present unresolved first.

## Output format

```
## Open review comments (N)

1. [path/to/file.rs:42] username: <comment body>
2. ...

## Resolved (N)

- [path/to/file.rs:10] username: <comment body> ✓
```

Use `new_line` as the line number; fall back to `old_line` when `new_line` is `null` (comment targets a removed line).
