#!/usr/bin/env bash

# Read hook input from stdin
INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
PROJECT_DIR=$(echo "$INPUT" | jq -r '.cwd // empty')
AGENT_TYPE=$(echo "$INPUT" | jq -r '.agent_type // empty')
AGENT_ID=$(echo "$INPUT" | jq -r '.agent_id // empty')

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

# Allow only the Task-spawned adr-architect subagent
if [ "$AGENT_TYPE" = "base:adr-architect" ] && [ -n "$AGENT_ID" ]; then
  exit 0
fi

# Otherwise, deny with a structured message Claude can act on
jq -n '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: "Files under docs/adr/ are owned by the adr-architect subagent. Delegate this change via the Task tool with subagent_type=\"adr-architect\" (see rules/base/adr.md)."
  }
}'
exit 0
