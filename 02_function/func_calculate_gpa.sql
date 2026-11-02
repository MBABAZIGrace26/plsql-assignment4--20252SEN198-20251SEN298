CREATE OR REPLACE FUNCTION calculate_gpa (p_student_id IN students.student_id%TYPE)
RETURN NUMBER
AS
  v_id           students.student_id%TYPE;
  v_points       NUMBER := 0;
  v_credits      NUMBER := 0;
  v_grade_points NUMBER;
  e_no_grades    EXCEPTION;

  -- explicit cursor declared in the declaration section
  CURSOR c_grades IS
    SELECT c.credits, e.grade_letter
      FROM enrollments e
      JOIN courses c ON c.course_id = e.course_id
     WHERE e.student_id = p_student_id
       AND e.grade_letter IS NOT NULL;
BEGIN
  SELECT student_id INTO v_id FROM students WHERE student_id = p_student_id;

  -- cursor FOR loop: opens, fetches and closes automatically
  FOR r IN c_grades LOOP
    v_grade_points := CASE r.grade_letter
                        WHEN 'A' THEN 4 WHEN 'B' THEN 3 WHEN 'C' THEN 2
                        WHEN 'D' THEN 1 ELSE 0 END;
    v_points  := v_points  + v_grade_points * r.credits;
    v_credits := v_credits + r.credits;
  END LOOP;

  IF v_credits = 0 THEN
    RAISE e_no_grades;
  END IF;
  RETURN ROUND(v_points / v_credits, 2);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20101, 'Student ' || p_student_id || ' does not exist.');
  WHEN e_no_grades THEN
    RAISE_APPLICATION_ERROR(-20102, 'Student ' || p_student_id || ' has no graded courses; GPA undefined.');
END calculate_gpa;
/
SHOW ERRORS


CREATE OR REPLACE FUNCTION calculate_gpa (
    p_student_id IN students.student_id%TYPE
)
RETURN NUMBER
AS
    v_id           students.student_id%TYPE;
    v_points       NUMBER := 0;
    v_credits      NUMBER := 0;
    v_grade_points NUMBER;
    e_no_grades    EXCEPTION;

    CURSOR c_grades IS
        SELECT c.credits, e.grade_letter
        FROM enrollments e
        JOIN courses c ON c.course_id = e.course_id
        WHERE e.student_id = p_student_id
          AND e.grade_letter IS NOT NULL;

BEGIN
    SELECT student_id
    INTO v_id
    FROM students
    WHERE student_id = p_student_id;

    FOR r IN c_grades LOOP
        v_grade_points := CASE r.grade_letter
            WHEN 'A' THEN 4
            WHEN 'B' THEN 3
            WHEN 'C' THEN 2
            WHEN 'D' THEN 1
            ELSE 0
        END;

        v_points := v_points + (v_grade_points * r.credits);
        v_credits := v_credits + r.credits;
    END LOOP;

    IF v_credits = 0 THEN
        RAISE e_no_grades;
    END IF;

    RETURN ROUND(v_points / v_credits, 2);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(
            -20101,
            'Student ' || p_student_id || ' does not exist.'
        );

    WHEN e_no_grades THEN
        RAISE_APPLICATION_ERROR(
            -20102,
            'Student ' || p_student_id || ' has no graded courses; GPA undefined.'
        );
END calculate_gpa;
/

SELECT
    s.student_id,
    s.full_name,
    calculate_gpa(s.student_id) AS GPA
FROM students s
WHERE EXISTS (
    SELECT 1
    FROM enrollments e
    WHERE e.student_id = s.student_id
      AND e.grade_letter IS NOT NULL
)
ORDER BY s.student_id;