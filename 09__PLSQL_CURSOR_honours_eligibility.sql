SET SERVEROUTPUT ON;
CREATE TABLE student (
    roll_no NUMBER PRIMARY KEY, 
    name VARCHAR2(100),
    s1_marks NUMBER,
    s2_marks NUMBER
);
INSERT INTO student VALUES (1, 'Lanu', 10, 10);
INSERT INTO student VALUES (2, 'Cinu', 5, 5);
INSERT INTO student VALUES (3, 'Nanu', 10, 10);
COMMIT;


DECLARE
    -- Declared variables to match the cursor select list--
    v_roll_no       student.roll_no%TYPE;
    v_name          student.name%TYPE;
    v_s1_marks      student.s1_marks%TYPE;
    v_s2_marks      student.s2_marks%TYPE;
    -- Variables for logic results--
    v_honour_status VARCHAR2(20); 
    v_highest_grade NUMBER;    
    -- Cursor is now complete, ordered by roll_no--
    CURSOR honour_cursor IS
        SELECT roll_no, name, s1_marks, s2_marks
        FROM student
        ORDER BY roll_no; 
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Student Honour Status Report ---');
    OPEN honour_cursor;
    LOOP
        FETCH honour_cursor INTO v_roll_no, v_name, v_s1_marks, v_s2_marks;
        EXIT WHEN honour_cursor%NOTFOUND;
        -- Logic 1: Highest Grade--
        IF (v_s1_marks > v_s2_marks) THEN
            v_highest_grade := v_s1_marks;
        ELSE
            v_highest_grade := v_s2_marks;
        END IF;
        -- Logic 2: Honour Status--
        IF ((v_s1_marks + v_s2_marks) > 12) THEN
            v_honour_status := 'Eligible';
        ELSE
            v_honour_status := 'Not Eligible';
        END IF;
        
        DBMS_OUTPUT.PUT_LINE(
            'Roll no : ' || RPAD(v_roll_no, 2) || 
            ' | Name : ' || RPAD(v_name, 5) || 
            ' | Highest grade : ' || RPAD(v_highest_grade, 2) ||
            ' | Honour status : ' || v_honour_status 
        );
        
    END LOOP;
    CLOSE honour_cursor;
    DBMS_OUTPUT.PUT_LINE('------------------------------------');
END;
/
