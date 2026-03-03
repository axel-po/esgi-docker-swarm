import { Global, Module } from '@nestjs/common';
import { DrizzleService, ConfigurableDatabaseModule } from './drizzle.service';

@Global()
@Module({
  providers: [DrizzleService],
  exports: [DrizzleService],
})
export class DatabaseModule extends ConfigurableDatabaseModule {}
