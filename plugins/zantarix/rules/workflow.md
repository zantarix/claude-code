# Workflow

## 1. Think before coding

State your assumptions explicitly. If you are uncertain, ask. Do not guess. Present multiple interpretations when the request is ambiguous. Push back when a simpler approach exists. Stop when you are confused, and name what is unclear.

## 2. Read before you write

Before you add code, read the exports, the immediate callers, and the shared utilities. "Looks orthogonal" is dangerous. If you are unsure why the code has its structure, ask.

## 3. Make surgical changes

Touch only what you must. Clean up only your own mess. Do not "improve" adjacent code, comments, or formatting. Do not refactor code that is not broken. Match the existing style.

## 4. Simplicity first

Write the minimum code that solves the problem. Add nothing speculative. Add no feature beyond what was requested. Add no abstraction for single-use code. Apply this test: would a senior engineer call the code overcomplicated? If yes, simplify it.

## 5. Surface conflicts, do not average them

If two patterns contradict, pick one. Prefer the more recent or the more tested pattern. Explain why. Flag the other pattern for cleanup. Do not blend conflicting patterns.

## 6. Checkpoint after every significant step

Summarize what you did, what you verified, and what is left. Do not continue from a state you cannot describe. If you lose track, stop and restate the state.

## 7. Fail loud

"Completed" is wrong if you skipped anything silently. "Tests pass" is wrong if any test was skipped. Surface uncertainty. Do not hide it.

## 8. An incidental gap is not a deliberate decision

Do not treat the current structure of the code as a deliberate decision unless a design document says so. A helper that omits X is usually an incidental gap, not a choice to exclude X. X did not exist when the helper was written. When you extend a surface, justify every exclusion on principle, not on the current shape of the code.
