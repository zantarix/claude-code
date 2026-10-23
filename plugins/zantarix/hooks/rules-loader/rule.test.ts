import { describe, expect, test } from 'claude-code/testing';

import { duplicatesOf, frame, matchesAny, parseRule, relativeTo, scopedFor } from './rule';

describe('parseRule', () => {
  test('a rule without frontmatter is always on, so repo-wide rules reach every session', () => {
    const rule = parseRule('/p/rules/a.md', '# Title\n\nBody\n');
    expect(rule.paths).toBeUndefined();
    expect(rule.content).toBe('# Title\n\nBody');
  });

  test('a block-list paths: scopes the rule and is stripped from the content', () => {
    const rule = parseRule('/p/a.md', '---\npaths:\n  - "**/*.rs"\n  - docs/**\n---\nBody');
    expect(rule.paths).toEqual(['**/*.rs', 'docs/**']);
    expect(rule.content).toBe('Body');
  });

  test('an inline paths: keeps commas inside braces as part of the glob', () => {
    const rule = parseRule('/p/a.md', '---\npaths: ["src/**/*.{res,resi}", "*.md"]\n---\nBody');
    expect(rule.paths).toEqual(['src/**/*.{res,resi}', '*.md']);
  });

  test('frontmatter without paths: stays always-on, so a description-only header cannot hide a rule', () => {
    const rule = parseRule('/p/a.md', '---\ndescription: x\n---\nBody');
    expect(rule.paths).toBeUndefined();
    expect(rule.content).toBe('Body');
  });
});

describe('matchesAny', () => {
  test('**/*.rs matches Rust files at any depth, including the root', () => {
    expect(matchesAny(['**/*.rs'], 'src/lib.rs')).toBe(true);
    expect(matchesAny(['**/*.rs'], 'lib.rs')).toBe(true);
    expect(matchesAny(['**/*.rs'], 'src/lib.rs.bak')).toBe(false);
  });

  test('a trailing ** covers a whole directory, as docs/adr/** guards ADRs', () => {
    expect(matchesAny(['docs/adr/**'], 'docs/adr/0001-x.md')).toBe(true);
    expect(matchesAny(['docs/adr/**'], 'docs/other/0001-x.md')).toBe(false);
  });

  test('a slash-less glob matches the file name anywhere, like .gitignore', () => {
    expect(matchesAny(['Cargo.toml'], 'crates/a/Cargo.toml')).toBe(true);
  });

  test('a rooted pattern with a dot directory is not a wildcard', () => {
    expect(matchesAny(['.cargo/mutants.toml'], '.cargo/mutants.toml')).toBe(true);
    expect(matchesAny(['.cargo/mutants.toml'], 'xcargo/mutantsxtoml')).toBe(false);
  });

  test('braces alternate: src/**/*.{res,resi}', () => {
    expect(matchesAny(['src/**/*.{res,resi}'], 'src/a/b.resi')).toBe(true);
    expect(matchesAny(['src/**/*.{res,resi}'], 'src/a/b.js')).toBe(false);
  });
});

describe('relativeTo', () => {
  test('files outside the project root get no path rules', () => {
    expect(relativeTo('/proj', '/proj/src/a.rs')).toBe('src/a.rs');
    expect(relativeTo('/proj', '/proj-other/a.rs')).toBeUndefined();
    expect(relativeTo('/proj', '/etc/hosts')).toBeUndefined();
  });
});

describe('scopedFor', () => {
  const rust = parseRule('/p/rust.md', '---\npaths:\n  - "**/*.rs"\n---\nRust');
  const always = parseRule('/p/always.md', 'Always');

  test('only matching scoped rules attach, never always-on ones (those load via instructions)', () => {
    expect(scopedFor([rust, always], 'a.rs', new Set()).map(r => r.path)).toEqual(['/p/rust.md']);
    expect(scopedFor([rust, always], 'a.md', new Set())).toEqual([]);
  });

  test('a rule already sent to the loop is not attached twice, keeping context small', () => {
    expect(scopedFor([rust], 'a.rs', new Set(['/p/rust.md']))).toEqual([]);
  });
});

describe('duplicatesOf', () => {
  test('a project file repeating a plugin rule is flagged even through a different frontmatter', () => {
    const rule = parseRule('/plugin/rules/a.md', 'Same body');
    expect(duplicatesOf([rule], ['---\npaths:\n  - x\n---\nSame body\n'])).toEqual(['/plugin/rules/a.md']);
    expect(duplicatesOf([rule], ['Different'])).toEqual([]);
  });
});

describe('frame', () => {
  test('names the source file so the model can tell plugin rules from project ones', () => {
    expect(frame(parseRule('/p/a.md', 'Body'))).toBe('Contents of /p/a.md:\n\nBody');
  });
});
