----------------TABLE CREATION------------------
CREATE TABLE Employee (
    eid NUMBER(5) PRIMARY KEY,
    ename VARCHAR2(50) NOT NULL,
    eaddress VARCHAR2(100),
    esalary NUMBER(10, 2) NOT NULL
);

--------------VALUE INSERTION-----------------
INSERT INTO Employee (eid, ename, eaddress, esalary) VALUES (1001, 'Alice Smith', '45 Park Ave', 60000.00);
INSERT INTO Employee (eid, ename, eaddress, esalary) VALUES (1002, 'Bob Johnson', '12 Elm St', 75000.00);
INSERT INTO Employee (eid, ename, eaddress, esalary) VALUES (1003, 'Charlie Brown', '9 High Rd', 52500.00);

-----------------CODE (PACKAGE SPECIFICATION)-------------------
SET SERVEROUTPUT ON

-- 1. PACKAGE SPECIFICATION: Defines the interface (what the package does)
CREATE OR REPLACE PACKAGE employee_pkg AS
    -- Procedure to add a new employee
    PROCEDURE add_employee(
        p_id IN Employee.eid%TYPE,
        p_name IN Employee.ename%TYPE,
        p_address IN Employee.eaddress%TYPE,
        p_salary IN Employee.esalary%TYPE
    );
    
    -- Procedure to delete an employee by ID
    PROCEDURE delete_employee(
        p_id IN Employee.eid%TYPE
    );
    
    -- Procedure to list all employees
    PROCEDURE list_all_employees;
    
    -- Function to return salary of an employee up on a given id
    FUNCTION get_salary(
        p_id IN Employee.eid%TYPE
    )
    RETURN Employee.esalary%TYPE;
END employee_pkg;
/

-----------------CODE (PACKAGE BODY)-------------------
-- 2. PACKAGE BODY: Implements the logic for the defined interface
CREATE OR REPLACE PACKAGE BODY employee_pkg AS

    -- Implementation of ADD_EMPLOYEE
    PROCEDURE add_employee(
        p_id IN Employee.eid%TYPE,
        p_name IN Employee.ename%TYPE,
        p_address IN Employee.eaddress%TYPE,
        p_salary IN Employee.esalary%TYPE
    )
    AS
    BEGIN
        INSERT INTO Employee (eid, ename, eaddress, esalary)
        VALUES (p_id, p_name, p_address, p_salary);
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('SUCCESS: Employee ID ' || p_id || ' (' || p_name || ') added.');
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: Employee ID ' || p_id || ' already exists. Cannot add.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR adding employee: ' || SQLERRM);
    END add_employee;

    -- Implementation of DELETE_EMPLOYEE
    PROCEDURE delete_employee(
        p_id IN Employee.eid%TYPE
    )
    AS
        v_rows_deleted NUMBER := 0;
    BEGIN
        DELETE FROM Employee
        WHERE eid = p_id;
        
        v_rows_deleted := SQL%ROWCOUNT;
        
        IF v_rows_deleted > 0 THEN
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('SUCCESS: Employee ID ' || p_id || ' deleted.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('WARNING: Employee ID ' || p_id || ' not found. No record deleted.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR deleting employee: ' || SQLERRM);
    END delete_employee;

    -- Implementation of LIST_ALL_EMPLOYEES
    PROCEDURE list_all_employees
    AS
        CURSOR c_emp IS
            SELECT eid, ename, eaddress, esalary
            FROM Employee
            ORDER BY eid;
    BEGIN
        DBMS_OUTPUT.PUT_LINE(CHR(10) || '---------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('EID  | Name          | Address        | Salary');
        DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');
        
        FOR emp_rec IN c_emp LOOP
            DBMS_OUTPUT.PUT_LINE(
                RPAD(emp_rec.eid, 5) || ' | ' ||
                RPAD(emp_rec.ename, 14) || ' | ' ||
                RPAD(emp_rec.eaddress, 15) || ' | $' ||
                TO_CHAR(emp_rec.esalary, 'FM99,999.00')
            );
        END LOOP;
        
        IF c_emp%NOTFOUND AND c_emp%ROWCOUNT = 0 THEN
             DBMS_OUTPUT.PUT_LINE('       (No employees found in the database)');
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('---------------------------------------------------');
    END list_all_employees;

    -- Implementation of GET_SALARY (Function)
    FUNCTION get_salary(
        p_id IN Employee.eid%TYPE
    )
    RETURN Employee.esalary%TYPE
    AS
        v_salary Employee.esalary%TYPE;
    BEGIN
        SELECT esalary INTO v_salary
        FROM Employee
        WHERE eid = p_id;
        
        RETURN v_salary;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Return 0 or NULL to indicate employee not found
            DBMS_OUTPUT.PUT_LINE('ERROR: Employee ID ' || p_id || ' not found.');
            RETURN NULL; 
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR fetching salary: ' || SQLERRM);
            RETURN NULL; 
    END get_salary;

END employee_pkg;
/

-----------------CODE (TEST BLOCK)-------------------
-- 3. Demonstration Block
DECLARE
    v_test_id Employee.eid%TYPE := 1002;
    v_new_id Employee.eid%TYPE := 1004;
    v_salary Employee.esalary%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '=========================================');
    DBMS_OUTPUT.PUT_LINE('   EMPLOYEE PACKAGE DEMONSTRATION');
    DBMS_OUTPUT.PUT_LINE('=========================================');

    -- Test 1: List all initial employees
    DBMS_OUTPUT.PUT_LINE('--- 1. INITIAL EMPLOYEE LIST ---');
    employee_pkg.list_all_employees;

    -- Test 2: Add a new employee
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- 2. ADD EMPLOYEE ' || v_new_id || ' (David Lee) ---');
    employee_pkg.add_employee(
        p_id      => v_new_id, 
        p_name    => 'David Lee', 
        p_address => '50 Main St', 
        p_salary  => 82000.50
    );

    -- Verify addition
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- 3. EMPLOYEE LIST AFTER ADDITION ---');
    employee_pkg.list_all_employees;

    -- Test 3: Get salary of an existing employee (Function)
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- 4. GET SALARY FOR EID ' || v_test_id || ' ---');
    v_salary := employee_pkg.get_salary(p_id => v_test_id);
    IF v_salary IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Salary for EID ' || v_test_id || ': $' || TO_CHAR(v_salary, 'FM99,999.00'));
    END IF;
    
    -- Test 4: Delete an employee
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- 5. DELETE EMPLOYEE EID ' || v_test_id || ' ---');
    employee_pkg.delete_employee(p_id => v_test_id);

    -- Verify deletion
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- 6. FINAL EMPLOYEE LIST ---');
    employee_pkg.list_all_employees;

    -- Test 5: Attempt to delete a non-existent employee
    DBMS_OUTPUT.PUT_LINE(CHR(10) || '--- 7. ATTEMPT DELETE NON-EXISTENT EID 9999 ---');
    employee_pkg.delete_employee(p_id => 9999);
    
END;
/
