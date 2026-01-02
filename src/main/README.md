# Database Schema Documentation

## Overview

This document describes the SQLite database schema for the Result Management System. The schema is organized into 10 main categories covering all functional requirements.

## Database Tables

### 1. Account Management

#### `roles`

Defines user roles and their permissions.

- **id**: Primary key
- **name**: Role name (Super Administrator, Administrator, Viewer)
- **description**: Role description
- **created_at**: Timestamp

#### `users`

User accounts for system administrators.

- **id**: Primary key
- **username**: Unique username for login
- **email**: Unique email address
- **password_hash**: Hashed password
- **role_id**: Foreign key to roles table
- **full_name**: User's full name
- **phone**: Contact number
- **is_active**: Account status
- **last_login**: Last login timestamp
- **created_at/updated_at**: Timestamps
- **created_by**: User who created this account

---

### 2. Organizational Structure

#### `faculties`

University faculties/colleges.

- **id**: Primary key
- **name**: Faculty name (unique)
- **code**: Faculty code (unique)
- **description**: Faculty description

#### `faculty_deans`

Heads of faculties.

- **faculty_id**: Foreign key to faculties (one-to-one)
- **dean_name**: Dean's full name
- **email/phone**: Contact information
- **start_date/end_date**: Term of office
- **is_active**: Current status

#### `departments`

Departments within faculties.

- **id**: Primary key
- **name**: Department name (unique)
- **code**: Department code (unique)
- **faculty_id**: Foreign key to faculties
- **description**: Department description

#### `department_heads`

Heads of departments.

- **department_id**: Foreign key to departments (one-to-one)
- **hod_name**: HOD's full name
- **email/phone**: Contact information
- **start_date/end_date**: Term of office
- **is_active**: Current status

---

### 3. Academic Structure

#### `academic_sessions`

Academic years (e.g., 2024/2025).

- **id**: Primary key
- **session_name**: Display name
- **start_year/end_year**: Academic year range
- **is_active**: Currently active session

#### `semesters`

Semesters within academic sessions.

- **session_id**: Foreign key to academic_sessions
- **semester_number**: 1 or 2
- **semester_name**: "First Semester", etc.
- **start_date/end_date**: Semester dates
- **is_active**: Currently active semester

#### `student_sets`

Student cohorts/classes (groups of students admitted in same year).

- **id**: Primary key
- **department_id**: Foreign key to departments
- **admission_year**: Year of admission
- **level**: 100, 200, 300, 400 (course level)
- **set_name**: e.g., "CS 200L (2022 Admission)"
- **is_active**: Currently active

---

### 4. Student Records

#### `students`

Student biodata and enrollment information.

- **id**: Primary key
- **student_id**: Unique student ID (e.g., "CS/2022/001")
- **set_id**: Foreign key to student_sets
- **first_name/last_name/middle_name**: Student name
- **gender**: Student gender
- **date_of_birth**: DOB
- **email/phone**: Contact information
- **address/city/state/postal_code**: Physical address
- **nationality**: Nationality
- **admission_date**: Date admitted
- **status**: active, graduated, suspended, withdrawn
- **photo_path**: Path to student photo

---

### 5. Curriculum Management

#### `courses`

Course definitions.

- **id**: Primary key
- **code**: Unique course code (e.g., "CS201")
- **title**: Course title
- **credit_units**: Credit units for the course
- **semester_id**: Which semester this course is offered
- **department_id**: Offering department
- **is_mandatory**: Whether course is required

#### `curriculum`

Curriculum plan for a student set in a specific semester.

- **id**: Primary key
- **set_id**: Which student set
- **semester_id**: Which semester
- **created_by**: Administrator who created curriculum
- **created_at/updated_at**: Timestamps

#### `curriculum_courses`

Courses included in a curriculum.

- **curriculum_id**: Foreign key to curriculum
- **course_id**: Foreign key to courses
- Maps courses to specific curriculum instances

---

### 6. Results & Grades

#### `grading_scale`

Grading system definition (default 4.0 scale).

- **grade_letter**: Letter grade (A, B, C, D, F)
- **grade_point**: Corresponding GPA point
- **min_score/max_score**: Score range for grade
- Example: A = 4.0 points, 80-100 score range

#### `results`

Student grades for each course.

- **id**: Primary key
- **student_id**: Which student
- **course_id**: Which course
- **semester_id**: Which semester
- **academic_session_id**: Which academic year
- **raw_score**: Score obtained (0-100)
- **grade_letter**: Computed grade (A-F)
- **grade_point**: Computed GPA points
- **is_exempted**: Whether student is exempted from course
- **remarks**: Additional notes
- **created_by**: Administrator who entered grade

#### `student_gpa`

Computed GPA for each student per semester.

- **student_id**: Which student
- **semester_id**: Which semester
- **academic_session_id**: Which academic year
- **semester_gpa**: GPA for that semester only
- **cumulative_gpa**: Overall GPA to date
- **total_credit_units**: Total credits taken
- **earned_credit_units**: Credits successfully completed

---

### 7. Reports

#### `master_mark_sheets`

Log of generated mark sheets for audit trail.

- **set_id**: Which student set
- **semester_id**: Which semester
- **course_id**: Which course
- **file_path**: Where the report file is stored
- **generated_by**: Administrator who generated report

#### `report_logs`

Log of all generated reports for audit trail.

- **report_type**: "Master Mark Sheet", "Running List", etc.
- **format**: xlsx, pdf, csv
- **file_path**: Location of generated file
- **status**: success, error, pending
- **error_message**: Error details if failed

---

### 8. Audit & System

#### `database_backups`

Log of database backups.

- **backup_name**: Name of backup
- **backup_path**: Location of backup file
- **created_at/created_by**: When and who created
- **restored_at/restored_by**: When and who restored

#### `audit_logs`

Audit trail of all database modifications.

- **user_id**: Which user made the change
- **action**: INSERT, UPDATE, DELETE, etc.
- **table_name**: Which table was modified
- **old_values**: Previous values (JSON)
- **new_values**: New values (JSON)
- **timestamp**: When change occurred

---

## Key Relationships

```
Faculty → Department → StudentSet → Student
                                  ↓
                            Results (Course) → Grade
                                  ↓
                            Student GPA

Academic Session → Semester → Courses
                         ↓
                    Curriculum → CurriculumCourse

Faculty → FacultyDean
Department → DepartmentHead
Department → Courses

User (Admin) creates/manages all entities
```

---

## Database Constraints

1. **Foreign Keys**: Enabled to maintain referential integrity
2. **Unique Constraints**:
   - `username`, `email` in users
   - Faculty/Department names and codes
   - Student ID within system
   - Course code
   - Combined (set_id, semester_id) for curriculum
   - Combined (student_id, course_id, semester_id, session_id) for results

3. **Not Null Constraints**: Applied to all required fields

---

## Performance Indexes

Indexes are created on frequently queried columns:

- User role lookups
- Student set/course lookups
- Result queries (student, course, semester, session)
- GPA queries
- Audit log queries
- Department/Faculty queries

---

## Initial Data

The schema includes default data:

- **Roles**: Super Administrator, Administrator, Viewer
- **Grading Scale**: Standard 4.0 point scale (A=4.0, B=3.0, C=2.0, D=1.0, F=0.0)

---

## Usage Notes

1. **Database Location**: Stored in user's app data directory (userData folder)
2. **WAL Mode**: Enabled for better concurrent access
3. **Password Storage**: Passwords should be hashed before insertion (use bcrypt or similar)
4. **Audit Logging**: All modifications should be logged to `audit_logs` table
5. **Backup**: Use the DatabaseManager to create backups (stored as separate .db files)
6. **Restore**: Can restore from backup files for recovery

---

## Database Initialization

The database is automatically initialized when the application starts:

1. Connection is established
2. Foreign keys are enabled
3. WAL mode is enabled
4. Schema is created if it doesn't exist
5. Default data is inserted

No manual SQL execution is needed.
