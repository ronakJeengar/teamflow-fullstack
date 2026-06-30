import { Request, Response, NextFunction } from 'express';
import { ZodError } from 'zod';

export const errorHandler = (
  err: any,
  req: any,
  res: Response,
  __: NextFunction
) => {
  const status = err.status || err.statusCode || 500;
  const requestId = req.id || 'N/A';

  const errorLog = {
    timestamp: new Date().toISOString(),
    requestId,
    error: err.name || 'Error',
    message: err.message || String(err),
    stack: err.stack,
  };

  if (process.env.NODE_ENV === "production") {
    console.error(JSON.stringify(errorLog));
  } else {
    console.error(`[${errorLog.timestamp}] [ERR-${requestId}] ${errorLog.message}\n${errorLog.stack || ''}`);
  }

  if (err instanceof ZodError) {
    return res.status(400).json({
      status: false,
      code: 'VALIDATION_ERROR',
      message: 'Validation failed',
      errors: err.issues,
    });
  }

  let code = 'INTERNAL_SERVER_ERROR';
  if (status === 401) code = 'UNAUTHORIZED';
  if (status === 403) code = 'FORBIDDEN';
  if (status === 404) code = 'NOT_FOUND';
  
  if (status === 409 || err.code === 'P2002') {
    return res.status(409).json({
      status: false,
      code: 'CONFLICT',
      message: err.message || 'A data conflict occurred (e.g. unique constraint violation)',
    });
  }

  res.status(status).json({
    status: false,
    code,
    message: err.message || 'An unexpected server error occurred',
  });
};
