import { Controller, Get, Query } from '@nestjs/common';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get('health')
  getHealth() {
    return {
      status: 'ok',
      service: 'search',
      version: process.env.VERSION ?? '1.0.0',
      timestamp: new Date().toISOString(),
    };
  }

  @Get('search')
  async search(@Query('q') query: string) {
    return this.appService.searchPosts(query);
  }
}
