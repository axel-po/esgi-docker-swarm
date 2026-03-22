import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class AppService {
  private readonly logger = new Logger(AppService.name);

  constructor(private config: ConfigService) {}

  async searchPosts(query: string) {
    const apiUrl = this.config.get('API_URL', 'http://localhost:3001');

    try {
      const response = await fetch(`${apiUrl}/posts`);
      const posts = await response.json();

      // Simple in-memory filter (stub — no real search engine)
      const filtered = Array.isArray(posts)
        ? posts.filter((p: { content?: string }) =>
            p.content?.toLowerCase().includes((query ?? '').toLowerCase()),
          )
        : [];

      this.logger.log(`Search "${query}" → ${filtered.length} results`);
      return { query, results: filtered, total: filtered.length };
    } catch {
      this.logger.warn(`API unreachable at ${apiUrl}`);
      return { query, results: [], total: 0, error: 'api_unavailable' };
    }
  }
}
