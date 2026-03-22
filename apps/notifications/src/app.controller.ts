import { Controller, Get } from "@nestjs/common";
import { AppService } from "./app.service";

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get("health")
  getHealth() {
    return {
      status: "ok",
      service: "notifications",
      version: process.env.VERSION ?? "1.0.0",
      timestamp: new Date().toISOString(),
      queuesListening: this.appService.getQueues(),
    };
  }
}
