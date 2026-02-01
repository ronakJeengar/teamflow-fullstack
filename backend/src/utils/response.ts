import { Response } from "express";

export const success = (
  res: Response,
  message: string,
  data: any,
  code = 200,
) => {
  return res.status(code).json({
    status: true,
    message,
    data,
  });
};

export const failure = (
  res: Response,
  message: string,
  code = 400,
  error: any = null,
) => {
  return res.status(code).json({
    status: false,
    message,
    error,
  });
};
