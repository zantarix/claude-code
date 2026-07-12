export const meta = {
	name: 'review-fanout',
	description: 'Fan every discovered reviewer over a diff: propose remit-aware partitions, then review each slice and render the consolidated report',
	phases: [
		{ title: 'Propose', detail: 'each reviewer proposes how it would partition the changes for its own remit' },
		{ title: 'Review', detail: 'fan each reviewer out over its chunks and collate findings' },
	],
}

// This script is generic over whatever reviewer set the skill discovers — it hardcodes no
// reviewer names. It is invoked in one of three modes via `input.mode`:
//
//   - 'propose'  → run one agent per reviewer that returns a partition proposal (WF1). The skill
//                  reads the proposals, applies the cost gate, and re-invokes in 'review' mode.
//   - 'review'   → given a (possibly trimmed) reviewer→chunks work-list, review each (reviewer,
//                  chunk) pair and return the rendered report + audit files (WF2).
//   - 'full'     → small-scope path: review the whole scope once per reviewer, render, return.
//
// The script never touches the filesystem (workflows can't). It returns rendered markdown strings
// and the caller (the skill's main loop) writes them under the session folder it created.
//
// `args` may arrive already parsed, or as a JSON string (tool/model serialisation varies).
// Normalise once, up front, and read everything from `input`.
const input = typeof args === 'string' ? JSON.parse(args) : args

const SEVERITIES = ['critical', 'major', 'minor']

const PARTITION_SCHEMA = {
	type: 'object',
	additionalProperties: false,
	properties: {
		chunks: {
			type: 'array',
			description: 'Cohesive chunks of changed files within this reviewer\'s remit; empty if none apply.',
			items: {
				type: 'object',
				additionalProperties: false,
				properties: {
					id: { type: 'string', description: 'Short kebab-case chunk id, e.g. auth-core.' },
					files: { type: 'array', items: { type: 'string' }, description: 'Changed files in this chunk.' },
					isCross: { type: 'boolean', description: 'True for a cross-boundary chunk (consistency across this reviewer\'s chunks) rather than a per-file chunk.' },
				},
				required: ['id', 'files', 'isCross'],
			},
		},
	},
	required: ['chunks'],
}

const FINDINGS_SCHEMA = {
	type: 'object',
	additionalProperties: false,
	properties: {
		findings: {
			type: 'array',
			description: 'Findings within this reviewer\'s remit for the assigned files; empty when nothing needs attention.',
			items: {
				type: 'object',
				additionalProperties: false,
				properties: {
					severity: { type: 'string', enum: SEVERITIES },
					finding: { type: 'string', description: 'The issue, stated so it can fail when the code changes.' },
					location: { type: 'string', description: 'file:line the finding anchors to.' },
				},
				required: ['severity', 'finding', 'location'],
			},
		},
		noIssues: {
			type: 'string',
			description: 'Components confirmed clean within scope, or "None". Set even when findings is empty — an empty findings list plus this field is an explicit clean result.',
		},
	},
	required: ['findings', 'noIssues'],
}

// Filesystem-safe path segment for a reviewer identifier (e.g. "rust:code-reviewer" → "rust-code-reviewer").
function safeName(id) {
	return id.replace(/[^A-Za-z0-9._-]/g, '-')
}

function counts(findings) {
	const c = { critical: 0, major: 0, minor: 0 }
	for (const f of findings) if (c[f.severity] !== undefined) c[f.severity]++
	return c
}

// A dead/skipped agent returns null; distinguish that from an explicit clean result.
function normalize(res) {
	if (!res) return null
	return {
		findings: Array.isArray(res.findings) ? res.findings : [],
		noIssues: (res.noIssues && String(res.noIssues).trim()) || 'None',
	}
}

function proposePrompt(reviewer, scope) {
	return `You are being run as the "${reviewer}" reviewer to plan a review, not perform it.

Read the full set of changes in scope: ${scope}.

Group ONLY the changed files that fall within YOUR review remit into cohesive chunks, each reviewable in one focused pass. Rules:
- Keep each feature's code, its tests, and the artifacts they depend on in the same chunk. Never split a subsystem into an implementation chunk and a separate tests chunk.
- Default to grouping at the module / subsystem / directory level; do not over-fragment into per-file chunks, and do not create chunks smaller than they need to be.
- You MAY add at most one chunk with isCross=true covering your cross-boundary surface — signature/contract consistency across call sites, rename completeness, coherence across modules within your remit.
- If none of the changes fall within your remit, return an empty chunks list.

Return your partition proposal via the structured-output schema. Do not review the code yet.`
}

function reviewPrompt(reviewer, chunk, scope) {
	const cross = chunk.isCross
		? `This is a CROSS-BOUNDARY chunk. Skip per-file depth. Inspect only issues that span these files: signature/contract consistency across call sites, rename completeness, and coherence across modules within your remit.`
		: `Review these files in depth for issues within your remit.`
	return `You are the "${reviewer}" reviewer. Scope context: ${scope}.

${cross}

Review EXACTLY these changed files and report ONLY on them — do not assert anything (clean or otherwise) about files outside this set:
${chunk.files.map((f) => `- ${f}`).join('\n')}

If nothing within your remit needs attention here, return an empty findings list and set noIssues to what you confirmed clean (or "None"). Group findings by severity and return them via the structured-output schema.`
}

function fullPrompt(reviewer, scope) {
	return `You are the "${reviewer}" reviewer. Review the full set of changes in scope: ${scope}.

Do both deep per-file analysis and cross-boundary checks (signature/contract consistency, rename completeness, coherence across modules) within your remit. Report ONLY on matters in your remit; if the scope contains nothing in your remit, return an empty findings list.

If nothing needs attention, set noIssues to what you confirmed clean (or "None"). Group findings by severity and return them via the structured-output schema.`
}

function renderAudit(reviewer, chunkId, scope, res) {
	const section = (sev, heading) => {
		const items = res.findings.filter((f) => f.severity === sev)
		const body = items.length ? items.map((f) => `- [ ] ${f.finding} — ${f.location}`).join('\n') : ''
		return `## ${heading}\n${body}`
	}
	return `# ${reviewer} Report
**Chunk**: ${chunkId}
**Scope**: ${scope}

${section('critical', 'Critical')}

${section('major', 'Major')}

${section('minor', 'Minor / Suggestions')}

## No Issues
${res.noIssues}
`
}

function renderReviewMd(session, reviewed, flat) {
	const total = { critical: 0, major: 0, minor: 0 }
	const rows = reviewed.map((r) => {
		const c = counts(r.result.findings)
		total.critical += c.critical
		total.major += c.major
		total.minor += c.minor
		return `| ${r.reviewer} | ${r.chunk} | ${c.critical} | ${c.major} | ${c.minor} |`
	})
	const section = (sev, heading) => {
		const items = flat.filter((f) => f.severity === sev)
		const body = items.length
			? items.map((f) => `- [ ] ${f.finding} — ${f.location} (chunk ${f.chunk})`).join('\n')
			: 'None'
		return `### ${heading}\n\n${body}`
	}
	return `# Consolidated Review

**Session**: \`${session}\`

## Summary Table

| Reviewer | Chunk | Critical | Major | Minor |
|----------|-------|----------|-------|-------|
${rows.join('\n')}
| **Total** | — | ${total.critical} | ${total.major} | ${total.minor} |

## Needs Human Input

None

## Other findings

${section('critical', 'Critical')}

${section('major', 'Major')}

${section('minor', 'Minor / Suggestions')}
`
}

// reviewed: [{ reviewer, chunk, result }] with result already normalized (non-null).
// failed:   [{ reviewer, chunk }] for pairs whose agent returned null.
function buildOutputs(session, scope, reviewed, failed) {
	const auditFiles = reviewed.map((r) => ({
		path: `${session}${safeName(r.reviewer)}/${r.chunk}.md`,
		content: renderAudit(r.reviewer, r.chunk, scope, r.result),
	}))
	const findings = reviewed.flatMap((r) =>
		r.result.findings.map((f) => ({ ...f, reviewer: r.reviewer, chunk: r.chunk })),
	)
	return {
		reviewMd: renderReviewMd(session, reviewed, findings),
		auditFiles,
		findings,
		failed,
	}
}

async function runReview(pairs) {
	// pairs: [{ reviewer, chunk: {id, files, isCross} }] — flattened so all pairs share the concurrency pool.
	const results = await parallel(
		pairs.map((p) => () => {
			// A chunk without a `files` list is the synthetic whole-scope chunk (small-scope 'full' mode);
			// reviewPrompt handles the per-chunk and cross-boundary cases.
			const prompt = p.chunk.files
				? reviewPrompt(p.reviewer, p.chunk, input.scope)
				: fullPrompt(p.reviewer, input.scope)
			return agent(prompt, {
				agentType: p.reviewer,
				label: `review:${safeName(p.reviewer)}:${p.chunk.id}`,
				phase: 'Review',
				schema: FINDINGS_SCHEMA,
			}).then((res) => ({ reviewer: p.reviewer, chunk: p.chunk.id, result: normalize(res) }))
		}),
	)
	const reviewed = results.filter((r) => r && r.result)
	const failed = results
		.map((r, i) => (r && r.result ? null : { reviewer: pairs[i].reviewer, chunk: pairs[i].chunk.id }))
		.filter(Boolean)
	return buildOutputs(input.session, input.scope, reviewed, failed)
}

// ---- entry point ----
// A top-level early `return` inside a branch does NOT halt the workflow runtime (unlike a normal
// function), so the modes must be mutually exclusive branches feeding a single final `return`.

let output

if (input.mode === 'propose') {
	phase('Propose')
	const proposals = await parallel(
		input.reviewers.map((r) => () =>
			agent(proposePrompt(r, input.scope), {
				agentType: r,
				label: `propose:${safeName(r)}`,
				phase: 'Propose',
				schema: PARTITION_SCHEMA,
			}).then((res) => ({
				reviewer: r,
				// A dead/skipped propose agent (res === null) yields no chunks — indistinguishable from an
				// empty remit unless flagged. Surface it so the skill can fail loud rather than silently
				// dropping a reviewer from coverage.
				alive: !!res,
				chunks: res && Array.isArray(res.chunks) ? res.chunks : [],
			})),
		),
	)
	output = { proposals: proposals.filter(Boolean) }
} else if (input.mode === 'full') {
	phase('Review')
	// One whole-scope pass per reviewer; a chunk without `files` signals the full-scope prompt.
	const pairs = input.reviewers.map((r) => ({ reviewer: r, chunk: { id: 'full', files: null, isCross: false } }))
	output = await runReview(pairs)
} else {
	// input.mode === 'review'
	phase('Review')
	const pairs = input.worklist.flatMap((entry) =>
		entry.chunks.map((chunk) => ({ reviewer: entry.reviewer, chunk })),
	)
	output = await runReview(pairs)
}

return output
