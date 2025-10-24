--------------------TABLE CREATION--------------------
CREATE TABLE student (
id NUMBER PRIMARY KEY;
name VARCHAR2 ; 
sub1 NUMBER ;
sub2 NUMBER ; 
sub3 NUMBER ;
total NUMBER ;
avg NUMBER
);
------------------------CODE--------------------------
CREATE TRIGGER total_avg_trigger
BEFORE INSERT ON student 
FOR EACH ROW
BEGIN
 IF INSERTING THEN
   :NEW.total := :NEW.sub1 + :NEW.sub2 + :NEW.sub3 ;
   :NEW.avg := (:NEW.total/3) ; 
END;
/
