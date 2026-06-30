import { Request, Response, NextFunction } from "express";

const WINDOW_MS = 15 * 60 * 1000; // 15 minutes
const MAX_REQUESTS = 500; // max 500 requests per 15 minutes per IP

interface RateLimitInfo {
  count: number;
  resetTime: number;
}

const ipCache = new Map<string, RateLimitInfo>();

export const rateLimiter = (req: Request, res: Response, next: NextFunction) => {
  const ip = req.ip || req.socket.remoteAddress || "unknown";
  const now = Date.now();

  let info = ipCache.get(ip);
  if (!info || now > info.resetTime) {
    info = {
      count: 0,
      resetTime: now + WINDOW_MS,
    };
  }

  info.count += 1;
  ipCache.set(ip, info);

  res.setHeader("X-RateLimit-Limit", MAX_REQUESTS);
  res.setHeader("X-RateLimit-Remaining", Math.max(0, MAX_REQUESTS - info.count));
  res.setHeader("X-RateLimit-Reset", new Date(info.resetTime).toISOString());

  if (info.count > MAX_REQUESTS) {
    return res.status(429).json({
      status: false,
      code: "TOO_MANY_REQUESTS",
      message: "Too many requests from this IP, please try again later.",
    });
  }

  next();
};
