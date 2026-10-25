export type RulesSource = {
  /** The plugin's name, as `$.plugin.name` gives it. */
  plugin: string;
  /** The plugin's directory, as `$.plugin.root` gives it; its `rules/` is read. */
  root: string;
};

/** Delivers the rules of the plugins that depend on the `rules` plugin. */
export type Rules = {
  /** Registers a plugin's `rules/` directory. Call from `session.start`, after `next`. */
  add(source: RulesSource): Promise<void>;
};

declare module 'claude-code' {
  interface EngineInterface {
    rules: Rules;
  }
}
