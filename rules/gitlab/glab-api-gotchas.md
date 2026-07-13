# glab api / MCP gotchas

## Commenting on a non-Issue work item

`mcp__gitlab__manage_mr_discussion` (action `comment`, `noteable_type: "issue"`) only
resolves classic Issue-type work items via `noteable_id`. Passing the id (or
`gid://gitlab/Issue/<id>`) of a **Task**, Epic, or other non-Issue work item 404s
("Resource not found") even with correct access — that item isn't backed by the legacy
Issue model the tool queries.

To comment on a non-Issue work item, get its numeric id via `browse_work_items` (action
`get`), then post with `glab api graphql` using a `WorkItem` GID:

```sh
glab api graphql --field query='
mutation($noteableId: NoteableID!, $body: String!) {
  createNote(input: {noteableId: $noteableId, body: $body}) { note { id url } errors }
}' --field noteableId="gid://gitlab/WorkItem/<numeric-id>" --field body="$(cat body.txt)"
```

## `glab api` needs `--field` for an `@file` body

`glab api -f body=@path` silently posts the literal string `@path` — `-f` is shorthand for
`--raw-field`, which does not dereference `@file`. Use the long form `--field body=@path`.
After any `glab api` POST that embeds file content, inspect the response body to confirm it
wasn't posted as a literal filename string.
