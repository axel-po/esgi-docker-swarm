import { Controller, Get, Post, Body } from "@nestjs/common";
import { PostsService } from "./posts.service";

@Controller("posts")
export class PostsController {
  constructor(private readonly postsService: PostsService) {}

  @Get()
  async findAll() {
    return this.postsService.findAll();
  }

  @Post()
  async create(@Body() body: { authorId: number; content: string }) {
    return this.postsService.create(body.authorId, body.content);
  }
}
