# zantarix/claude-code

Claude Code plugins for Zantarix projects.

## Plugins

### `base`

General-purpose skills and rules for all Zantarix projects.

| Type | Name | Description |
|------|------|-------------|
| Skill | `commit` | Verify and commit staged/unstaged changes with a well-crafted Conventional Commit message |
| Agent | `adr-architect` | Create and maintain Architecture Decision Records in `docs/adr/` |
| Rule | `adr` | Instructs Claude to delegate ADR changes to the `adr-architect` agent |

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

## Usage

Add this marketplace to your project's Claude Code configuration to pull in the plugins you need.
