/*
 * Pure rule logic: parsing and path matching. No engine access, so it is unit
 * tested directly. Design follows mcmanussliam/claude-plugin-rules (MIT) and
 * Anthropic's mods/agents-md.
 */

/** One rule file shipped by a plugin. */
export type Rule = {
  /** Absolute path of the rule file. */
  path: string;
  /** Rule text without frontmatter. */
  content: string;
  /** Globs from the `paths:` frontmatter; undefined for an always-on rule. */
  paths?: readonly string[];
};

const FRONTMATTER = /^---\r?\n([\s\S]*?)\r?\n---\r?\n?/;

const unquote = (value: string): string => value.trim().replace(/^(["'])(.*)\1$/, '$2');

/** Reads the `paths:` list from frontmatter text: block list, inline list or a bare string. */
function pathsOf(frontmatter: string): string[] | undefined {
  const lines = frontmatter.split(/\r?\n/);
  const start = lines.findIndex(line => /^paths\s*:/.test(line));
  if (start === -1) {
    return undefined;
  }

  const inline = (lines[start] ?? '').replace(/^paths\s*:/, '').trim();
  const globs: string[] = [];
  if (inline !== '') {
    // A comma inside {a,b} belongs to the glob, not the list
    const items = inline.replace(/^\[|\]$/g, '').split(/,(?![^{]*\})/);
    globs.push(...items.map(unquote));
  } else {
    for (const line of lines.slice(start + 1)) {
      const item = /^\s*-\s+(.*)$/.exec(line);
      if (item === null) {
        break;
      }
      globs.push(unquote(item[1] ?? ''));
    }
  }

  const found = globs.filter(glob => glob !== '');
  return found.length > 0 ? found : undefined;
}

/**
 * Parses a rule file. A rule with no `paths:` frontmatter is always on, as in
 * `.claude/rules`.
 */
export function parseRule(path: string, text: string): Rule {
  const match = FRONTMATTER.exec(text);
  const paths = match === null ? undefined : pathsOf(match[1] ?? '');
  const content = (match === null ? text : text.slice(match[0].length)).trim();
  return paths === undefined ? { path, content } : { path, content, paths };
}

/** Compiles a glob to a regular expression over `/`-separated relative paths. */
export function globToRegExp(glob: string): RegExp {
  let source = '';
  let braces = 0;

  for (let i = 0; i < glob.length; i++) {
    const char = glob.charAt(i);
    if (char === '*' && glob.charAt(i + 1) === '*') {
      const isSegment = glob.charAt(i + 2) === '/';
      source += isSegment ? '(?:.*/)?' : '.*';
      i += isSegment ? 2 : 1;
    } else if (char === '*') {
      source += '[^/]*';
    } else if (char === '?') {
      source += '[^/]';
    } else if (char === '{') {
      braces++;
      source += '(?:';
    } else if (char === '}' && braces > 0) {
      braces--;
      source += ')';
    } else if (char === ',' && braces > 0) {
      source += '|';
    } else {
      source += char.replace(/[.+^$()|[\]\\{}]/g, '\\$&');
    }
  }

  // A glob without a slash matches the file name anywhere, as in `.gitignore`
  const anchored = glob.includes('/') ? `^${source}$` : `^(?:.*/)?${source}$`;
  return new RegExp(anchored);
}

/** Whether a project-relative path matches any of the globs. */
export function matchesAny(globs: readonly string[], relPath: string): boolean {
  return globs.some(glob => globToRegExp(glob).test(relPath));
}

/**
 * The path relative to the project root, or undefined for a file outside it
 * (the engine attaches nested rules only inside the project, so do we).
 */
export function relativeTo(root: string, file: string): string | undefined {
  const base = root.replace(/\/+$/, '');
  return file.startsWith(`${base}/`) ? file.slice(base.length + 1) : undefined;
}

/** Frames a rule as the engine frames a nested instruction file. */
export const frame = (rule: Rule): string => `Contents of ${rule.path}:\n\n${rule.content}`;

/**
 * The `paths:` rules that a read of `relPath` should attach and that have not
 * been sent yet.
 */
export function scopedFor(rules: readonly Rule[], relPath: string, sent: ReadonlySet<string>): Rule[] {
  return rules.filter(
    rule => rule.paths !== undefined && !sent.has(rule.path) && matchesAny(rule.paths, relPath),
  );
}

/** Paths of the plugin rules whose content a project's own rule files repeat. */
export function duplicatesOf(rules: readonly Rule[], projectTexts: readonly string[]): string[] {
  const known = new Set(projectTexts.map(text => parseRule('', text).content));
  return rules.filter(rule => known.has(rule.content)).map(rule => rule.path);
}
