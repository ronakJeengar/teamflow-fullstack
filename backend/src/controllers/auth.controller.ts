import { Request, Response } from "express";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { prisma } from "../prisma/client.js";
import { AuthRequest } from "../middleware/auth.middleware.js";
import { failure, success } from "../utils/response.js";

// Extend Request type
declare global {
  namespace Express {
    interface Request {
      user?: {
        userId: string;
        role?: string;
      };
    }
  }
}

const JWT_ACCESS_SECRET = process.env.JWT_ACCESS_SECRET;
const JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET;

if (!JWT_ACCESS_SECRET || !JWT_REFRESH_SECRET) {
  throw new Error("JWT secrets are not defined in environment variables");
}

/* ========================= REGISTER ========================= */

export const register = async (req: Request, res: Response) => {
  try {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
      return failure(res, "All fields are required", 400);
    }

    const existingUser = await prisma.user.findUnique({ where: { email } });
    if (existingUser) {
      return failure(res, "Email already registered", 400);
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const user = await prisma.user.create({
      data: {
        name,
        email,
        password: hashedPassword,
      },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
        createdAt: true,
      },
    });

    return success(res, "Registration successful", user, 201);
  } catch (error) {
    console.error("Register error:", error);
    return failure(res, "Internal server error", 500);
  }
};

/* ========================= LOGIN ========================= */

export const login = async (req: Request, res: Response) => {
  try {
    const { email, password } = req.body;

    const user = await prisma.user.findUnique({ where: { email } });
    if (!user) {
      return failure(res, "Invalid credentials", 401);
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return failure(res, "Invalid credentials", 401);
    }

    const accessToken = jwt.sign(
      { userId: user.id, role: user.role },
      JWT_ACCESS_SECRET,
      { expiresIn: "15m" },
    );

    const refreshToken = jwt.sign({ userId: user.id }, JWT_REFRESH_SECRET, {
      expiresIn: "7d",
    });

    // Set access token cookie
    res.cookie("accessToken", accessToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "strict",
      maxAge: 15 * 60 * 1000, // 15 minutes
    });

    // Set refresh token cookie
    res.cookie("refreshToken", refreshToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "strict",
      maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
    });

    return success(res, "Login successful", {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
    });
  } catch (error) {
    console.error("Login error:", error);
    return failure(res, "Internal server error", 500);
  }
};

/* ========================= CURRENT USER ========================= */

export const getCurrentUser = async (req: AuthRequest, res: Response) => {
  try {
    if (!req.user) {
      return res.sendStatus(204);
    }

    const user = await prisma.user.findUnique({
      where: { id: req.user.userId },
      select: {
        id: true,
        name: true,
        email: true,
        role: true,
      },
    });

    if (!user) {
      return failure(res, "User not found", 404);
    }

    return success(res, "User fetched successfully", user);
  } catch (error) {
    console.error("Get current user error:", error);
    return failure(res, "Internal server error", 500);
  }
};

/* ========================= REFRESH ========================= */

export const refresh = (req: Request, res: Response) => {
  const token = req.cookies?.refreshToken;

  if (!token) {
    return res.sendStatus(204);
  }

  try {
    const decoded = jwt.verify(token, JWT_REFRESH_SECRET) as {
      userId: string;
    };

    const accessToken = jwt.sign(
      { userId: decoded.userId },
      JWT_ACCESS_SECRET,
      { expiresIn: "15m" },
    );

    // Set new access token cookie
    res.cookie("accessToken", accessToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "strict",
      maxAge: 15 * 60 * 1000, // 15 minutes
    });

    return success(res, "Token refreshed successfully", { accessToken });
  } catch (error) {
    return failure(res, "Invalid refresh token", 403);
  }
};

export const logout = (req: Request, res: Response) => {
  res.clearCookie("accessToken");
  res.clearCookie("refreshToken");
  return success(res, "Logged out successfully", null);
};
