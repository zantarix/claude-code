#!/usr/bin/env bash

# Read hook input from stdin
INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
PROJECT_DIR=$(echo "$INPUT" | jq -r '.cwd // empty')
AGENT_TYPE=$(echo "$INPUT" | jq -r '.agent_type // empty')

# Only care about write-capable tools
case "$TOOL_NAME" in
  Edit|Write|MultiEdit) ;;
  *) exit 0 ;;
esac

# Need both a file path and a project root to evaluate scope
if [ -z "$FILE_PATH" ] || [ -z "$PROJECT_DIR" ]; then
  exit 0
fi

# Only guard files inside <project>/docs/adr/ or <project>/docs/architecture/
case "$FILE_PATH" in
  "$PROJECT_DIR"/docs/adr/*) ;;
  "$PROJECT_DIR"/docs/architecture/*) ;;
  *) exit 0 ;;
esac

# Allow the architecture-curator agent whether invoked as a subagent or directly via --agent.
# The legacy adr-architect identity is a transitional allowance for sessions that started
# before the architecture-curator rename; remove once no consumer pins the old agent name.
case "$AGENT_TYPE" in
  zantarix:architecture-curator|zantarix:adr-architect) exit 0 ;;
esac

# Otherwise, deny with a structured message Claude can act on
jq -n '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: "Files under docs/adr/ and docs/architecture/ are owned by the zantarix:architecture-curator agent. Delegate this change via the Task tool with subagent_type=\"zantarix:architecture-curator\", or invoke directly with `claude --agent zantarix:architecture-curator` (see rules/zantarix/adr.md)."
  }
}'
exit 0
