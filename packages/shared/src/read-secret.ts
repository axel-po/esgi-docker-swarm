import { readFileSync } from "fs";

export function readSecret(name: string, fallback?: string): string {
  try {
    return readFileSync(`/run/secrets/${name}`, "utf-8").trim();
  } catch {
    return fallback ?? "";
  }
}
