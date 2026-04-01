# Architecture Decision Register

Big decisions are documented in ADR format in the `docs/adr/` folder. To see what ADRs exist, their titles, statuses, and summaries, consult @docs/adr/README.md

Any changes to the `docs/adr/` folder should be handled by delegating to the `@adr-architect` agent.

When reading an ADR file, always read the whole file. Errata appear at the end of the file which may change the context of the content.

ADR's can be in one of four statuses:

* **Proposed** ADRs are still under discussion and haven't been implemented yet.
* **Accepted** ADRs have been implemented.
* **Deprecated** ADRs are no longer relevant, but were not specifically replaced new decisions.
* **Superceded** ADRs are no longer relevant, but have been replaced with a new decision.

Once an ADR has been marked accepted and committed to git, it is immutable. The only exceptions to this is further updates to it's status or the addition of an Errata section at the end of the ADR with notes about smaller changes that affect this ADR with a forward link to the ADR that made the change.

## Related Projects

When writing ADRs that reference cursus or other related Zantarix projects, check the ADRs of those related projects for relevant context and prior decisions. Related Zantarix project repositories can be found as siblings of the current project folder (e.g., `../cursus` for the cursus project). The Related Projects section of @docs/adr/README.md lists the known related projects and their GitHub URLs.

When cross-linking to ADRs in related projects, use the format "Project Name ADR-XXX" as the link label and link to the ADR file on GitHub rather than using relative paths. For example: `[Cursus ADR-001](https://github.com/zantarix/cursus/blob/main/docs/adr/001-some-decision.md)`.
