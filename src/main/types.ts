/**
 * Database Type Definitions
 * Corresponds to the SQLite schema for Result Management System
 */

// =====================================================
// Account Management Types
// =====================================================

export interface Role {
  id: number;
  name: string;
  description?: string;
  created_at: string;
}

export interface User {
  id: number;
  username: string;
  email: string;
  password_hash: string;
  role_id: number;
  full_name: string;
  phone?: string;
  is_active: boolean;
  last_login?: string;
  created_at: string;
  updated_at: string;
  created_by?: number;
  role?: Role; // Populated when joined
}

// =====================================================
// Organizational Structure Types
// =====================================================

export interface Faculty {
  id: number;
  name: string;
  code: string;
  description?: string;
  created_at: string;
  updated_at: string;
}

export interface FacultyDean {
  id: number;
  faculty_id: number;
  dean_name: string;
  email?: string;
  phone?: string;
  start_date?: string;
  end_date?: string;
  is_active: boolean;
  created_at: string;
  updated_at: string;
  faculty?: Faculty; // Populated when joined
}

export interface Department {
  id: number;
  name: string;
  code: string;
  faculty_id: number;
  description?: string;
  created_at: string;
  updated_at: string;
  faculty?: Faculty; // Populated when joined
}

export interface DepartmentHead {
  id: number;
  department_id: number;
  hod_name: string;
  email?: string;
  phone?: string;
  start_date?: string;
  end_date?: string;
  is_active: boolean;
  created_at: string;
  updated_at: string;
  department?: Department; // Populated when joined
}

// =====================================================
// Academic Structure Types
// =====================================================

export interface AcademicSession {
  id: number;
  session_name: string;
  start_year: number;
  end_year: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface Semester {
  id: number;
  session_id: number;
  semester_number: number;
  semester_name: string;
  start_date: string;
  end_date: string;
  is_active: boolean;
  created_at: string;
  updated_at: string;
  session?: AcademicSession; // Populated when joined
}

export interface StudentSet {
  id: number;
  department_id: number;
  admission_year: number;
  level: number;
  set_name: string;
  description?: string;
  is_active: boolean;
  created_at: string;
  updated_at: string;
  department?: Department; // Populated when joined
}

// =====================================================
// Student Records Types
// =====================================================

export interface Student {
  id: number;
  student_id: string;
  set_id: number;
  first_name: string;
  last_name: string;
  middle_name?: string;
  gender?: string;
  date_of_birth?: string;
  email?: string;
  phone?: string;
  address?: string;
  city?: string;
  state?: string;
  postal_code?: string;
  nationality?: string;
  admission_date: string;
  status: "active" | "graduated" | "suspended" | "withdrawn";
  photo_path?: string;
  created_at: string;
  updated_at: string;
  created_by?: number;
  set?: StudentSet; // Populated when joined
}

// =====================================================
// Curriculum Types
// =====================================================

export interface Course {
  id: number;
  code: string;
  title: string;
  description?: string;
  credit_units: number;
  semester_id: number;
  department_id: number;
  is_mandatory: boolean;
  created_at: string;
  updated_at: string;
  semester?: Semester; // Populated when joined
  department?: Department; // Populated when joined
}

export interface Curriculum {
  id: number;
  set_id: number;
  semester_id: number;
  created_at: string;
  updated_at: string;
  created_by?: number;
  set?: StudentSet; // Populated when joined
  semester?: Semester; // Populated when joined
}

export interface CurriculumCourse {
  id: number;
  curriculum_id: number;
  course_id: number;
  created_at: string;
  curriculum?: Curriculum; // Populated when joined
  course?: Course; // Populated when joined
}

// =====================================================
// Results/Grades Types
// =====================================================

export interface GradingScale {
  id: number;
  grade_letter: string;
  grade_point: number;
  min_score: number;
  max_score: number;
  description?: string;
  created_at: string;
}

export interface Result {
  id: number;
  student_id: number;
  course_id: number;
  semester_id: number;
  academic_session_id: number;
  raw_score?: number;
  grade_letter?: string;
  grade_point?: number;
  is_exempted: boolean;
  remarks?: string;
  created_at: string;
  updated_at: string;
  created_by?: number;
  student?: Student; // Populated when joined
  course?: Course; // Populated when joined
  semester?: Semester; // Populated when joined
  session?: AcademicSession; // Populated when joined
}

export interface StudentGPA {
  id: number;
  student_id: number;
  semester_id: number;
  academic_session_id: number;
  semester_gpa?: number;
  cumulative_gpa?: number;
  total_credit_units: number;
  earned_credit_units: number;
  created_at: string;
  updated_at: string;
  student?: Student; // Populated when joined
  semester?: Semester; // Populated when joined
  session?: AcademicSession; // Populated when joined
}

// =====================================================
// Reports Types
// =====================================================

export interface MasterMarkSheet {
  id: number;
  set_id: number;
  semester_id: number;
  academic_session_id: number;
  course_id: number;
  generated_at: string;
  generated_by?: number;
  file_path?: string;
  set?: StudentSet; // Populated when joined
  semester?: Semester; // Populated when joined
  session?: AcademicSession; // Populated when joined
  course?: Course; // Populated when joined
}

export interface ReportLog {
  id: number;
  report_type: string;
  set_id?: number;
  semester_id?: number;
  academic_session_id?: number;
  format: "xlsx" | "pdf" | "csv";
  file_path?: string;
  generated_at: string;
  generated_by?: number;
  status: "success" | "error" | "pending";
  error_message?: string;
  set?: StudentSet; // Populated when joined
  semester?: Semester; // Populated when joined
  session?: AcademicSession; // Populated when joined
}

// =====================================================
// Audit & System Types
// =====================================================

export interface DatabaseBackup {
  id: number;
  backup_name: string;
  backup_path: string;
  backup_size?: number;
  created_at: string;
  created_by?: number;
  restored_at?: string;
  restored_by?: number;
}

export interface AuditLog {
  id: number;
  user_id?: number;
  action: string;
  table_name?: string;
  record_id?: number;
  old_values?: string;
  new_values?: string;
  ip_address?: string;
  timestamp: string;
  user?: User; // Populated when joined
}

// =====================================================
// Request/Response Types
// =====================================================

export interface PagedResponse<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  total_pages: number;
}

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  message?: string;
  error?: string;
}

// =====================================================
// Utility Types
// =====================================================

export type StudentStatus = "active" | "graduated" | "suspended" | "withdrawn";
export type ReportFormat = "xlsx" | "pdf" | "csv";
export type ReportStatus = "success" | "error" | "pending";
