import type { Register } from 'claude-code';

import { rules } from './index';

export const register: Register = on => {
  rules(on);
};
