import { Request, Response, NextFunction } from "express";

export interface LoggedRequest extends Request {
  id?: string;
  startTime?: number;
}

export const loggerMiddleware = (req: LoggedRequest, res: Response, next: NextFunction) => {
  const reqId = req.headers["x-request-id"] || Math.random().toString(36).substring(2, 11);
  req.id = reqId as string;
  req.startTime = Date.now();

  res.setHeader("x-request-id", reqId);

  res.on("finish", () => {
    const duration = Date.now() - (req.startTime ?? Date.now());
    const log = {
      timestamp: new Date().toISOString(),
      requestId: req.id,
      method: req.method,
      url: req.originalUrl,
      status: res.statusCode,
      duration: `${duration}ms`,
      userAgent: req.headers["user-agent"],
      ip: req.ip || req.socket.remoteAddress,
    };

    if (process.env.NODE_ENV === "production") {
      console.log(JSON.stringify(log));
    } else {
      console.log(`[${log.timestamp}] [${log.requestId}] ${log.method} ${log.url} - ${log.status} in ${log.duration}`);
    }
  });

  next();
};
