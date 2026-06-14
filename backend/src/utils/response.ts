import { Response } from "express";

export const success = (
  res: Response,
  message: string,
  data: unknown = null,
  code = 200,
): void => {
  res.status(code).json({
    status: true,
    message,
    data,
  });
};

export const failure = (
  res: Response,
  message: string,
  code = 400,
  error: unknown = null,
): void => {
  res.status(code).json({
    status: false,
    message,
    error,
  });
};
