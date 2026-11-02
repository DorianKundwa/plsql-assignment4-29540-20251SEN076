CREATE OR REPLACE PROCEDURE proc_dept_payroll_report (
    p_department_id IN departments.department_id%TYPE
) IS
    TYPE t_emp_payroll_rec IS RECORD (
        emp_id       employees.employee_id%TYPE,
        full_name    VARCHAR2(120),
        role_name    roles.role_name%TYPE,
        base_salary  employees.salary%TYPE,
        allowances   NUMBER(10, 2),
        tax_amount   NUMBER(10, 2),
        net_salary   NUMBER(10, 2)
    );

    v_emp_rec t_emp_payroll_rec;

    TYPE t_payroll_assoc_array IS TABLE OF t_emp_payroll_rec INDEX BY PLS_INTEGER;
    v_payroll_cache t_payroll_assoc_array;

    CURSOR c_dept_emps (cp_dept_id NUMBER) IS
        SELECT e.employee_id,
               e.first_name || ' ' || e.last_name AS full_name,
               r.role_name,
               e.salary AS base_salary,
               fn_get_total_allowance(e.role_id) AS allowances,
               fn_calc_income_tax(e.salary + fn_get_total_allowance(e.role_id)) AS tax_amount,
               (e.salary + fn_get_total_allowance(e.role_id)) -
               fn_calc_income_tax(e.salary + fn_get_total_allowance(e.role_id)) AS net_salary
        FROM employees e
        JOIN roles r ON e.role_id = r.role_id
        WHERE e.department_id = cp_dept_id
        ORDER BY e.employee_id;

    CURSOR c_dept_attendance (cp_dept_id NUMBER) IS
        SELECT a.employee_id, a.attendance_date, a.status
        FROM attendance a
        JOIN employees e ON a.employee_id = e.employee_id
        WHERE e.department_id = cp_dept_id
        ORDER BY a.attendance_date DESC;

    v_dept_name departments.department_name%TYPE;
    v_total_net NUMBER(12, 2) := 0;
    e_empty_dept EXCEPTION;
BEGIN
    SELECT department_name INTO v_dept_name
    FROM departments
    WHERE department_id = p_department_id;

    DBMS_OUTPUT.PUT_LINE('=================================================================');
    DBMS_OUTPUT.PUT_LINE('PAYROLL REPORT FOR DEPARTMENT: ' || UPPER(v_dept_name) || ' (ID: ' || p_department_id || ')');
    DBMS_OUTPUT.PUT_LINE('=================================================================');

    OPEN c_dept_emps(p_department_id);
    IF c_dept_emps%ISOPEN THEN
        DBMS_OUTPUT.PUT_LINE('[Cursor Status: c_dept_emps opened successfully]');
    END IF;

    LOOP
        FETCH c_dept_emps INTO v_emp_rec;
        EXIT WHEN c_dept_emps%NOTFOUND;

        v_payroll_cache(v_emp_rec.emp_id) := v_emp_rec;
        v_total_net := v_total_net + v_emp_rec.net_salary;

        DBMS_OUTPUT.PUT_LINE(
            'Row #' || c_dept_emps%ROWCOUNT || ' | ID: ' || v_emp_rec.emp_id ||
            ' | Name: ' || RPAD(v_emp_rec.full_name, 18) ||
            ' | Role: ' || RPAD(v_emp_rec.role_name, 22) ||
            ' | Base: $' || v_emp_rec.base_salary ||
            ' | Allow: $' || v_emp_rec.allowances ||
            ' | Tax: $' || v_emp_rec.tax_amount ||
            ' | Net: $' || v_emp_rec.net_salary
        );
    END LOOP;

    IF c_dept_emps%ROWCOUNT = 0 THEN
        CLOSE c_dept_emps;
        RAISE e_empty_dept;
    END IF;

    CLOSE c_dept_emps;

    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Total Department Monthly Net Payroll: $' || v_total_net);
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('RECENT ATTENDANCE LOGS (Processed via Cursor FOR Loop & Associative Array Lookup):');

    FOR att_rec IN c_dept_attendance(p_department_id) LOOP
        IF v_payroll_cache.EXISTS(att_rec.employee_id) THEN
            DBMS_OUTPUT.PUT_LINE(
                ' -> Date: ' || TO_CHAR(att_rec.attendance_date, 'YYYY-MM-DD') ||
                ' | Employee: ' || RPAD(v_payroll_cache(att_rec.employee_id).full_name, 18) ||
                ' | Status: ' || att_rec.status
            );
        END IF;
    END LOOP;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Department ID ' || p_department_id || ' does not exist.');
    WHEN e_empty_dept THEN
        DBMS_OUTPUT.PUT_LINE('WARNING: Department "' || v_dept_name || '" (ID: ' || p_department_id || ') currently has 0 employees.');
    WHEN OTHERS THEN
        IF c_dept_emps%ISOPEN THEN
            CLOSE c_dept_emps;
        END IF;
        DBMS_OUTPUT.PUT_LINE('UNEXPECTED ERROR in proc_dept_payroll_report: ' || SQLERRM);
END proc_dept_payroll_report;
/
