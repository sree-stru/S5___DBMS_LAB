----------------------CODE-----------------------
SET SERVEROUTPUT ON;
-- DDL: CREATE TABLE--
CREATE TABLE TRAIN (
    tno NUMBER PRIMARY KEY, 
    tname VARCHAR2(100), 
    tdate DATE,
    source VARCHAR2(50), 
    destination VARCHAR2(50), 
    seats NUMBER
);
-- DDL: CREATE SEQUENCE--
CREATE SEQUENCE train_seq
    START WITH 101
    INCREMENT BY 1
    NOCACHE;
-- DDL: CREATE TRIGGER--
CREATE OR REPLACE TRIGGER trg_train_number_auto
BEFORE INSERT ON TRAIN
FOR EACH ROW
BEGIN
    :NEW.tno := train_seq.NEXTVAL;
END;
/
--PL/SQL BLOCK--
BEGIN
    INSERT INTO TRAIN (tname, source, destination) VALUES ('Superfast Express', 'Delhi', 'Mumbai');
    DBMS_OUTPUT.PUT_LINE ('>> Inserted 1 row (Superfast Express).');
    COMMIT;
    DBMS_OUTPUT.PUT_LINE ('>> COMMIT executed. Row is permanent.');

    INSERT INTO TRAIN (tname, source, destination) VALUES ('Mountain Passenger', 'Shimla', 'Kalka');
    DBMS_OUTPUT.PUT_LINE ('>> Inserted 1 row (Mountain Passenger).');
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE ('>> ROLLBACK executed. Row is discarded.');

    DBMS_OUTPUT.PUT_LINE('--- Verification: Permanent Rows Only ---');
    FOR rec IN (SELECT tno, tname, source FROM TRAIN) 
    LOOP
        DBMS_OUTPUT.PUT_LINE ('Train: ' || rec.tno || ' | Name: ' || rec.tname || ' | Source: ' || rec.source);
    END LOOP;
END;
/
