import { Request, Response } from "express";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { prisma } from "../prisma/client.js";
import { AuthRequest } from "../middleware/auth.middleware.js";
import { successResponse, errorResponse } from "../utils/response.js";

const JWT_ACCESS_SECRET = process.env.JWT_ACCESS_SECRET!;
const JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET!;

/* ========================= REGISTER ========================= */

export const register = async (req: Request, res: Response): Promise<void> => {
  try {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
      errorResponse(res, "All fields are required", 400);
      return;
    }

    const existingUser = await prisma.user.findUnique({
      where: { email },
    });

    if (existingUser) {
      errorResponse(res, "Email already registered", 400);
      return;
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const workspaceName = `${name}'s Workspace`;
    let slug = workspaceName
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/(^-|-$)+/g, "");
    
    if (!slug) {
      slug = "workspace";
    }

    const count = await prisma.workspace.count({ where: { slug } });
    if (count > 0) {
      slug = `${slug}-${Math.random().toString(36).substring(2, 7)}`;
    }

    const result = await prisma.$transaction(async (tx) => {
      const u = await tx.user.create({
        data: {
          name,
          email,
          password: hashedPassword,
        },
      });

      await tx.workspace.create({
        data: {
          name: workspaceName,
          slug,
          color: "#7C5CFF",
          ownerId: u.id,
          members: {
            create: {
              userId: u.id,
              role: "OWNER",
            },
          },
        },
      });

      return u;
    });

    const userResponse = {
      id: result.id,
      name: result.name,
      email: result.email,
      role: result.role,
      createdAt: result.createdAt,
    };

    successResponse(res, userResponse, "Registration successful", 201);
  } catch (error) {
    console.error("Register error:", error);
    errorResponse(res, "Internal server error", 500);
  }
};

/* ========================= LOGIN ========================= */

export const login = async (req: Request, res: Response): Promise<void> => {
  try {
    const { email, password } = req.body;

    const user = await prisma.user.findUnique({
      where: { email },
    });

    if (!user) {
      errorResponse(res, "Invalid credentials", 401);
      return;
    }

    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      errorResponse(res, "Invalid credentials", 401);
      return;
    }

    // Default to the first workspace owned or member of, if none auto-create
    let workspaceMember = await prisma.workspaceMember.findFirst({
      where: { userId: user.id },
      orderBy: { joinedAt: "asc" },
    });

    if (!workspaceMember) {
      const workspaceName = `${user.name}'s Workspace`;
      let slug = workspaceName
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, "-")
        .replace(/(^-|-$)+/g, "");
      
      if (!slug) {
        slug = "workspace";
      }

      const count = await prisma.workspace.count({ where: { slug } });
      if (count > 0) {
        slug = `${slug}-${Math.random().toString(36).substring(2, 7)}`;
      }

      const newWs = await prisma.workspace.create({
        data: {
          name: workspaceName,
          slug,
          color: "#7C5CFF",
          ownerId: user.id,
          members: {
            create: {
              userId: user.id,
              role: "OWNER",
            },
          },
        },
      });

      workspaceMember = await prisma.workspaceMember.findFirst({
        where: { userId: user.id, workspaceId: newWs.id },
      });
    }

    const activeWorkspaceId = workspaceMember ? workspaceMember.workspaceId : undefined;

    const accessToken = jwt.sign(
      {
        userId: user.id,
        email: user.email,
        role: user.role,
        activeWorkspaceId,
      },
      JWT_ACCESS_SECRET,
      { expiresIn: "15m" },
    );

    const refreshToken = jwt.sign({ userId: user.id }, JWT_REFRESH_SECRET, {
      expiresIn: "7d",
    });

    res.cookie("accessToken", accessToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "strict",
      maxAge: 15 * 60 * 1000,
    });

    res.cookie("refreshToken", refreshToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "strict",
      maxAge: 7 * 24 * 60 * 60 * 1000,
    });

    successResponse(res, {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      activeWorkspaceId,
    }, "Login successful");
  } catch (error) {
    console.error("Login error:", error);
    errorResponse(res, "Internal server error", 500);
  }
};

/* ========================= CURRENT USER ========================= */

export const getCurrentUser = async (
  req: AuthRequest,
  res: Response,
): Promise<void> => {
  try {
    if (!req.user) {
      res.sendStatus(204);
      return;
    }

    const user = await prisma.user.findUnique({
      where: { id: req.user.userId },
      select: {
        id: true,
        name: true,
        email: true,
        avatar: true,
        bio: true,
        role: true,
      },
    });

    if (!user) {
      errorResponse(res, "User not found", 404);
      return;
    }

    successResponse(res, {
      ...user,
      activeWorkspaceId: req.user.activeWorkspaceId,
    }, "User fetched successfully");
  } catch (error) {
    console.error("Get current user error:", error);
    errorResponse(res, "Internal server error", 500);
  }
};

/* ========================= UPDATE PROFILE ========================= */

export const updateProfile = async (
  req: AuthRequest,
  res: Response,
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { name, avatar, bio, password } = req.body;

    const data: any = {};
    if (name !== undefined) data.name = name;
    if (avatar !== undefined) data.avatar = avatar;
    if (bio !== undefined) data.bio = bio;
    if (password !== undefined) {
      data.password = await bcrypt.hash(password, 10);
    }

    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data,
      select: {
        id: true,
        name: true,
        email: true,
        avatar: true,
        bio: true,
        role: true,
      },
    });

    successResponse(res, updatedUser, "Profile updated successfully");
  } catch (error) {
    console.error("Update profile error:", error);
    errorResponse(res, "Internal server error", 500);
  }
};

/* ========================= MY MEMBERSHIPS ========================= */

export const getMyMemberships = async (
  req: AuthRequest,
  res: Response,
): Promise<void> => {
  try {
    const userId = req.user!.userId;

    const memberships = await prisma.teamMember.findMany({
      where: { userId },
      select: {
        role: true,
        team: {
          select: {
            id: true,
            name: true,
            avatar: true,
          },
        },
      },
    });

    successResponse(res, memberships, "Memberships fetched successfully");
  } catch (error) {
    console.error("Get memberships error:", error);
    errorResponse(res, "Internal server error", 500);
  }
};

/* ========================= REFRESH ========================= */

export const refresh = async (req: Request, res: Response): Promise<void> => {
  const token = req.cookies?.refreshToken;

  if (!token) {
    res.sendStatus(204);
    return;
  }

  try {
    const decoded = jwt.verify(token, JWT_REFRESH_SECRET) as {
      userId: string;
    };

    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
      select: {
        id: true,
        email: true,
        role: true,
      },
    });

    if (!user) {
      errorResponse(res, "User not found", 401);
      return;
    }

    let activeWorkspaceId: string | undefined;
    const expiredAccessToken = req.cookies?.accessToken;
    if (expiredAccessToken) {
      try {
        const decodedAccess = jwt.verify(expiredAccessToken, JWT_ACCESS_SECRET, {
          ignoreExpiration: true,
        }) as { activeWorkspaceId?: string };
        activeWorkspaceId = decodedAccess.activeWorkspaceId;
      } catch (err) {
        // Ignore verify errors for expired/malformed token and fall back
      }
    }

    if (activeWorkspaceId) {
      const isMember = await prisma.workspaceMember.findFirst({
        where: { workspaceId: activeWorkspaceId, userId: user.id },
      });
      if (!isMember) {
        activeWorkspaceId = undefined;
      }
    }

    if (!activeWorkspaceId) {
      const workspaceMember = await prisma.workspaceMember.findFirst({
        where: { userId: user.id },
        orderBy: { joinedAt: "asc" },
      });
      activeWorkspaceId = workspaceMember ? workspaceMember.workspaceId : undefined;
    }

    const accessToken = jwt.sign(
      {
        userId: user.id,
        email: user.email,
        role: user.role,
        activeWorkspaceId,
      },
      JWT_ACCESS_SECRET,
      { expiresIn: "15m" },
    );

    res.cookie("accessToken", accessToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "strict",
      maxAge: 15 * 60 * 1000,
    });

    successResponse(res, { accessToken }, "Token refreshed successfully");
  } catch {
    errorResponse(res, "Invalid refresh token", 403);
  }
};

/* ========================= LOGOUT ========================= */

export const logout = (req: Request, res: Response): void => {
  res.clearCookie("accessToken");
  res.clearCookie("refreshToken");

  successResponse(res, null, "Logged out successfully");
};
