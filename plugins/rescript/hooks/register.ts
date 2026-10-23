import type { Register } from 'claude-code';

import { rules } from './rules-loader';

export const register: Register = on => {
  rules(on);
};
