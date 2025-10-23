----------------TABLE CREATION------------------
CREATE TABLE Account (
    v_account_no NUMBER(10) PRIMARY KEY,
    v_name VARCHAR2(30),
    v_balance NUMBER(10)
);
--------------VALUE INSERTION-----------------
INSERT INTO Account VALUES (1, 'Anu', 5000);
INSERT INTO Account VALUES (2, 'Cinu', 50000);
INSERT INTO Account VALUES (3, 'Pinu', 55000);

-----------------CODE-------------------
SET SERVEROUTPUT ON
--function dc--
CREATE OR REPLACE FUNCTION dc (p_account_no IN NUMBER)
RETURN VARCHAR2
AS
    v_account_category VARCHAR2(10);
    v_balance Account.v_balance%TYPE;
BEGIN
    SELECT v_balance INTO v_balance
    FROM Account
    WHERE v_account_no = p_account_no;

    IF v_balance > 50000 THEN
        v_account_category := 'platinum';
    ELSIF v_balance > 10000 AND v_balance <= 50000 THEN
        v_account_category := 'gold';
    ELSIF v_balance <= 10000 THEN
        v_account_category := 'silver';
    END IF;
    RETURN v_account_category;
END dc;
/

--general--
DECLARE
    v_acc_no NUMBER;
    v_name Account.v_name%TYPE;
    v_balance Account.v_balance%TYPE;
    v_category VARCHAR2(10);
BEGIN
    --Prompt the user (The client will display this message first)
    DBMS_OUTPUT.PUT_LINE('ENTER THE ACCOUNT NUMBER:');
    --  Read the user input (The client will pause and ask for input_acc_no)
    v_acc_no := &input_acc_no; 

    SELECT v_name, v_balance INTO v_name, v_balance
    FROM Account
    WHERE v_account_no = v_acc_no;
    
    DBMS_OUTPUT.PUT_LINE('Account no entered : ' || v_acc_no);
    DBMS_OUTPUT.PUT_LINE('Account name : ' || v_name); 
    DBMS_OUTPUT.PUT_LINE('Account balance : ' || v_balance); 

    --  Call the function
    v_category := dc(v_acc_no);
    
    DBMS_OUTPUT.PUT_LINE('Account category : ' || v_category); 

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: Account number ' || v_acc_no || ' not found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM);
END;
/
