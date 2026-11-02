CREATE OR REPLACE FUNCTION find_student_id_by_name (p_name IN students.full_name%TYPE)
RETURN students.student_id%TYPE
AS
  v_id students.student_id%TYPE;
BEGIN
  SELECT student_id INTO v_id FROM students WHERE UPPER(full_name) = UPPER(p_name);
  RETURN v_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20110, 'No student named "' || p_name || '".');
  WHEN TOO_MANY_ROWS THEN
    RAISE_APPLICATION_ERROR(-20111, 'More than one student named "' || p_name || '"; search by ID instead.');
END find_student_id_by_name;
/
SHOW ERRORS

SELECT
    student_id,
    full_name
FROM students
ORDER BY full_name;