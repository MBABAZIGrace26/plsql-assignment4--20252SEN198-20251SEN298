CREATE OR REPLACE PROCEDURE update_marks (
  p_student_id   IN  enrollments.student_id%TYPE,
  p_course_id    IN  enrollments.course_id%TYPE,
  p_semester     IN  enrollments.semester%TYPE,
  p_new_marks    IN  NUMBER,
  p_rows_updated OUT PLS_INTEGER
) AS
  v_enr enrollments%ROWTYPE;
BEGIN
  p_rows_updated := 0;
  IF p_new_marks IS NULL OR p_new_marks < 0 OR p_new_marks > 100 THEN
    RAISE_APPLICATION_ERROR(-20010, 'Marks must be between 0 and 100.');
  END IF;

  SELECT * INTO v_enr FROM enrollments
   WHERE student_id = p_student_id AND course_id = p_course_id AND semester = p_semester;

  UPDATE enrollments
     SET marks = p_new_marks,
         grade_letter = get_letter_grade(p_new_marks)
   WHERE enrollment_id = v_enr.enrollment_id;

  p_rows_updated := SQL%ROWCOUNT;          -- how many rows changed
  IF SQL%NOTFOUND THEN                     -- no row was touched
    RAISE_APPLICATION_ERROR(-20011, 'Enrollment disappeared before update.');
  END IF;
  IF SQL%FOUND THEN                        -- at least one row was touched
    INSERT INTO grade_audit (enrollment_id, old_marks, new_marks)
    VALUES (v_enr.enrollment_id, v_enr.marks, p_new_marks);
    DBMS_OUTPUT.PUT_LINE('Marks updated: ' || NVL(TO_CHAR(v_enr.marks), 'none') || ' -> ' || p_new_marks);
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20011, 'No enrollment for student ' || p_student_id || ' in ' || p_course_id || ' (' || p_semester || ').');
  WHEN OTHERS THEN
    IF SQLCODE NOT BETWEEN -20999 AND -20000 THEN
      DBMS_OUTPUT.PUT_LINE('update_marks unexpected error: ' || SQLERRM);
    END IF;
    RAISE;
END update_marks;
/
SHOW ERRORS

SELECT
    e.enrollment_id AS "Enrollment ID",
    s.student_id AS "Student ID",
    s.full_name AS "Student Name",
    c.course_id AS "Course ID",
    c.course_name AS "Course Name",
    e.semester AS "Semester",
    e.marks AS "New Marks",
    e.grade_letter AS "Grade"
FROM enrollments e
JOIN students s ON s.student_id = e.student_id
JOIN courses c ON c.course_id = e.course_id
ORDER BY e.enrollment_id;