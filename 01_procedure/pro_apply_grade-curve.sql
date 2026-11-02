CREATE OR REPLACE PROCEDURE apply_grade_curve (
  p_course_id IN  courses.course_id%TYPE,
  p_semester  IN  enrollments.semester%TYPE,
  p_bonus     IN  NUMBER,
  p_updated   OUT PLS_INTEGER,
  p_failed    OUT PLS_INTEGER
) AS
  TYPE t_num_tab    IS TABLE OF NUMBER;
  TYPE t_letter_tab IS TABLE OF enrollments.grade_letter%TYPE;
  v_ids     t_id_list;
  v_old     t_num_tab;
  v_new     t_num_tab    := t_num_tab();
  v_letters t_letter_tab := t_letter_tab();
  e_bulk_errors EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_bulk_errors, -24381);   -- links the name to ORA-24381
BEGIN
  p_updated := 0;
  p_failed  := 0;
  IF p_bonus IS NULL OR p_bonus NOT BETWEEN -20 AND 20 THEN
    RAISE_APPLICATION_ERROR(-20040, 'Bonus must be between -20 and 20.');
  END IF;

  -- BULK COLLECT: all rows into collections in ONE trip
  SELECT enrollment_id, marks
    BULK COLLECT INTO v_ids, v_old
    FROM enrollments
   WHERE course_id = p_course_id AND semester = p_semester AND marks IS NOT NULL
   ORDER BY enrollment_id;

  IF v_ids.COUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20041, 'No graded enrollments for ' || p_course_id || ' in ' || p_semester || '.');
  END IF;

  v_new.EXTEND(v_ids.COUNT);
  v_letters.EXTEND(v_ids.COUNT);
  FOR i IN 1 .. v_ids.COUNT LOOP
    v_new(i) := v_old(i) + p_bonus;
    IF v_new(i) BETWEEN 0 AND 100 THEN
      v_letters(i) := get_letter_grade(v_new(i));
    ELSE
      v_letters(i) := NULL;     -- row will be rejected by ck_marks and reported
    END IF;
  END LOOP;

  -- FORALL: all updates in ONE trip, SAVE EXCEPTIONS = keep going after a bad row
  FORALL i IN 1 .. v_ids.COUNT SAVE EXCEPTIONS
    UPDATE enrollments
       SET marks = v_new(i), grade_letter = v_letters(i)
     WHERE enrollment_id = v_ids(i);

  p_updated := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('Curve applied to ' || p_updated || ' enrollments.');
EXCEPTION
  WHEN e_bulk_errors THEN
    p_updated := SQL%ROWCOUNT;
    p_failed  := SQL%BULK_EXCEPTIONS.COUNT;
    FOR j IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
      DBMS_OUTPUT.PUT_LINE('  Failed enrollment ' || v_ids(SQL%BULK_EXCEPTIONS(j).ERROR_INDEX) ||
                           ' (new marks ' || v_new(SQL%BULK_EXCEPTIONS(j).ERROR_INDEX) || '): ' ||
                           SQLERRM(-SQL%BULK_EXCEPTIONS(j).ERROR_CODE));
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Curve finished: ' || p_updated || ' updated, ' || p_failed || ' failed.');
  WHEN OTHERS THEN
    IF SQLCODE NOT BETWEEN -20999 AND -20000 THEN
      DBMS_OUTPUT.PUT_LINE('apply_grade_curve unexpected error: ' || SQLERRM);
    END IF;
    RAISE;
END apply_grade_curve;
/
SHOW ERRORS
SELECT
    course_id,
    semester,
    grade_letter,
    COUNT(*) AS total_students
FROM enrollments
WHERE grade_letter IS NOT NULL
GROUP BY course_id, semester, grade_letter
ORDER BY course_id, semester, grade_letter;