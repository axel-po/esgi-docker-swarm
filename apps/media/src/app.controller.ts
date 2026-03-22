import { Controller, Get, Post, Body } from "@nestjs/common";
import { AppService } from "./app.service";

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get("health")
  getHealth() {
    return {
      status: "ok",
      service: "media",
      version: process.env.VERSION ?? "1.0.0",
      timestamp: new Date().toISOString(),
    };
  }

  @Post("upload")
  async upload(@Body() body: { filename: string; userId: string }) {
    return this.appService.handleUpload(body.filename, body.userId);
  }
}
