# Group Assignment IV - Student Registration & Grading (Oracle PL/SQL)

Course: Database Development with PL/SQL (INSY 8311)
Instructor: Eric Maniraguha

## Group members
 Names                            Student ID 
MBABAZI Grace                     20252SEN198
UHIRIWE Benjamin


## Application description
A university system where students register for courses, lecturers record marks, and the registry
produces transcripts, GPAs and class reports.
Tables: departments, students, courses, enrollments, grade_audit (+ perfect_test for the benchmark).

Requirements covered:
- Register and drop students with capacity and status rules
- Update marks with automatic letter grade and an audit trail
- Bulk-enrol many students and apply a grade curve to a whole class
- Transcripts, GPA calculation, failing-student reports

## Where each concept is demonstrated
| Concept | File(s) |
|---|---|
| User-defined record | print_transcript.sql |
| %ROWTYPE | register_student_course.sql, update_marks.sql, print_transcript.sql |
| Associative array | course_grade_report.sql, benchmark_bulk_vs_loop.sql |
| Nested table / VARRAY | t_id_list, t_name_list, course_grade_report.sql, apply_grade_curve.sql |
| Implicit cursors | register_student_course, update_marks, drop_enrollment |
| Explicit cursors | print_transcript.sql (OPEN/FETCH/CLOSE), calculate_gpa.sql (FOR loop) |
| BULK COLLECT | apply_grade_curve.sql, get_failing_students.sql |
| FORALL + SAVE EXCEPTIONS | bulk_enroll_students.sql, apply_grade_curve.sql |
| Predefined exceptions | NO_DATA_FOUND, TOO_MANY_ROWS, DUP_VAL_ON_INDEX |
| User-defined exceptions | e_student_inactive, e_course_full, e_not_enrolled, e_already_graded, e_no_grades |
| RAISE_APPLICATION_ERROR | all procedures and functions (-20001 ... -20120) |

## How to run (Oracle 12c or later)
1. Run 00_schema/01_create_tables.sql
2. Run 00_schema/02_insert_data.sql
3. Compile the functions in 02_functions/ first (the procedures call get_letter_grade)
4. Compile the procedures in 01_procedures/
5. Run 03_tests/test_success_cases.sql, then 03_tests/test_error_cases.sql
6. Screenshots of every test output are in screenshots/

## AI usage disclosure
We used an AI assistant (Claude) to help draft the schema and PL/SQL code. We then reviewed, ran and
tested everything ourselves, and both members can explain every part of the code.
