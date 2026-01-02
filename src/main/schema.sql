-- =====================================================
-- Result Management System - SQLite Schema
-- Department of Information Systems
-- =====================================================

-- =====================================================
-- 1. ACCOUNT MANAGEMENT TABLES
-- =====================================================

-- User Roles
-- CREATE TABLE IF NOT EXISTS roles (
--   id INTEGER PRIMARY KEY AUTOINCREMENT,
--   name TEXT UNIQUE NOT NULL,
--   description TEXT,
--   created_at DATETIME DEFAULT CURRENT_TIMESTAMP
-- );

-- Users/Administrator Accounts 
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL, -- Store hashed passwords, never plain text
    role TEXT CHECK(role IN ('super_admin', 'admin')) NOT NULL DEFAULT 'admin',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 2. ORGANIZATIONAL STRUCTURE TABLES
-- =====================================================

-- Faculty
CREATE TABLE IF NOT EXISTS faculties (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT UNIQUE NOT NULL,
  code TEXT UNIQUE NOT NULL,
  description TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Faculty Dean
CREATE TABLE IF NOT EXISTS faculty_deans (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  faculty_id INTEGER UNIQUE NOT NULL,
  dean_name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  start_date DATE,
  end_date DATE,
  is_active BOOLEAN DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (faculty_id) REFERENCES faculties(id)
);

-- Department
CREATE TABLE IF NOT EXISTS departments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT UNIQUE NOT NULL,
  code TEXT UNIQUE NOT NULL,
  faculty_id INTEGER NOT NULL,
  description TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (faculty_id) REFERENCES faculties(id)
);

-- Department Head of Department (HOD)
CREATE TABLE IF NOT EXISTS department_heads (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  department_id INTEGER UNIQUE NOT NULL,
  hod_name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  start_date DATE,
  end_date DATE,
  is_active BOOLEAN DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (department_id) REFERENCES departments(id)
);

-- =====================================================
-- 3. ACADEMIC STRUCTURE TABLES
-- =====================================================

-- Academic Sessions/Years
CREATE TABLE IF NOT EXISTS academic_sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_name TEXT NOT NULL,
  start_year INTEGER NOT NULL,
  end_year INTEGER NOT NULL,
  is_active BOOLEAN DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(start_year, end_year)
);

-- Semesters
CREATE TABLE IF NOT EXISTS semesters (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id INTEGER NOT NULL,
  semester_number INTEGER NOT NULL,
  semester_name TEXT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  is_active BOOLEAN DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (session_id) REFERENCES academic_sessions(id),
  UNIQUE(session_id, semester_number)
);

-- Student Sets/Cohorts/Programs
CREATE TABLE IF NOT EXISTS student_sets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  department_id INTEGER NOT NULL,
  admission_year INTEGER NOT NULL,
  level INTEGER NOT NULL,
  set_name TEXT NOT NULL,
  description TEXT,
  is_active BOOLEAN DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (department_id) REFERENCES departments(id),
  UNIQUE(department_id, admission_year, level)
);

-- =====================================================
-- 4. STUDENT RECORDS TABLES
-- =====================================================

-- Students
CREATE TABLE IF NOT EXISTS students (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  student_id TEXT UNIQUE NOT NULL,
  set_id INTEGER NOT NULL,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  middle_name TEXT,
  gender TEXT,
  date_of_birth DATE,
  email TEXT UNIQUE,
  phone TEXT,
  address TEXT,
  city TEXT,
  state TEXT,
  postal_code TEXT,
  nationality TEXT,
  admission_date DATE NOT NULL,
  status TEXT DEFAULT 'active',
  photo_path TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  created_by INTEGER,
  FOREIGN KEY (set_id) REFERENCES student_sets(id),
  FOREIGN KEY (created_by) REFERENCES users(id)
);

-- =====================================================
-- 5. CURRICULUM TABLES
-- =====================================================

-- Courses
CREATE TABLE IF NOT EXISTS courses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  code TEXT UNIQUE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  credit_units INTEGER NOT NULL,
  semester_id INTEGER NOT NULL,
  department_id INTEGER NOT NULL,
  is_mandatory BOOLEAN DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (semester_id) REFERENCES semesters(id),
  FOREIGN KEY (department_id) REFERENCES departments(id)
);

-- Curriculum (Course Plan for a Set)
CREATE TABLE IF NOT EXISTS curriculum (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  set_id INTEGER NOT NULL,
  semester_id INTEGER NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  created_by INTEGER,
  FOREIGN KEY (set_id) REFERENCES student_sets(id),
  FOREIGN KEY (semester_id) REFERENCES semesters(id),
  FOREIGN KEY (created_by) REFERENCES users(id),
  UNIQUE(set_id, semester_id)
);

-- Curriculum Courses (Courses in a specific curriculum)
CREATE TABLE IF NOT EXISTS curriculum_courses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  curriculum_id INTEGER NOT NULL,
  course_id INTEGER NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (curriculum_id) REFERENCES curriculum(id),
  FOREIGN KEY (course_id) REFERENCES courses(id),
  UNIQUE(curriculum_id, course_id)
);

-- =====================================================
-- 6. RESULTS/GRADES TABLES
-- =====================================================

-- Grading Scale
CREATE TABLE IF NOT EXISTS grading_scale (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  grade_letter TEXT UNIQUE NOT NULL,
  grade_point REAL NOT NULL,
  min_score REAL NOT NULL,
  max_score REAL NOT NULL,
  description TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Student Results/Grades
CREATE TABLE IF NOT EXISTS results (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  student_id INTEGER NOT NULL,
  course_id INTEGER NOT NULL,
  semester_id INTEGER NOT NULL,
  academic_session_id INTEGER NOT NULL,
  raw_score REAL,
  grade_letter TEXT,
  grade_point REAL,
  is_exempted BOOLEAN DEFAULT 0,
  remarks TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  created_by INTEGER,
  FOREIGN KEY (student_id) REFERENCES students(id),
  FOREIGN KEY (course_id) REFERENCES courses(id),
  FOREIGN KEY (semester_id) REFERENCES semesters(id),
  FOREIGN KEY (academic_session_id) REFERENCES academic_sessions(id),
  FOREIGN KEY (grade_letter) REFERENCES grading_scale(grade_letter),
  FOREIGN KEY (created_by) REFERENCES users(id),
  UNIQUE(student_id, course_id, semester_id, academic_session_id)
);

-- Student GPA/Cumulative Results (Computed)
CREATE TABLE IF NOT EXISTS student_gpa (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  student_id INTEGER NOT NULL,
  semester_id INTEGER NOT NULL,
  academic_session_id INTEGER NOT NULL,
  semester_gpa REAL,
  cumulative_gpa REAL,
  total_credit_units INTEGER,
  earned_credit_units INTEGER,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES students(id),
  FOREIGN KEY (semester_id) REFERENCES semesters(id),
  FOREIGN KEY (academic_session_id) REFERENCES academic_sessions(id),
  UNIQUE(student_id, semester_id, academic_session_id)
);

-- =====================================================
-- 7. REPORTS TABLES
-- =====================================================

-- Master Mark Sheet (Aggregated Results)
CREATE TABLE IF NOT EXISTS master_mark_sheets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  set_id INTEGER NOT NULL,
  semester_id INTEGER NOT NULL,
  academic_session_id INTEGER NOT NULL,
  course_id INTEGER NOT NULL,
  generated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  generated_by INTEGER,
  file_path TEXT,
  FOREIGN KEY (set_id) REFERENCES student_sets(id),
  FOREIGN KEY (semester_id) REFERENCES semesters(id),
  FOREIGN KEY (academic_session_id) REFERENCES academic_sessions(id),
  FOREIGN KEY (course_id) REFERENCES courses(id),
  FOREIGN KEY (generated_by) REFERENCES users(id)
);

-- Report Generation Log
CREATE TABLE IF NOT EXISTS report_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  report_type TEXT NOT NULL,
  set_id INTEGER,
  semester_id INTEGER,
  academic_session_id INTEGER,
  format TEXT NOT NULL,
  file_path TEXT,
  generated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  generated_by INTEGER,
  status TEXT DEFAULT 'success',
  error_message TEXT,
  FOREIGN KEY (set_id) REFERENCES student_sets(id),
  FOREIGN KEY (semester_id) REFERENCES semesters(id),
  FOREIGN KEY (academic_session_id) REFERENCES academic_sessions(id),
  FOREIGN KEY (generated_by) REFERENCES users(id)
);

-- =====================================================
-- 8. AUDIT & SYSTEM TABLES
-- =====================================================

-- Database Backups
CREATE TABLE IF NOT EXISTS database_backups (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  backup_name TEXT UNIQUE NOT NULL,
  backup_path TEXT NOT NULL,
  backup_size INTEGER,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  created_by INTEGER,
  restored_at DATETIME,
  restored_by INTEGER,
  FOREIGN KEY (created_by) REFERENCES users(id),
  FOREIGN KEY (restored_by) REFERENCES users(id)
);

-- Audit Log
CREATE TABLE IF NOT EXISTS audit_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER,
  action TEXT NOT NULL,
  table_name TEXT,
  record_id INTEGER,
  old_values TEXT,
  new_values TEXT,
  ip_address TEXT,
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- =====================================================
-- 9. INDEXES FOR PERFORMANCE
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_users_role_id ON users(role_id);
CREATE INDEX IF NOT EXISTS idx_users_is_active ON users(is_active);
CREATE INDEX IF NOT EXISTS idx_students_set_id ON students(set_id);
CREATE INDEX IF NOT EXISTS idx_students_status ON students(status);
CREATE INDEX IF NOT EXISTS idx_results_student_id ON results(student_id);
CREATE INDEX IF NOT EXISTS idx_results_course_id ON results(course_id);
CREATE INDEX IF NOT EXISTS idx_results_semester_id ON results(semester_id);
CREATE INDEX IF NOT EXISTS idx_results_session_id ON results(academic_session_id);
CREATE INDEX IF NOT EXISTS idx_student_gpa_student_id ON student_gpa(student_id);
CREATE INDEX IF NOT EXISTS idx_student_gpa_semester_id ON student_gpa(semester_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_timestamp ON audit_logs(timestamp);
CREATE INDEX IF NOT EXISTS idx_departments_faculty_id ON departments(faculty_id);
CREATE INDEX IF NOT EXISTS idx_student_sets_department_id ON student_sets(department_id);
CREATE INDEX IF NOT EXISTS idx_courses_department_id ON courses(department_id);
CREATE INDEX IF NOT EXISTS idx_courses_semester_id ON courses(semester_id);
CREATE INDEX IF NOT EXISTS idx_semesters_session_id ON semesters(session_id);

-- =====================================================
-- 10. INITIAL DATA
-- =====================================================

-- Insert default roles
INSERT INTO roles (name, description) VALUES 
  ('Super Administrator', 'Full system access, account management'),
  ('Administrator', 'Record management, result processing'),
  ('Viewer', 'View-only access to records and reports')
ON CONFLICT DO NOTHING;

-- Insert default grading scale (Typical 4.0 scale)
INSERT INTO grading_scale (grade_letter, grade_point, min_score, max_score, description) VALUES
  ('A', 4.0, 80, 100, 'Excellent'),
  ('B', 3.0, 70, 79, 'Good'),
  ('C', 2.0, 60, 69, 'Satisfactory'),
  ('D', 1.0, 50, 59, 'Pass'),
  ('F', 0.0, 0, 49, 'Fail')
ON CONFLICT DO NOTHING;
