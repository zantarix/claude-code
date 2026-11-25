# glab api / MCP gotchas

## Commenting on a non-Issue work item

`mcp__gitlab__manage_mr_discussion` (action `comment`, `noteable_type: "issue"`) resolves only classic Issue-type work items through `noteable_id`. If you pass the id (or `gid://gitlab/Issue/<id>`) of a **Task**, Epic, or other non-Issue work item, the call returns a 404 ("Resource not found"). This happens even with correct access. The legacy Issue model, which the tool queries, does not back that work item.

To comment on a non-Issue work item, do these steps:

1. Get its numeric id with `browse_work_items` (action `get`).
2. Post the comment with `glab api graphql`, using a `WorkItem` GID:

```sh
glab api graphql --field query='
mutation($noteableId: NoteableID!, $body: String!) {
  createNote(input: {noteableId: $noteableId, body: $body}) { note { id url } errors }
}' --field noteableId="gid://gitlab/WorkItem/<numeric-id>" --field body="$(cat body.txt)"
```

## `glab api` needs `--field` for an `@file` body

`glab api -f body=@path` silently posts the literal string `@path`. The `-f` flag is shorthand for `--raw-field`, which does not read `@file`. Use the long form `--field body=@path`. After any `glab api` POST that embeds file content, inspect the response body. Confirm that it does not contain a literal filename string.
