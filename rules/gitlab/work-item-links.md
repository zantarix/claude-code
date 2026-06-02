Link related GitLab work items rather than describing relationships in prose (see `terminology` for the work-item distinction). Prose like "blocked by #N" is invisible to GitLab's board, the work-item graph, and the "Linked items" widget — the formal link is the source of truth.

**How to apply:**

Whenever a description would say "blocks #N", "blocked by #N", "related to #N", or "see #N", create the link. Invoke the `gitlab:link-work-items` skill via the Skill tool — it carries the MCP/GraphQL incantation, the uppercase `linkType` enum, and the iid→GID resolution. Keep prose explanation if it adds context, but the formal link is canonical.

See also: `prefer-gitlab-mcp`, `status`.
