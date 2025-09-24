import { registerPlugin } from '@capacitor/core';

import type { HealthPlugin } from './definitions';

const Health = registerPlugin<HealthPlugin>('Health', {
  web: () => import('./web').then((m) => new m.HealthWeb()),
});

export * from './definitions';
export { Health };
