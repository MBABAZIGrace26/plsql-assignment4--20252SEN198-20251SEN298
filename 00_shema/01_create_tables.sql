SET SERVEROUTPUT ON

BEGIN
  FOR t IN (SELECT table_name FROM user_tables
            WHERE table_name IN ('GRADE_AUDIT','ENROLLMENTS','COURSES','STUDENTS','DEPARTMENTS','PERF_TEST')) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
  END LOOP;
END;
/

CREATE OR REPLACE TYPE t_id_list AS TABLE OF NUMBER;
/
CREATE OR REPLACE TYPE t_name_list AS TABLE OF VARCHAR2(100);
/

CREATE TABLE departments (
  dept_id   NUMBER(4)    CONSTRAINT pk_departments PRIMARY KEY,
  dept_name VARCHAR2(80) NOT NULL CONSTRAINT uq_dept_name UNIQUE
);

CREATE TABLE students (
  student_id NUMBER(6)     CONSTRAINT pk_students PRIMARY KEY,
  full_name  VARCHAR2(100) NOT NULL,
  email      VARCHAR2(120) NOT NULL CONSTRAINT uq_student_email UNIQUE,
  dept_id    NUMBER(4)     NOT NULL,
  status     VARCHAR2(10)  DEFAULT 'ACTIVE' NOT NULL,
  CONSTRAINT fk_students_dept FOREIGN KEY (dept_id) REFERENCES departments (dept_id),
  CONSTRAINT ck_student_status CHECK (status IN ('ACTIVE','SUSPENDED','GRADUATED'))
);

CREATE TABLE courses (
  course_id    VARCHAR2(10)  CONSTRAINT pk_courses PRIMARY KEY,
  course_name  VARCHAR2(100) NOT NULL,
  credits      NUMBER(1)     NOT NULL,
  dept_id      NUMBER(4)     NOT NULL,
  max_capacity NUMBER(3)     DEFAULT 40 NOT NULL,
  CONSTRAINT fk_courses_dept FOREIGN KEY (dept_id) REFERENCES departments (dept_id),
  CONSTRAINT ck_course_credits CHECK (credits BETWEEN 1 AND 6),
  CONSTRAINT ck_course_capacity CHECK (max_capacity > 0)
);

CREATE TABLE enrollments (
  enrollment_id NUMBER GENERATED ALWAYS AS IDENTITY CONSTRAINT pk_enrollments PRIMARY KEY,
  student_id    NUMBER(6)    NOT NULL,
  course_id     VARCHAR2(10) NOT NULL,
  semester      VARCHAR2(10) NOT NULL,
  marks         NUMBER(5,2),
  grade_letter  CHAR(1),
  CONSTRAINT fk_enr_student FOREIGN KEY (student_id) REFERENCES students (student_id),
  CONSTRAINT fk_enr_course  FOREIGN KEY (course_id)  REFERENCES courses (course_id),
  CONSTRAINT uq_enrollment  UNIQUE (student_id, course_id, semester),
  CONSTRAINT ck_marks       CHECK (marks BETWEEN 0 AND 100),
  CONSTRAINT ck_grade       CHECK (grade_letter IN ('A','B','C','D','F'))
);

CREATE TABLE grade_audit (
  audit_id      NUMBER GENERATED ALWAYS AS IDENTITY CONSTRAINT pk_grade_audit PRIMARY KEY,
  enrollment_id NUMBER NOT NULL,
  old_marks     NUMBER(5,2),
  new_marks     NUMBER(5,2),
  changed_on    DATE DEFAULT SYSDATE NOT NULL
);

CREATE TABLE perf_test (
  id    NUMBER,
  label VARCHAR2(30)
);