----------------TABLE CREATION------------------
CREATE TABLE Account (
    v_account_no NUMBER(10) PRIMARY KEY,
    v_name VARCHAR2(30),
    v_balance NUMBER(10, 2) 
);
--------------VALUE INSERTION-----------------
INSERT INTO Account VALUES (1, 'Anu', 5000.00);
INSERT INTO Account VALUES (2, 'Cinu', 50000.00);
INSERT INTO Account VALUES (3, 'Pinu', 55000.00);

-----------------CODE-------------------
SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE debit_credit_show (
    p_account_no IN Account.v_account_no%TYPE,
    p_amount IN NUMBER,
    p_operation IN VARCHAR2 
)
AS
    v_current_balance Account.v_balance%TYPE;
    v_new_balance Account.v_balance%TYPE;
    MIN_BALANCE CONSTANT NUMBER(10, 2) := 500.00;
    
    insufficient_funds EXCEPTION;
    
BEGIN
    SELECT v_balance INTO v_current_balance
    FROM Account
    WHERE v_account_no = p_account_no;

    p_operation := UPPER(TRIM(p_operation));

    IF p_operation = 'SHOW' THEN
        DBMS_OUTPUT.PUT_LINE('--- SHOW BALANCE ---');
        DBMS_OUTPUT.PUT_LINE('Account No: ' || p_account_no);
        DBMS_OUTPUT.PUT_LINE('Current Balance: $' || TO_CHAR(v_current_balance, 'FM99,999.00'));

    ELSIF p_operation = 'CREDIT' THEN
        v_new_balance := v_current_balance + p_amount;
        
        UPDATE Account
        SET v_balance = v_new_balance
        WHERE v_account_no = p_account_no;
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('--- CREDIT SUCCESSFUL ---');
        DBMS_OUTPUT.PUT_LINE('Credited Amount: $' || TO_CHAR(p_amount, 'FM99,999.00'));
        DBMS_OUTPUT.PUT_LINE('New Balance: $' || TO_CHAR(v_new_balance, 'FM99,999.00'));

    ELSIF p_operation = 'DEBIT' THEN
        v_new_balance := v_current_balance - p_amount;

        IF v_new_balance < MIN_BALANCE THEN
            RAISE insufficient_funds;
        END IF;
        
        UPDATE Account
        SET v_balance = v_new_balance
        WHERE v_account_no = p_account_no;
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('--- DEBIT SUCCESSFUL ---');
        DBMS_OUTPUT.PUT_LINE('Debited Amount: $' || TO_CHAR(p_amount, 'FM99,999.00'));
        DBMS_OUTPUT.PUT_LINE('New Balance: $' || TO_CHAR(v_new_balance, 'FM99,999.00'));

    ELSE
        DBMS_OUTPUT.PUT_LINE('Error: Invalid operation specified. Use DEBIT, CREDIT, or SHOW.');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Account number ' || p_account_no || ' not found.');
    
    WHEN insufficient_funds THEN
        DBMS_OUTPUT.PUT_LINE('TRANSACTION FAILED: Insufficient funds.');
        DBMS_OUTPUT.PUT_LINE('Debit requires a minimum balance of $' || TO_CHAR(MIN_BALANCE, 'FM999.00') || ' after the transaction.');
        DBMS_OUTPUT.PUT_LINE('Current Balance: $' || TO_CHAR(v_current_balance, 'FM99,999.00'));
        
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM);
END;
/
DECLARE
    v_acc_no Account.v_account_no%TYPE := &Enter_Account_Number_for_Debit;
    c_debit_amount CONSTANT NUMBER := 200;
BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- EXECUTING FIXED DEBIT (Part B) ---');
    debit_credit_show(
        p_account_no => v_acc_no,
        p_amount => c_debit_amount,
        p_operation => 'DEBIT'
    );
END;
/

DECLARE
    v_acc_no Account.v_account_no%TYPE := &Enter_Account_Number_for_Operation;
    v_op_type VARCHAR2(10) := '&Enter_Operation_Type_(DEBIT_CREDIT_SHOW)';
    v_op_amount NUMBER := &Enter_Amount_for_Operation;
BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- EXECUTING GENERAL OPERATION (Part A) ---');
    debit_credit_show(
        p_account_no => v_acc_no,
        p_amount => v_op_amount,
        p_operation => v_op_type
    );
END;
/
