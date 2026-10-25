import type { Register } from 'claude-code';

export const register: Register = on => {
  on('session.start', {}, async ($, e, next) => {
    const started = await next(e);
    // Swallowed here: the .catch below would call next(e) a second time
    await $.rules.add({ plugin: $.plugin.name, root: $.plugin.root }).catch(() => undefined);
    return started;
  }).catch(($, e, next) => next(e));
};
