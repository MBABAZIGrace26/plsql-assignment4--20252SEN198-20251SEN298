INSERT INTO departments VALUES (10, 'Computer Science');
INSERT INTO departments VALUES (20, 'Mathematics');

INSERT INTO students VALUES (1001, 'Alice Mukamana',      'alice@auca.ac.rw',   10, 'ACTIVE');
INSERT INTO students VALUES (1002, 'Eric Habimana',       'eric@auca.ac.rw',    10, 'ACTIVE');
INSERT INTO students VALUES (1003, 'Grace Uwase',         'grace@auca.ac.rw',   10, 'ACTIVE');
INSERT INTO students VALUES (1004, 'David Nkurunziza',    'david@auca.ac.rw',   20, 'ACTIVE');
INSERT INTO students VALUES (1005, 'Sandrine Ingabire',   'sandrine@auca.ac.rw',10, 'ACTIVE');
INSERT INTO students VALUES (1006, 'Patrick Niyonzima',   'patrick@auca.ac.rw', 10, 'ACTIVE');
INSERT INTO students VALUES (1007, 'Claudine Mutesi',     'claudine@auca.ac.rw',10, 'SUSPENDED');
INSERT INTO students VALUES (1008, 'Olivier Kamanzi',     'olivier@auca.ac.rw', 10, 'ACTIVE');
INSERT INTO students VALUES (1009, 'Jean Claude Uwimana', 'jc1@auca.ac.rw',     20, 'ACTIVE');
INSERT INTO students VALUES (1010, 'Jean Claude Uwimana', 'jc2@auca.ac.rw',     10, 'ACTIVE');

INSERT INTO courses VALUES ('INSY8311', 'Database Development with PL/SQL', 3, 10, 40);
INSERT INTO courses VALUES ('INSY8312', 'Systems Analysis',                 3, 10, 40);
INSERT INTO courses VALUES ('MATH101',  'Calculus I',                       4, 20, 40);
INSERT INTO courses VALUES ('CAP2',     'Capstone Seminar',                 2, 10, 2);

INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1001, 'INSY8311', '2026-A', 85);
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1002, 'INSY8311', '2026-A', 92);
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1003, 'INSY8311', '2026-A', 58);
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1004, 'INSY8311', '2026-A', 45);
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1005, 'INSY8311', '2026-A', 73);
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1006, 'INSY8311', '2026-A', 99.5);
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1007, 'INSY8311', '2026-A', NULL);
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1001, 'INSY8312', '2026-A', 78);
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1002, 'INSY8312', '2026-A', 88);
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1003, 'INSY8312', '2026-A', 64);
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1001, 'MATH101', '2026-A', 91);
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1004, 'MATH101', '2026-A', 52);
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1001, 'CAP2', '2026-A', NULL);
INSERT INTO enrollments (student_id, course_id, semester, marks) VALUES (1002, 'CAP2', '2026-A', NULL);

UPDATE enrollments
   SET grade_letter = CASE WHEN marks >= 90 THEN 'A' WHEN marks >= 80 THEN 'B'
                           WHEN marks >= 70 THEN 'C' WHEN marks >= 60 THEN 'D' ELSE 'F' END
 WHERE marks IS NOT NULL;

COMMIT;