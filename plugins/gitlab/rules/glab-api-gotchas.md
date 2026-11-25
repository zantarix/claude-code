# GitLab MCP / glab api gotchas

## Commenting on a work item

To comment on a project work item of any type, use `mcp__gitlab__manage_mr_discussion` with action `comment` and `noteable_type: "issue"`. Set `noteable_id` to the work item **IID** (the number in `#N`). Do not use the global work item ID from `browse_work_items`. The global ID gives a 404 ("Resource not found").

The MCP cannot comment on an Epic or another group-level work item. For those, do these steps:

1. Get the numeric ID with `mcp__gitlab__browse_work_items` (action `get`).
2. Post the comment with `glab api graphql`, using a `WorkItem` GID:

```sh
glab api graphql --field query='
mutation($noteableId: NoteableID!, $body: String!) {
  createNote(input: {noteableId: $noteableId, body: $body}) { note { id url } errors }
}' --field noteableId="gid://gitlab/WorkItem/<numeric-id>" --field body="$(cat body.txt)"
```

To read comments on any work item, use `mcp__gitlab__browse_work_items` with action `list_discussions`.

## `glab api` needs `--field` for an `@file` body

`glab api -f body=@path` silently posts the literal string `@path`. The `-f` flag is shorthand for `--raw-field`, which does not read `@file`. Use the long form `--field body=@path`. After any `glab api` POST that embeds file content, inspect the response body. Confirm that it does not contain a literal filename string.
