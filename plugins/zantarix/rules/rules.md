# Project rules versus organisation rules

Project rules are the files in `.claude/rules/`. Organisation rules are the files in a plugin's own `rules/` directory. Their paths are under the plugin's install directory. Organisation rules are immutable. Do not edit them.

A project rule can override or extend an organisation rule. Tell the user about any contradiction.

## Rule length

Write rules as short, imperative instructions. State every instruction as a clear directive. Put any rationale that changes how or when the rule applies into the instruction itself. Remove pure motivation. A rule file must not be longer than 50 lines. If a rule grows past 50 lines, split it into several focused rules. Each rule covers one concern.

## Rule scope

Scope each rule to specific files or directories with the `paths` frontmatter field when possible. The field accepts glob patterns. Leave a rule unscoped (repo-wide) only when it applies everywhere. Examples are style guides, logging conventions, and security requirements.
