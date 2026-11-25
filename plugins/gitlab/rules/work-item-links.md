Link related GitLab work items. Do not describe the relationship in prose (see `terminology`). Prose such as "blocked by #N" is invisible to the board, the work-item graph, and the "Linked items" widget.

When a description would say "blocks #N", "blocked by #N", "related to #N", or "see #N", create the link instead. Invoke the `gitlab:link-work-items` skill with the Skill tool. The skill carries the MCP commands, the uppercase `linkType` enum, and the iid-to-ID resolution. You can keep a prose explanation when it adds context. The formal link is the canonical record.
