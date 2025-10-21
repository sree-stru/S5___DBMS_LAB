-----------------TABLE CREATION------------------
CREATE TABLE students (
    student_id NUMBER PRIMARY KEY,
    name VARCHAR2(100),
    marks NUMBER(5,2)
);

--------------- VALUE INSERTION-------------------
INSERT INTO students VALUES (1, 'Alice', 78);
INSERT INTO students VALUES (2, 'Bob', 35);
INSERT INTO students VALUES (3, 'Charlie', 42);
INSERT INTO students VALUES (4, 'Diana', 28);
INSERT INTO students VALUES (5, 'Ethan', 55);

COMMIT;


------------------- CODE-------------------------
SET SERVEROUTPUT ON SIZE 1000000;

DECLARE
    v_avg_marks NUMBER(7,2);
    v_day VARCHAR2(30);
    v_date_str VARCHAR2(30);

BEGIN
    DBMS_OUTPUT.PUT_LINE('====================================================');
    DBMS_OUTPUT.PUT_LINE('              STUDENT MARKS REPORT                ');
    DBMS_OUTPUT.PUT_LINE('====================================================');

    -- Print header for student marks--
    DBMS_OUTPUT.PUT_LINE(RPAD('ID',6) || RPAD('NAME',15) || RPAD('MARKS',10));
    DBMS_OUTPUT.PUT_LINE('------------------------------------');

    -- Print each student's marks--
    FOR rec IN (SELECT student_id, name, marks FROM students ORDER BY student_id) 
    LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(rec.student_id, 6) ||
            RPAD(rec.name, 15) ||
            RPAD(NVL(TO_CHAR(rec.marks), 'NULL'), 10)
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('------------------------------------');

    SELECT AVG(marks) INTO v_avg_marks FROM students;

    DBMS_OUTPUT.PUT_LINE('------------------------------------');

    IF v_avg_marks IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('No students found in the class.');
    ELSE
      
        DBMS_OUTPUT.PUT_LINE('Class Average Marks: ' || TO_CHAR(ROUND(v_avg_marks,2)));

        IF v_avg_marks < 40 THEN
            DBMS_OUTPUT.PUT_LINE('*** ALERT: Class average is below 40. Improvement needed! ***');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Class average is satisfactory.');
        END IF;
    END IF;

    DBMS_OUTPUT.PUT_LINE('------------------------------------');


    -- Print today's day and date--
    v_day      := TO_CHAR(SYSDATE, 'fmDay');
    v_date_str := TO_CHAR(SYSDATE, 'DD-Mon-YYYY');

    DBMS_OUTPUT.PUT_LINE('Report Generated On: ' || v_day || ' ' || v_date_str);


    DBMS_OUTPUT.PUT_LINE('====================================================');

END;
/
