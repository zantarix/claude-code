# zantarix/claude-code

Claude Code plugins for Zantarix projects.

## Usage

Add this marketplace to your project's Claude Code configuration to pull in the plugins you need.

## Plugins

### `base`

General-purpose skills, agents, and rules for all Zantarix projects.

| Type | Name | Description |
|------|------|-------------|
| Skill | `accept-adr` | Review ADR implementation for completeness and mark it as accepted |
| Skill | `commit` | Verify and commit staged/unstaged changes with a well-crafted Conventional Commit message |
| Skill | `implement-ticket` | Work a ticket reference to completion — fetch the issue, clarify intent, then plan or implement |
| Skill | `memory-reconciliation` | Triage accumulated project memories into discard / keep / promote-to-project-rule / promote-to-org-rule |
| Skill | `plan-adr` | Enter planning mode to scope a decision with the user, then delegate to `adr-architect` to write the ADR |
| Skill | `review` | Run all `*-reviewer` agents concurrently, auto-fix critical/major issues, and report results |
| Skill | `upstream` | Commit changes, push the branch, and open a pull/merge request in one flow |
| Agent | `adr-architect` | Create and maintain Architecture Decision Records in `docs/adr/` |
| Agent | `documentation-reviewer` | Review code changes and identify project documentation that needs updating |
| Rule | `adr` | Instructs Claude to delegate ADR changes to the `adr-architect` agent |
| Rule | `adr-workflow` | ADR process conventions: when to write, scanning Proposed ADRs, pausing before acceptance, verifying existing implementation |
| Rule | `agent-role` | Defines Claude's role as an adversarial pair-programming partner |
| Rule | `changesets` | Changeset policy: always add a changeset for any releasable change |
| Rule | `git-workflow` | Prefer cherry-pick over merge commit when integrating a finished branch into `main` |
| Rule | `init` | Conventions for managing `CLAUDE.md` and `.claude/rules/` files |
| Rule | `investigation` | Never claim "known issue" without evidence — bisect first to rule out self-introduced regressions |
| Rule | `memory-feedback` | Write feedback memories as generalized rules, not session-specific notes; reframe narrow entries rather than discarding them |
| Rule | `nix` | Nix flakes and direnv guidance for development environments, including dev shell lifecycle |
| Rule | `plans` | Implementation plan conventions (verification, review, commit behaviour, and surfacing real alternatives) |
| Rule | `preserve-multiphase-contracts` | Preserve observable multi-phase contracts rather than collapsing them into single atomic calls |
| Rule | `tmp` | Prefer `.tmp/` inside the repo over `/tmp` for scratch artefacts |

### `github`

Skills, agents, and rules for GitHub projects.

| Type | Name | Description |
|------|------|-------------|
| Skill | `create-pull-request` | Create a GitHub PR for the current branch; posts the session's `/review` summary as a comment if the session folder is known |
| Skill | `pr-review-comments` | Fetch open PR review thread comments with resolution status for the current branch |
| Rule | `github-actions` | Requires pinning GitHub Actions to commit SHAs |
| Rule | `pr` | Always invoke the `github:create-pull-request` skill rather than calling `gh pr create` directly |

### `gitlab`

Skills, agents, and rules for GitLab projects. Uses the [GitLab MCP server](https://gitlab-mcp.sw.foundation/guide/quick-start) — a local MCP that exposes browse/manage tool pairs (`mcp__gitlab__browse_*` / `mcp__gitlab__manage_*`) for work items, merge requests, pipelines, and more.

| Type | Name | Description |
|------|------|-------------|
| Skill | `create-merge-request` | Create a GitLab MR for the current branch; posts the session's `/review` summary as a comment if the session folder is known |
| Skill | `mr-review-comments` | Fetch open MR review comments and discussion threads (diff and general) with resolution status for the current branch |
| Rule | `child-task-work-items` | Create pre-work as child `Task` work items rather than bullet points in the description |
| Rule | `gitlab-ci` | Requires pinning GitLab CI includes/components and Docker images to immutable SHAs |
| Rule | `mr` | Always invoke the `gitlab:create-merge-request` skill rather than reaching for MCP or `glab` directly |
| Rule | `prefer-gitlab-mcp` | Prefer `mcp__gitlab__*` tools over the `glab` CLI for GitLab operations |
| Rule | `ref-notation` | Honour GitLab reference sigils: `#N` = issue, `!N` = MR, `&N` = epic |
| Rule | `status` | Update the native work item status field (`Triage` → `To do` → `In progress` → `Done`) as work progresses |
| Rule | `terminology` | "Ticket" is any work item (Issue/Task/custom); default to work-item APIs over legacy `/issues` endpoints |
| Rule | `use-glab-cli-not-curl` | Use `glab` CLI instead of raw `curl` for GitLab API calls |
| Rule | `work-item-links` | Link related work items via API rather than naming them in prose |

### `rescript`

Skills, agents, and rules for ReScript frontend projects.

| Type | Name | Description |
|------|------|-------------|
| Skill | `verify-code` | Format (`pnpm format`), build (`pnpm build`), and test (`pnpm test`) |
| Agent | `code-reviewer` | Thorough frontend code review covering ReScript, React, TailwindCSS, rescript-relay, and FFI bindings |
| Rule | `rescript` | ReScript language and project conventions |
| Rule | `ffi-bindings` | FFI binding organisation, interface file requirements, and colocating reusable domain helpers |
| Rule | `named-type-aliases` | Prefer named `type t` aliases over inlined primitives for domain-semantic collections |
| Rule | `react-optional-props` | Required annotation asymmetry for optional props with no default: `T=?` in `.resi`, `option<T>=?` in `.res` |

### `rust`

Skills, agents, and rules for Rust projects.

| Type | Name | Description |
|------|------|-------------|
| Skill | `analyse-mutations` | Analyse `cargo mutants` output and orchestrate parallel subagent fixes for under-tested code paths |
| Skill | `verify-code` | Lint (`cargo clippy`), test with coverage (`cargo make coverage`), and format (`cargo fmt`) |
| Agent | `code-reviewer` | Thorough code review covering correctness, safety, style, coverage, and architecture |
| Rule | `clippy` | Valid reasons to suppress Clippy lints and how to read clippy output |
| Rule | `mutants` | No mutation-test exclusions — prefer adding tests or simplifying code over suppressing results |
| Rule | `coverage` | Coverage tooling (`cargo llvm-cov`), cfg registration, and `coverage(off)` attribute usage |
| Rule | `dependencies` | Dependency management: ask before adding, run `cargo deny check`, and `cargo clean` on proc-macro cache errors |
| Rule | `docs` | Use `docs.rs/<crate>/latest/` URLs rather than version-pinned links |
| Rule | `error-handling` | Prefer `anyhow::Result<Outcome>` over enums with a `Failure` variant |
| Rule | `modules` | Module organisation conventions |
| Rule | `non-functional` | Non-functional requirements (performance, reliability, etc.) |
| Rule | `style` | Code style conventions |
| Rule | `workflow` | Prefer `cargo make` tasks over README runbooks for repeatable maintenance steps |
