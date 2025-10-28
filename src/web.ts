import { WebPlugin } from '@capacitor/core';

import type {
  AuthorizationOptions,
  AuthorizationStatus,
  AvailabilityResult,
  HealthPlugin,
  QueryOptions,
  ReadSamplesResult,
  WriteSampleOptions,
} from './definitions';

export class HealthWeb extends WebPlugin implements HealthPlugin {
  async isAvailable(): Promise<AvailabilityResult> {
    return {
      available: false,
      platform: 'web',
      reason: 'Native health APIs are not accessible in a browser environment.',
    };
  }

  async requestAuthorization(_options: AuthorizationOptions): Promise<AuthorizationStatus> {
    throw this.unimplemented('Health permissions are only available on native platforms.');
  }

  async checkAuthorization(_options: AuthorizationOptions): Promise<AuthorizationStatus> {
    throw this.unimplemented('Health permissions are only available on native platforms.');
  }

  async readSamples(_options: QueryOptions): Promise<ReadSamplesResult> {
    throw this.unimplemented('Reading health data is only available on native platforms.');
  }

  async saveSample(_options: WriteSampleOptions): Promise<void> {
    throw this.unimplemented('Writing health data is only available on native platforms.');
  }

  async startObservingHRV(): Promise<void> {
    throw this.unimplemented('Reading health data is only available on native platforms.');
  }
}
