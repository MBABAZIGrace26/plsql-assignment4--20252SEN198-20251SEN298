CREATE OR REPLACE PROCEDURE bulk_enroll_students (
  p_course_id   IN  courses.course_id%TYPE,
  p_semester    IN  enrollments.semester%TYPE,
  p_student_ids IN  t_id_list,
  p_inserted    OUT PLS_INTEGER,
  p_failed      OUT PLS_INTEGER
) AS
  e_bulk_errors EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_bulk_errors, -24381);
BEGIN
  p_inserted := 0;
  p_failed   := 0;
  IF p_student_ids IS NULL OR p_student_ids.COUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20030, 'Student list is empty.');
  END IF;

  FORALL i IN 1 .. p_student_ids.COUNT SAVE EXCEPTIONS
    INSERT INTO enrollments (student_id, course_id, semester)
    VALUES (p_student_ids(i), p_course_id, p_semester);

  p_inserted := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('Bulk enroll OK: ' || p_inserted || ' rows inserted.');
EXCEPTION
  WHEN e_bulk_errors THEN
    p_inserted := SQL%ROWCOUNT;
    p_failed   := SQL%BULK_EXCEPTIONS.COUNT;
    FOR j IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
      DBMS_OUTPUT.PUT_LINE('  Failed student ' || p_student_ids(SQL%BULK_EXCEPTIONS(j).ERROR_INDEX) ||
                           ': ' || SQLERRM(-SQL%BULK_EXCEPTIONS(j).ERROR_CODE));
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Bulk enroll finished: ' || p_inserted || ' inserted, ' || p_failed || ' failed.');
  WHEN OTHERS THEN
    IF SQLCODE NOT BETWEEN -20999 AND -20000 THEN
      DBMS_OUTPUT.PUT_LINE('bulk_enroll_students unexpected error: ' || SQLERRM);
    END IF;
    RAISE;
END bulk_enroll_students;
/
SHOW ERRORS

SELECT
    enrollment_id,
    student_id,
    course_id,
    semester,
    marks,
    grade_letter
FROM enrollments
ORDER BY enrollment_id;