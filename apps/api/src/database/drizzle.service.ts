import { Inject, Injectable, OnModuleDestroy } from "@nestjs/common";
import { drizzle, PostgresJsDatabase } from "drizzle-orm/postgres-js";
import postgres from "postgres";
import {
  ConfigurableDatabaseModule,
  DATABASE_OPTIONS,
  DatabaseOptions,
} from "./database.module-definition";
import { databaseSchema } from "./schema";

export type DrizzleDb = PostgresJsDatabase<typeof databaseSchema>;

@Injectable()
export class DrizzleService implements OnModuleDestroy {
  private client: ReturnType<typeof postgres>;
  public db: DrizzleDb;

  constructor(
    @Inject(DATABASE_OPTIONS) private readonly options: DatabaseOptions,
  ) {
    this.client = postgres(options.url, {
      ssl: options.ssl ? "require" : false,
      max: 10,
    });
    this.db = drizzle(this.client, { schema: databaseSchema });
  }

  async onModuleDestroy() {
    await this.client.end();
  }
}

export { ConfigurableDatabaseModule };
