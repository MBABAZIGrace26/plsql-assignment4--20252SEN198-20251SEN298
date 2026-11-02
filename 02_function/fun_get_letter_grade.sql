CREATE OR REPLACE FUNCTION get_letter_grade (
    p_marks IN NUMBER
)
RETURN VARCHAR2 DETERMINISTIC
AS
BEGIN
    IF p_marks IS NULL THEN
        RETURN NULL;

    ELSIF p_marks < 0 OR p_marks > 100 THEN
        RAISE_APPLICATION_ERROR(
            -20100,
            'Marks must be between 0 and 100, got ' || p_marks
        );

    ELSIF p_marks >= 90 THEN
        RETURN 'A';

    ELSIF p_marks >= 80 THEN
        RETURN 'B';

    ELSIF p_marks >= 70 THEN
        RETURN 'C';

    ELSIF p_marks >= 60 THEN
        RETURN 'D';

    ELSE
        RETURN 'F';
    END IF;
END get_letter_grade;
/

SELECT 95 AS marks, get_letter_grade(95) AS grade FROM dual
UNION ALL
SELECT 85, get_letter_grade(85) FROM dual
UNION ALL
SELECT 75, get_letter_grade(75) FROM dual
UNION ALL
SELECT 65, get_letter_grade(65) FROM dual
UNION ALL
SELECT 45, get_letter_grade(45) FROM dual;
