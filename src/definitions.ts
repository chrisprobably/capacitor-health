export interface HealthPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
