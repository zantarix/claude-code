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
| Agent | `adr-architect` | Create and maintain Architecture Decision Records in `docs/adr/` |
| Agent | `documentation-reviewer` | Review code changes and identify project documentation that needs updating |
| Rule | `adr` | Instructs Claude to delegate ADR changes to the `adr-architect` agent |
| Rule | `agent-role` | Defines Claude's role as an adversarial pair-programming partner |
| Rule | `init` | Conventions for managing `CLAUDE.md` and `.claude/rules/` files |
| Rule | `investigation` | Never claim "known issue" without evidence — bisect first to rule out self-introduced regressions |
| Rule | `nix` | Nix flakes and direnv guidance for development environments |
| Rule | `plans` | Implementation plan conventions (verification, review, and commit behaviour) |
| Rule | `tmp` | Prefer `.tmp/` inside the repo over `/tmp` for scratch artefacts |

### `github`

Skills, agents, and rules for GitHub projects.

| Type | Name | Description |
|------|------|-------------|
| Skill | `pr-review-comments` | Fetch open PR review thread comments with resolution status for the current branch |
| Rule | `github-actions` | Requires pinning GitHub Actions to commit SHAs |

### `gitlab`

Skills, agents, and rules for GitLab projects. Includes an MCP server config for the GitLab MCP at `https://gitlab.com/api/v4/mcp`.

| Type | Name | Description |
|------|------|-------------|
| Skill | `create-merge-request` | Create a GitLab MR for the current branch; posts the session's `/review` summary as a comment if the session folder is known |
| Skill | `mr-review-comments` | Fetch open MR diff-thread review comments with resolution status for the current branch |
| Rule | `gitlab-ci` | Requires pinning GitLab CI includes/components and Docker images to immutable SHAs |
| Rule | `prefer-gitlab-mcp` | Prefer `mcp__plugin_gitlab_gitlab__*` tools over the `glab` CLI for GitLab operations |
| Rule | `ref-notation` | Honour GitLab reference sigils: `#N` = issue, `!N` = MR, `&N` = epic |
| Rule | `status` | Update the native work item status field (`Triage` → `To do` → `In progress` → `Done`) as work progresses |
| Rule | `use-glab-cli-not-curl` | Use `glab` CLI instead of raw `curl` for GitLab API calls |

### `rescript`

Skills, agents, and rules for ReScript frontend projects.

| Type | Name | Description |
|------|------|-------------|
| Skill | `verify-code` | Format (`pnpm format`), build (`pnpm build`), and test (`pnpm test`) |
| Agent | `code-reviewer` | Thorough frontend code review covering ReScript, React, TailwindCSS, rescript-relay, and FFI bindings |
| Rule | `rescript` | ReScript language and project conventions |
| Rule | `ffi-bindings` | FFI binding organisation, interface file requirements, and colocating reusable domain helpers |
| Rule | `named-type-aliases` | Prefer named `type t` aliases over inlined primitives for domain-semantic collections |

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
| Rule | `dependencies` | Dependency management conventions |
| Rule | `modules` | Module organisation conventions |
| Rule | `non-functional` | Non-functional requirements (performance, reliability, etc.) |
| Rule | `style` | Code style conventions |
