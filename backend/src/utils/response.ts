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

export const successResponse = (res: Response, data: any, message = 'Success', statusCode = 200) => {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
  })
}

export const errorResponse = (res: Response, message: string, statusCode = 400, errors?: any) => {
  return res.status(statusCode).json({
    success: false,
    message,
    errors: errors || null,
  })
}

export const paginatedResponse = (res: Response, data: any[], total: number, page: number, limit: number) => {
  return res.status(200).json({
    success: true,
    data,
    pagination: {
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
      hasMore: page * limit < total,
    }
  })
}
