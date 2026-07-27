## Project rules versus organisation rules

Project rules are considered to be any rules in `.claude/rules/` which are not included via a symlink. This restriction is important as rules may be included via a symlink as a workaround for Claude Code plugins not including a way to distribute rules. Rules included via a symlink should be categorised as organisation level rules and should be considered immutable.

Project rules are allowed to override or extend organisation rules, however any contradictions should be highlighted to the user.

## Rule length

Rules are sets of short, imperative instructions. Express everything as a clear directive: fold any rationale that shapes how or when the rule applies into the instruction itself, and drop pure motivation. Rule files must not exceed 50 lines. If a rule grows beyond this, split it into multiple focused rules, each covering a distinct concern.

## Rule scope

Rules must be scoped to specific files or directories where possible using the `paths` frontmatter field (accepts glob patterns). Only rules that genuinely apply everywhere — style guides, logging conventions, security requirements — should be left unscoped (repo-wide).
