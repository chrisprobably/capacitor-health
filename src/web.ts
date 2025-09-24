import { WebPlugin } from '@capacitor/core';

import type { HealthPlugin } from './definitions';

export class HealthWeb extends WebPlugin implements HealthPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
