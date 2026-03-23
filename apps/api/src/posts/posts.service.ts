import {
  Injectable,
  Logger,
  OnModuleInit,
  OnModuleDestroy,
} from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { readSecret } from "@nebula/shared";
import { DrizzleService } from "../database/drizzle.service";
import { posts } from "../database/schema";
import amqplib from "amqplib";

@Injectable()
export class PostsService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(PostsService.name);
  private rabbit: Awaited<ReturnType<typeof amqplib.connect>> | null = null;
  private channel: Awaited<
    ReturnType<Awaited<ReturnType<typeof amqplib.connect>>["createChannel"]>
  > | null = null;

  constructor(
    private readonly drizzle: DrizzleService,
    private readonly config: ConfigService,
  ) {}

  async onModuleInit() {
    try {
      const rabbitmqPass = readSecret("rabbitmq_password");
      const url = rabbitmqPass
        ? `amqp://nebula:${rabbitmqPass}@rabbitmq:5672`
        : this.config.get("RABBITMQ_URL", "amqp://localhost:5672");
      this.rabbit = await amqplib.connect(url);
      this.channel = await this.rabbit.createChannel();
      await this.channel.assertQueue("post.created", { durable: true });
      this.logger.log("Connected to RabbitMQ");
    } catch {
      this.logger.warn("RabbitMQ not available, running without queue");
    }
  }

  async onModuleDestroy() {
    await this.channel?.close();
    await this.rabbit?.close();
  }

  async findAll() {
    return this.drizzle.db.select().from(posts);
  }

  async create(authorId: number, content: string) {
    const [newPost] = await this.drizzle.db
      .insert(posts)
      .values({ authorId, content })
      .returning();

    if (this.channel) {
      this.channel.sendToQueue(
        "post.created",
        Buffer.from(JSON.stringify({ postId: newPost.id, authorId, content })),
        { persistent: true },
      );
      this.logger.log(`Published post.created event for post ${newPost.id}`);
    }

    return newPost;
  }
}
