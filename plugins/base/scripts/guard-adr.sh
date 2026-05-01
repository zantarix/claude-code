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

# Only guard files inside <project>/docs/adr/
case "$FILE_PATH" in
  "$PROJECT_DIR"/docs/adr/*) ;;
  *) exit 0 ;;
esac

# Allow the adr-architect agent whether invoked as a subagent or directly via --agent
if [ "$AGENT_TYPE" = "base:adr-architect" ]; then
  exit 0
fi

# Otherwise, deny with a structured message Claude can act on
jq -n '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: "Files under docs/adr/ are owned by the base:adr-architect agent. Delegate this change via the Task tool with subagent_type=\"base:adr-architect\", or invoke directly with `claude --agent base:adr-architect` (see rules/base/adr.md)."
  }
}'
exit 0
