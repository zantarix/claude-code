---
name: review
description: |-
  Run all *-reviewer agents concurrently, fix critical/major issues, and report results.

  Proactively use this agent to review code you've created if you have added or modified more than two functions, or
  whenever you complete an implementation plan.
---

Review the current changes by running all available reviewer agents concurrently, then address any critical or major issues they find.

## Step 1: Discover reviewers

Find all available `*-reviewer` agents. Each one is a reviewer agent to launch.

## Step 2: Launch all reviewers concurrently

Launch every discovered reviewer agent **in parallel** using the Agent tool. Pass each agent a prompt describing the scope of the review (e.g., uncommitted changes, recent commits on the branch, or a user-specified scope).

## Step 3: Triage findings

Collect the results from all agents. Classify each finding by urgency:

| Agent | Critical | Major |
|-------|----------|-------|
| `code-reviewer` | 🔴 Critical Issues | 🟠 Major Issues |
| `documentation-reviewer` | All "Documentation Updates Needed" items | — |

Any other `*-reviewer` agents discovered in Step 1 should have their output scanned for similar severity indicators (e.g. "Critical", "Error", "Must fix", "Required") and triaged accordingly using your best judgement.

## Step 4: Fix critical and major issues

Automatically fix all critical and major issues identified in Step 3. For each fix:

- Make the code or documentation change directly.
- If a fix is ambiguous or risky (e.g., an architectural concern, a decision that needs user input), **skip it** and flag it in the report instead.

Do NOT fix minor issues, suggestions, or cosmetic nits — leave those for the user to decide on.

## Step 5: Report to the user

Present a consolidated report:

```
## Review Results

### Reviewers Run
- <agent name>: <one-line verdict or summary>
- ...

### Issues Fixed
<numbered list of fixes applied, with file paths and brief descriptions>

### Issues Requiring Attention
<numbered list of issues that were not auto-fixed, with the agent that raised them and why they need human input>

### Minor / Suggestions (not actioned)
<brief list or count of lower-priority items from each agent, so the user knows they exist>
```

Keep the report concise but complete. All findings should have an entry in one of the three sections above. The user can re-run individual reviewer agents if they want full details.
