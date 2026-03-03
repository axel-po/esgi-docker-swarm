// Shared types between web and api

export interface User {
  id: string;
  email: string;
  username: string;
  createdAt: string;
}

export interface Post {
  id: string;
  authorId: string;
  content: string;
  mediaUrl?: string;
  createdAt: string;
}

export interface ApiResponse<T> {
  data?: T;
  error?: string;
  status: number;
}

export interface HealthResponse {
  status: "ok" | "error";
  service: string;
  version: string;
  timestamp: string;
}
