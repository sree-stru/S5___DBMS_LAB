----------------TABLE CREATION------------------
CREATE TABLE Consumer (
    c_no NUMBER(5) PRIMARY KEY,
    c_name VARCHAR2(50),
    c_address VARCHAR2(100)
);

--------------VALUE INSERTION-----------------
INSERT INTO Consumer (c_no, c_name, c_address) VALUES (101, 'Anu Sharma', 'Mumbai');
INSERT INTO Consumer (c_no, c_name, c_address) VALUES (102, 'Bhavin Patel', 'Pune');
INSERT INTO Consumer (c_no, c_name, c_address) VALUES (103, 'Chetan Yadav', 'Delhi');

-----------------CODE-------------------
SET SERVEROUTPUT ON

DECLARE
    v_consumer_no Consumer.c_no%TYPE := &Enter_Consumer_Number;
    v_present_reading NUMBER := &Enter_Present_Reading;
    v_past_reading NUMBER := &Enter_Past_Reading;
    
    v_units_consumed NUMBER;
    v_total_bill_amount NUMBER(10, 2) := 0;
    
    CURSOR c_consumer IS
        SELECT c_name, c_address
        FROM Consumer
        WHERE c_no = v_consumer_no;
        
    v_consumer_rec c_consumer%ROWTYPE;

    CHARGE_1_100 CONSTANT NUMBER(4, 2) := 5.00;
    CHARGE_101_300 CONSTANT NUMBER(4, 2) := 7.50;
    CHARGE_301_500 CONSTANT NUMBER(4, 2) := 15.00;
    CHARGE_OVER_500 CONSTANT NUMBER(4, 2) := 22.50;
    
    v_remaining_units NUMBER;
    v_slab_units NUMBER;

BEGIN
    IF v_present_reading < v_past_reading THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Present reading (' || v_present_reading || ') cannot be less than past reading (' || v_past_reading || ').');
        RETURN;
    END IF;
    
    v_units_consumed := v_present_reading - v_past_reading;
    v_remaining_units := v_units_consumed;

    OPEN c_consumer;
    FETCH c_consumer INTO v_consumer_rec;
    
    IF c_consumer%NOTFOUND THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Consumer number ' || v_consumer_no || ' not found.');
        CLOSE c_consumer;
        RETURN;
    END IF;
    
    CLOSE c_consumer;

    DBMS_OUTPUT.PUT_LINE(CHR(10) || '---------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('          ELECTRICITY BILL STATEMENT         ');
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Consumer No: ' || v_consumer_no);
    DBMS_OUTPUT.PUT_LINE('Name: ' || v_consumer_rec.c_name);
    DBMS_OUTPUT.PUT_LINE('Address: ' || v_consumer_rec.c_address);
    DBMS_OUTPUT.PUT_LINE('Units Consumed: ' || v_units_consumed);
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Charge Breakdown:');

   
    IF v_remaining_units > 500 THEN
        v_slab_units := v_remaining_units - 500;
        v_total_bill_amount := v_total_bill_amount + (v_slab_units * CHARGE_OVER_500);
        DBMS_OUTPUT.PUT_LINE('  ' || v_slab_units || ' units @ $' || CHARGE_OVER_500 || '/unit = $' || (v_slab_units * CHARGE_OVER_500));
        v_remaining_units := 500;
    END IF;
    
    IF v_remaining_units > 300 THEN
        v_slab_units := v_remaining_units - 300;
        v_total_bill_amount := v_total_bill_amount + (v_slab_units * CHARGE_301_500);
        DBMS_OUTPUT.PUT_LINE('  ' || v_slab_units || ' units @ $' || CHARGE_301_500 || '/unit = $' || (v_slab_units * CHARGE_301_500));
        v_remaining_units := 300; 
    END IF;

    IF v_remaining_units > 100 THEN
        v_slab_units := v_remaining_units - 100;
        v_total_bill_amount := v_total_bill_amount + (v_slab_units * CHARGE_101_300);
        DBMS_OUTPUT.PUT_LINE('  ' || v_slab_units || ' units @ $' || CHARGE_101_300 || '/unit = $' || (v_slab_units * CHARGE_101_300));
        v_remaining_units := 100; 
    END IF;
    
    IF v_remaining_units > 0 THEN
        v_slab_units := v_remaining_units;
        v_total_bill_amount := v_total_bill_amount + (v_slab_units * CHARGE_1_100);
        DBMS_OUTPUT.PUT_LINE('  ' || v_slab_units || ' units @ $' || CHARGE_1_100 || '/unit = $' || (v_slab_units * CHARGE_1_100));
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('TOTAL BILL AMOUNT: $' || TO_CHAR(v_total_bill_amount, 'FM99,999.00'));
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------');
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Consumer number ' || v_consumer_no || ' not found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM);
END;
/
