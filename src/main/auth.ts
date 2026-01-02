import { ipcMain } from "electron";
import db from "./database";
import bcrypt from "bcryptjs";

// Constants
const LAUTECH_EMAIL_DOMAIN = "@lautech.edu.ng";
const MIN_PASSWORD_LENGTH = 8;


const isLautechEmail = (email: string): boolean => {
  return email.toLowerCase().endsWith(LAUTECH_EMAIL_DOMAIN);
};

const validatePassword = (
  password: string
): { valid: boolean; message: string } => {
  if (password.length < MIN_PASSWORD_LENGTH) {
    return {
      valid: false,
      message: `Password must be at least ${MIN_PASSWORD_LENGTH} characters long`,
    };
  }
  if (!/[A-Z]/.test(password)) {
    return {
      valid: false,
      message: "Password must contain at least one uppercase letter",
    };
  }
  if (!/[a-z]/.test(password)) {
    return {
      valid: false,
      message: "Password must contain at least one lowercase letter",
    };
  }
  if (!/[0-9]/.test(password)) {
    return {
      valid: false,
      message: "Password must contain at least one number",
    };
  }
  return { valid: true, message: "Password is valid" };
};

export const setupAdminHandlers = () => {
  ipcMain.handle(
    "admin:login",
    async (event, email: string, password: string) => {
      try {
        // Validate input
        if (!email || !password) {
          throw new Error("Email and password are required");
        }

        // Validate email domain
        if (!isLautechEmail(email)) {
          throw new Error(
            "Only LAUTECH email addresses (@lautech.edu.ng) are allowed"
          );
        }

        const user = db
          .prepare("SELECT * FROM users WHERE email = ?")
          .get(email) as
          | {
              id: number;
              email: string;
              password_hash: string;
              role: string;
            }
          | undefined;

        if (!user) {
          throw new Error("Invalid email or password");
        }

        const isPasswordValid = bcrypt.compareSync(
          password,
          user.password_hash
        );

        if (!isPasswordValid) {
          throw new Error("Invalid email or password");
        }

        // Update last login timestamp
        db.prepare(
          "UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE id = ?"
        ).run(user.id);

        return {
          success: true,
          id: user.id,
          email: user.email,
          role: user.role,
          message: "Login successful",
        };
      } catch (error: any) {
        return {
          success: false,
          message: error.message,
        };
      }
    }
  );

  /**
   * Create Admin Handler
   * Only Super Admin can create new admin accounts
   * Admin email must be @lautech.edu.ng
   */
  ipcMain.handle(
    "auth:create-admin",
    async (
      event,
      email: string,
      password: string,
      createdByAdminId?: number
    ) => {
      try {
        // Validate input
        if (!email || !password) {
          throw new Error("Email and password are required");
        }

        // Validate email domain
        if (!isLautechEmail(email)) {
          throw new Error(
            "Only LAUTECH email addresses (@lautech.edu.ng) are allowed"
          );
        }

        // Check if user already exists
        const existingUser = db
          .prepare("SELECT * FROM users WHERE email = ?")
          .get(email);

        if (existingUser) {
          throw new Error("User with this email already exists");
        }

        // Validate password strength
        const passwordValidation = validatePassword(password);
        if (!passwordValidation.valid) {
          throw new Error(passwordValidation.message);
        }

        // Hash password
        const salt = bcrypt.genSaltSync(10);
        const hash = bcrypt.hashSync(password, salt);

        // Insert new admin user
        const result = db
          .prepare(
            `
            INSERT INTO users (email, password_hash, role, created_at) 
            VALUES (@email, @hash, 'admin', CURRENT_TIMESTAMP)
          `
          )
          .run({ email, hash });

        return {
          success: true,
          id: result.lastInsertRowid,
          message: "Admin user created successfully",
        };
      } catch (error: any) {
        return {
          success: false,
          message: error.message,
        };
      }
    }
  );

  ipcMain.handle(
    "auth:create-super-admin",
    async (event, email: string, password: string, createdByUserId: number) => {
      try {
        // Validate input
        if (!email || !password) {
          throw new Error("Email and password are required");
        }

        // Verify that the user creating this super admin is themselves a super admin
        const creator = db
          .prepare("SELECT * FROM users WHERE id = ?")
          .get(createdByUserId) as { role: string } | undefined;

        if (!creator) {
          throw new Error("Creator user not found");
        }

        if (creator.role !== "super_admin") {
          throw new Error("Only super admins can create other super admins");
        }

        // Validate email domain
        if (!isLautechEmail(email)) {
          throw new Error(
            "Only LAUTECH email addresses (@lautech.edu.ng) are allowed"
          );
        }

        // Check if user already exists
        const existingUser = db
          .prepare("SELECT * FROM users WHERE email = ?")
          .get(email);

        if (existingUser) {
          throw new Error("User with this email already exists");
        }

        // Validate password strength
        const passwordValidation = validatePassword(password);
        if (!passwordValidation.valid) {
          throw new Error(passwordValidation.message);
        }

        // Hash password
        const salt = bcrypt.genSaltSync(10);
        const hash = bcrypt.hashSync(password, salt);

        // Insert new super admin user
        const result = db
          .prepare(
            `
            INSERT INTO users (email, password_hash, role, created_at) 
            VALUES (@email, @hash, 'super_admin', CURRENT_TIMESTAMP)
          `
          )
          .run({ email, hash });

        return {
          success: true,
          id: result.lastInsertRowid,
          message: "Super admin user created successfully",
        };
      } catch (error: any) {
        return {
          success: false,
          message: error.message,
        };
      }
    }
  );

  /**
   * Change Password Handler
   * Allows users to change their password
   */
  ipcMain.handle(
    "auth:change-password",
    async (event, userId: number, oldPassword: string, newPassword: string) => {
      try {
        if (!oldPassword || !newPassword) {
          throw new Error("Old password and new password are required");
        }

        const user = db
          .prepare("SELECT * FROM users WHERE id = ?")
          .get(userId) as { password_hash: string } | undefined;

        if (!user) {
          throw new Error("User not found");
        }

        // Verify old password
        const isOldPasswordValid = bcrypt.compareSync(
          oldPassword,
          user.password_hash
        );
        if (!isOldPasswordValid) {
          throw new Error("Old password is incorrect");
        }

        // Validate new password strength
        const passwordValidation = validatePassword(newPassword);
        if (!passwordValidation.valid) {
          throw new Error(passwordValidation.message);
        }

        // Hash new password
        const salt = bcrypt.genSaltSync(10);
        const newHash = bcrypt.hashSync(newPassword, salt);

        // Update password
        db.prepare("UPDATE users SET password_hash = ? WHERE id = ?").run(
          newHash,
          userId
        );

        return {
          success: true,
          message: "Password changed successfully",
        };
      } catch (error: any) {
        return {
          success: false,
          message: error.message,
        };
      }
    }
  );
};
