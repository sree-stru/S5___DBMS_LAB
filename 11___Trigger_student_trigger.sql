------------------TABLE CREATION------------------
CREATE TABLE student (
roll_no NUMBER ,
name VARCHAR2 ,
s1_grade NUMBER , 
s2_grade NUMBER 
);
-----------------------CODE-------------------------
SET SERVEROUTPUT ON ;
CREATE TRIGGER message_trigger
AFTER INSERT OR DELETE OR UPDATE ON student
FOR EACH ROW 
BEGIN
 IF UPDATING THEN 
   DBMS_OUTPUT.PUT_LINE('updated is ' || :NEW.name ) ;
 ELSIF INSERTING THEN
   DBMS_OUTPUT.PUT_LINE('inserting ' || :NEW.name ) ;
 ELSIF DELETING THEN
   DBMS_OUTPUT.PUT_LINE('deleting ' || :OLD.name) ;
 END IF;
END /

