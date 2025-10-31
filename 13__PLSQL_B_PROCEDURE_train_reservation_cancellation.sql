SET SERVEROUTPUT ON;
CREATE TABLE train (
    tno NUMBER PRIMARY KEY,
    tname VARCHAR2(100),
    tdate DATE,
    source VARCHAR2(50),
    destination VARCHAR2(50),
    total_seats NUMBER,
    available_seats NUMBER
);
INSERT INTO train (tno, tname, tdate, source, destination, total_seats, available_seats)
VALUES (101, 'Express Train', SYSDATE, 'CityA', 'CityB', 100, 50);
COMMIT;

--  PROCEDURE CREATION --
CREATE OR REPLACE PROCEDURE train_procedure
IS
    option_choice       NUMBER;
    v_tno               train.tno%TYPE;
    v_total_seats       train.total_seats%TYPE;
    v_available_seats   train.available_seats%TYPE;
    v_seats_change      NUMBER; 
    v_reserved_count    NUMBER; 
BEGIN
    DBMS_OUTPUT.PUT_LINE (CHR(10) || '--- Railway Reservation System ---');
    DBMS_OUTPUT.PUT_LINE ('1. Reservation');
    DBMS_OUTPUT.PUT_LINE ('2. Cancellation');
    DBMS_OUTPUT.PUT_LINE ('Enter your choice (1 or 2): ');
    option_choice := &input_option;
  
    -- Reservation Logic
    IF (option_choice = 1) THEN 
        DBMS_OUTPUT.PUT_LINE ( '--- Reservation ---');
        DBMS_OUTPUT.PUT_LINE ('Enter the train number: ');
        v_tno := &input_v_tno;
        DBMS_OUTPUT.PUT_LINE ('Enter the no. of seats wanted to reserve: ');
        v_seats_change := &input_v_reserved_seats;

        -- Check if train exists and lock row for update
        SELECT total_seats, available_seats
        INTO v_total_seats, v_available_seats
        FROM train
        WHERE tno = v_tno
        FOR UPDATE; 

        IF (v_seats_change <= 0) THEN
            DBMS_OUTPUT.PUT_LINE ('ERROR: Number of seats must be positive.');
        ELSIF (v_available_seats >= v_seats_change) THEN
            -- Perform Reservation Update
            UPDATE train
            SET available_seats = available_seats - v_seats_change
            WHERE tno = v_tno;
            COMMIT;
            DBMS_OUTPUT.PUT_LINE ('SUCCESS: ' || v_seats_change || ' seat(s) reserved on Train ' || v_tno || '.');
            DBMS_OUTPUT.PUT_LINE ('New Available Seats: ' || (v_available_seats - v_seats_change));
        ELSE
            DBMS_OUTPUT.PUT_LINE ('FAILURE: Only ' || v_available_seats || ' seat(s) available. Cannot reserve ' || v_seats_change || ' seats.');
        END IF;

    -- Cancellation Logic
    ELSIF (option_choice = 2) THEN 
        DBMS_OUTPUT.PUT_LINE (CHR(10) || '--- Cancellation ---');
        DBMS_OUTPUT.PUT_LINE ('Enter the train number: ');
        v_tno := &input_v_tno;
        DBMS_OUTPUT.PUT_LINE ('Enter the no. of seats wanted to cancel: ');
        v_seats_change := &input_v_cancel_seats;

        -- Check if train exists and lock row for update
        SELECT total_seats, available_seats
        INTO v_total_seats, v_available_seats
        FROM train
        WHERE tno = v_tno
        FOR UPDATE;
        
        v_reserved_count := v_total_seats - v_available_seats; 

        IF (v_seats_change <= 0) THEN
            DBMS_OUTPUT.PUT_LINE ('ERROR: Number of seats to cancel must be positive.');
        ELSIF (v_reserved_count >= v_seats_change) THEN
            -- Perform Cancellation Update
            UPDATE train
            SET available_seats = available_seats + v_seats_change
            WHERE tno = v_tno;
            COMMIT;
            DBMS_OUTPUT.PUT_LINE ('SUCCESS: ' || v_seats_change || ' seat(s) cancelled on Train ' || v_tno || '.');
            DBMS_OUTPUT.PUT_LINE ('New Available Seats: ' || (v_available_seats + v_seats_change));
        ELSE
            DBMS_OUTPUT.PUT_LINE ('FAILURE: Only ' || v_reserved_count || ' seats are currently reserved. Cannot cancel ' || v_seats_change || ' seats.');
        END IF;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Invalid choice. Please select 1 or 2.');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE ('ERROR: Train number ' || v_tno || ' not found.');
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE ('UNEXPECTED ERROR: ' || SQLERRM);
        ROLLBACK;
END train_procedure;
/
