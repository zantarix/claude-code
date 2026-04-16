# zantarix/claude-code

Claude Code plugins for Zantarix projects.

## Usage

Add this marketplace to your project's Claude Code configuration to pull in the plugins you need.

## Plugins

### `base`

General-purpose skills, agents, and rules for all Zantarix projects.

| Type | Name | Description |
|------|------|-------------|
| Skill | `commit` | Verify and commit staged/unstaged changes with a well-crafted Conventional Commit message |
| Skill | `accept-adr` | Review ADR implementation for completeness and mark it as accepted |
| Skill | `plan-adr` | Enter planning mode to scope a decision with the user, then delegate to `adr-architect` to write the ADR |
| Skill | `review` | Run all `*-reviewer` agents concurrently, auto-fix critical/major issues, and report results |
| Agent | `adr-architect` | Create and maintain Architecture Decision Records in `docs/adr/` |
| Agent | `documentation-reviewer` | Review code changes and identify project documentation that needs updating |
| Rule | `adr` | Instructs Claude to delegate ADR changes to the `adr-architect` agent |
| Rule | `agent-role` | Defines Claude's role as an adversarial pair-programming partner |
| Rule | `init` | Conventions for managing `CLAUDE.md` and `.claude/rules/` files |
| Rule | `nix` | Nix flakes and direnv guidance for development environments |
| Rule | `plans` | Implementation plan conventions (verification, review, and commit behaviour) |

### `rescript`

Skills, agents, and rules for ReScript frontend projects.

| Type | Name | Description |
|------|------|-------------|
| Skill | `verify-code` | Format (`pnpm format`), build (`pnpm build`), and test (`pnpm test`) |
| Agent | `code-reviewer` | Thorough frontend code review covering ReScript, React, TailwindCSS, rescript-relay, and FFI bindings |
| Rule | `rescript` | ReScript language and project conventions |
| Rule | `ffi-bindings` | FFI binding organisation and interface file requirements |

### `rust`

Skills, agents, and rules for Rust projects.

| Type | Name | Description |
|------|------|-------------|
| Skill | `verify-code` | Lint (`cargo clippy`), test with coverage (`cargo make coverage`), and format (`cargo fmt`) |
| Skill | `analyse-mutations` | Analyse `cargo mutants` output and fix under-tested code paths |
| Agent | `code-reviewer` | Thorough code review covering correctness, safety, style, coverage, and architecture |
| Rule | `clippy` | Documents the only valid reasons to suppress Clippy lints |
| Rule | `modules` | Module organisation conventions |
| Rule | `dependencies` | Dependency management conventions |
| Rule | `style` | Code style conventions |
| Rule | `non-functional` | Non-functional requirements (performance, reliability, etc.) |
