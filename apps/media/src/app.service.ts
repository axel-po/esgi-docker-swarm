import {
  Injectable,
  Logger,
  OnModuleInit,
  OnModuleDestroy,
} from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import amqplib from "amqplib";
import { Client } from "minio";

@Injectable()
export class AppService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(AppService.name);
  private rabbit: Awaited<ReturnType<typeof amqplib.connect>> | null = null;
  private channel: Awaited<
    ReturnType<Awaited<ReturnType<typeof amqplib.connect>>["createChannel"]>
  > | null = null;
  private minioClient: Client;

  constructor(private config: ConfigService) {
    this.minioClient = new Client({
      endPoint: this.config.get("MINIO_ENDPOINT", "localhost"),
      port: parseInt(this.config.get("MINIO_PORT", "9000"), 10),
      useSSL: false,
      accessKey: this.config.get("MINIO_ACCESS_KEY", "minioadmin"),
      secretKey: this.config.get("MINIO_SECRET_KEY", "minioadmin"),
    });
  }

  async onModuleInit() {
    try {
      const url = this.config.get("RABBITMQ_URL", "amqp://localhost:5672");
      this.rabbit = await amqplib.connect(url);
      this.channel = await this.rabbit.createChannel();
      await this.channel.assertQueue("media.uploaded", { durable: true });
      this.logger.log("Connected to RabbitMQ");
    } catch {
      this.logger.warn("RabbitMQ not available, running without queue");
    }

    try {
      const bucket = this.config.get("MINIO_BUCKET", "nebula-media");
      const exists = await this.minioClient.bucketExists(bucket);
      if (!exists) {
        await this.minioClient.makeBucket(bucket);
      }
      this.logger.log("Connected to MinIO");
    } catch {
      this.logger.warn("MinIO not available, running without storage");
    }
  }

  async onModuleDestroy() {
    await this.channel?.close();
    await this.rabbit?.close();
  }

  async handleUpload(filename: string, userId: string) {
    const objectKey = `${userId}/${Date.now()}-${filename}`;
    const bucket = this.config.get("MINIO_BUCKET", "nebula-media");

    try {
      await this.minioClient.putObject(bucket, objectKey, Buffer.from("stub"));
      this.logger.log(`Stored ${objectKey} in MinIO`);
    } catch {
      this.logger.warn("MinIO upload skipped (not available)");
    }

    if (this.channel) {
      this.channel.sendToQueue(
        "media.uploaded",
        Buffer.from(JSON.stringify({ objectKey, userId, filename })),
        { persistent: true },
      );
      this.logger.log("Published media.uploaded event");
    }

    return { objectKey, status: "uploaded" };
  }
}
