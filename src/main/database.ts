import Database from "better-sqlite3";
import bcrypt from "bcryptjs";
import path from "path";
import { app } from "electron";

// Initialize DB
const dbPath = path.join(app.getPath("userData"), "database.sqlite");
const db = new Database(dbPath);

export const initDB = () => {
  // Create Table
  db.prepare(
    `
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT UNIQUE NOT NULL,
      password_hash TEXT NOT NULL,
      role TEXT CHECK(role IN ('super_admin', 'admin')) NOT NULL DEFAULT 'admin',
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  `
  ).run();

  // Create Default Super Admin if none exists
  const userCount = db.prepare("SELECT count(*) as count FROM users").get() as {
    count: number;
  };

  if (userCount.count === 0) {
    const salt = bcrypt.genSaltSync(10);
    const hash = bcrypt.hashSync("admin123", salt); // Default password

    db.prepare(
      `
      INSERT INTO users (email, password_hash, role) 
      VALUES (@email, @hash, 'super_admin')
    `
    ).run({ email: "admin@lautech.edu.ng", hash });

    console.log("Default Super Admin created: admin@lautech.edu.ng / admin123");
  }
};

export default db;
