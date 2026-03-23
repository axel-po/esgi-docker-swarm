import {
  Injectable,
  Logger,
  OnModuleInit,
  OnModuleDestroy,
} from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { readSecret } from "@nebula/shared";
import amqplib from "amqplib";

@Injectable()
export class AppService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(AppService.name);
  private rabbit: Awaited<ReturnType<typeof amqplib.connect>> | null = null;
  private channel: Awaited<
    ReturnType<Awaited<ReturnType<typeof amqplib.connect>>["createChannel"]>
  > | null = null;
  private readonly queues = ["post.created", "media.uploaded"];

  constructor(private config: ConfigService) {}

  async onModuleInit() {
    try {
      const rabbitmqPass = readSecret("rabbitmq_password");
      const url = rabbitmqPass
        ? `amqp://nebula:${rabbitmqPass}@rabbitmq:5672`
        : this.config.get("RABBITMQ_URL", "amqp://localhost:5672");
      this.rabbit = await amqplib.connect(url);
      this.channel = await this.rabbit.createChannel();

      for (const queue of this.queues) {
        await this.channel.assertQueue(queue, { durable: true });
        this.channel.consume(queue, (msg) => {
          if (msg) {
            const payload = JSON.parse(msg.content.toString());
            this.logger.log(`[${queue}] Received: ${JSON.stringify(payload)}`);
            this.channel!.ack(msg);
          }
        });
      }

      this.logger.log(`Consuming queues: ${this.queues.join(", ")}`);
    } catch {
      this.logger.warn("RabbitMQ not available, running without consumer");
    }
  }

  async onModuleDestroy() {
    await this.channel?.close();
    await this.rabbit?.close();
  }

  getQueues(): string[] {
    return this.queues;
  }
}
