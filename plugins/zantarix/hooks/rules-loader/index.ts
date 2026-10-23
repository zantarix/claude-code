/*
 * Loads a plugin's own `rules/` directory: Claude Code has no rules component
 * for plugins (anthropics/claude-code#14200), so each plugin does it with a
 * hooks module. Design follows mcmanussliam/claude-plugin-rules (MIT) and
 * Anthropic's mods/agents-md.
 *
 * Canonical copy: plugins/zantarix/hooks/rules-loader/. The other plugins carry
 * byte-identical copies made by scripts/sync-rules-loader.sh.
 *
 * Rules never gate anything: every hook passes its event on if it fails.
 */
import type { EngineInterface, InstructionFile, On } from 'claude-code';

import { duplicatesOf, frame, parseRule, relativeTo, scopedFor, type Rule } from './rule';

/** Deepest rules directory nesting walked; also guards against symlink loops. */
const MAX_DEPTH = 6;

/** Rules read from disk, until the next session start. */
let cache: Promise<Rule[]> | undefined;
/** Whether the engine asked `prompt.context` this session, i.e. rules reach it natively. */
let hasContextRun = false;
/** Whether a turn finished without `prompt.context` having run. */
let isBypassed = false;
/** Path rules already attached, by agent loop. */
const sent = new Map<string, Set<string>>();
/** Agent loops that have been given the always-on rules by fallback. */
const told = new Set<string>();

const keyOf = (agentId: string | undefined): string => agentId ?? 'main';

/** Every `.md` file under `dir`, following symlinked directories. */
async function walk($: EngineInterface, dir: string, depth = 0): Promise<string[]> {
  if (depth > MAX_DEPTH || !(await $.fs.exists(dir))) {
    return [];
  }

  const found: string[] = [];
  for (const entry of await $.fs.list(dir)) {
    const path = `${dir}/${entry.name}`;
    const kind = entry.isLink === true ? (await $.fs.stat(path).catch(() => undefined))?.kind : entry.kind;
    if (kind === 'dir') {
      found.push(...(await walk($, path, depth + 1)));
    } else if (kind === 'file' && entry.name.endsWith('.md')) {
      found.push(path);
    }
  }
  return found.sort();
}

async function readRules($: EngineInterface): Promise<Rule[]> {
  const files = await walk($, `${$.plugin.root}/rules`);
  const texts = await Promise.all(files.map(file => $.fs.read(file)));
  return files.map((file, i) => parseRule(file, texts[i] ?? '')).filter(rule => rule.content !== '');
}

function rulesOf($: EngineInterface): Promise<Rule[]> {
  cache ??= readRules($).catch(error => {
    cache = undefined;
    throw error;
  });
  return cache;
}

/** Adds rules as `user` instruction files: after the person's own, before the project's. */
function withUserFiles(files: readonly InstructionFile[], rules: readonly Rule[]): InstructionFile[] {
  const added = rules.map((rule): InstructionFile => ({ path: rule.path, kind: 'user', content: rule.content }));
  const lastUser = files.findLastIndex(file => file.kind === 'user');
  const firstLater = files.findIndex(file => file.kind !== 'managed' && file.kind !== 'user');
  const at = lastUser !== -1 ? lastUser + 1 : firstLater !== -1 ? firstLater : files.length;
  return [...files.slice(0, at), ...added, ...files.slice(at)];
}

/** The path rules a read of `file` attaches that this loop has not had, marked as sent. */
async function attachFor($: EngineInterface, file: string, agentId: string | undefined): Promise<string[]> {
  const relPath = relativeTo(await $.session.root(), file);
  if (relPath === undefined) {
    return [];
  }

  const key = keyOf(agentId);
  const done = sent.get(key) ?? new Set<string>();
  const fresh = scopedFor(await rulesOf($), relPath, done);
  sent.set(key, new Set([...done, ...fresh.map(rule => rule.path)]));
  return fresh.map(frame);
}

/**
 * Always-on rules for a loop, only where `prompt.context` cannot carry them
 * (Team/Enterprise or managed settings skip it for user-installed plugins).
 */
async function fallbackFor($: EngineInterface, agentId: string | undefined): Promise<string[]> {
  const key = keyOf(agentId);
  if (!isBypassed || told.has(key)) {
    return [];
  }

  told.add(key);
  return (await rulesOf($)).filter(rule => rule.paths === undefined).map(frame);
}

/** Tells the person when `.claude/rules` still holds copies of this plugin's rules. */
async function warnDuplicates($: EngineInterface): Promise<void> {
  const root = await $.session.root();
  const files = await walk($, `${root}/.claude/rules`);
  if (files.length === 0) {
    return;
  }

  const texts = await Promise.all(files.map(file => $.fs.read(file).catch(() => '')));
  const copies = duplicatesOf(await rulesOf($), texts);
  if (copies.length > 0) {
    $.ui.log(
      `${$.plugin.name}: ${copies.length} of this plugin's rules are also in .claude/rules (the old ` +
        `symlink/submodule route). Remove those symlinks and the .claude/shared submodule: the plugin loads its ` +
        'rules itself, so each is currently sent twice.',
    );
  }
}

async function listing($: EngineInterface): Promise<string> {
  const rules = await rulesOf($);
  const mode = hasContextRun ? 'instructions' : isBypassed ? 'fallback (prompt.context skipped)' : 'not yet confirmed';
  const lines = rules.map(rule => `- ${rule.path.replace(`${$.plugin.root}/`, '')}${rule.paths ? ` [${rule.paths.join(', ')}]` : ''}`);
  return `${$.plugin.name}: ${rules.length} rules, always-on delivery: ${mode}\n${lines.join('\n')}`;
}

/** Hooks this plugin's `rules/` directory into the session. Call once from `register`. */
export function rules(on: On): void {
  on('session.start', {}, async ($, e, next) => {
    const started = await next(e);
    cache = undefined;
    await $.command.register({ name: `${$.plugin.name}-rules`, description: `List the rules the ${$.plugin.name} plugin loads` });
    await warnDuplicates($).catch(() => undefined);
    return started;
  }).catch(($, e, next) => next(e));

  on('command.run', {}, async ($, e, next) =>
    e.command === `${$.plugin.name}-rules` ? { text: await listing($) } : next(e),
  ).catch(($, e, next) => next(e));

  on('session.end', { reason: 'clear' }, ($, e, next) => {
    sent.clear();
    told.clear();
    isBypassed = false;
    hasContextRun = false;
    return next(e);
  }).catch(($, e, next) => next(e));

  on('session.compact', {}, async ($, e, next) => {
    const result = await next(e);
    sent.delete(keyOf(e.agentId));
    told.delete(keyOf(e.agentId));
    return result;
  }).catch(($, e, next) => next(e));

  on('prompt.context', {}, async ($, e, next) => {
    // A hook above rewrote the instructions' text: files added now would be lost
    if (e.instructionFiles === undefined) {
      return next(e);
    }

    const present = new Set(e.instructionFiles.map(file => file.path));
    const always = (await rulesOf($)).filter(rule => rule.paths === undefined && !present.has(rule.path));
    hasContextRun = true;
    return next({ ...e, instructionFiles: withUserFiles(e.instructionFiles, always) });
  }).catch(($, e, next) => next(e));

  // A turn that ended without the instructions having been asked for: they
  // are out of reach here, so rules ride the prompt and tool results instead
  on('turn.complete', {}, (_$, e, next) => {
    isBypassed = !hasContextRun;
    return next(e);
  }).catch(($, e, next) => next(e));

  on('prompt.submit', {}, async ($, e, next) => {
    const fresh = await fallbackFor($, undefined);
    return next(fresh.length > 0 ? { ...e, context: [...(e.context ?? []), ...fresh] } : e);
  }).catch(($, e, next) => next(e));

  on('prompt.mention', {}, async ($, e, next) => {
    const result = await next(e);
    if (result.deny !== undefined || result.type === null) {
      return result;
    }

    const fresh = await attachFor($, e.path, e.agentId);
    return fresh.length > 0 ? { ...result, context: [...(result.context ?? []), ...fresh] } : result;
  }).catch(($, e, next) => next(e));

  on('agent.spawn', { fork: true }, async ($, e, next) => {
    const result = await next(e);
    // A fork carries its parent's conversation, and the rules in it
    if (e.resume === undefined && result.agentId !== undefined) {
      sent.set(keyOf(result.agentId), new Set(sent.get(keyOf(e.parentAgentId)) ?? []));
      if (told.has(keyOf(e.parentAgentId))) {
        told.add(keyOf(result.agentId));
      }
    }
    return result;
  }).catch(($, e, next) => next(e));

  on('tool.call', {}, async ($, e, next) => {
    const result = await next(e);
    if (result.deny !== undefined || result.isError) {
      return result;
    }

    const scoped = e.tool === 'Read' && typeof e.file_path === 'string' ? await attachFor($, e.file_path, e.agentId) : [];
    const fresh = [...(await fallbackFor($, e.agentId)), ...scoped];
    return fresh.length > 0 ? { ...result, context: [...(result.context ?? []), ...fresh] } : result;
  }).catch(($, e, next) => next(e));
}
