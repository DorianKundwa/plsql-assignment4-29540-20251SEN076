SET SERVEROUTPUT ON SIZE UNLIMITED;

SELECT e.employee_id,
       e.first_name || ' ' || e.last_name AS employee_name,
       e.salary AS base_salary,
       fn_get_total_allowance(e.role_id) AS role_allowance,
       fn_calc_income_tax(e.salary + fn_get_total_allowance(e.role_id)) AS monthly_tax
FROM employees e
WHERE e.department_id = 10;

BEGIN
    DBMS_OUTPUT.PUT_LINE(fn_get_emp_financial_summary(101));
    DBMS_OUTPUT.PUT_LINE(fn_get_emp_financial_summary(102));
END;
/

DECLARE
    v_salary NUMBER := 65000;
    v_status VARCHAR2(200);
BEGIN
    proc_register_employee(
        p_emp_id     => 108,
        p_first_name => 'Kevin',
        p_last_name  => 'Gatete',
        p_email      => 'kevin.gatete@auca.ac.rw',
        p_phone      => '0788100108',
        p_dept_id    => 10,
        p_role_id    => 1,
        p_salary     => v_salary,
        p_bonus      => 2000,
        p_status_msg => v_status
    );
    DBMS_OUTPUT.PUT_LINE('Output Status: ' || v_status);
END;
/

BEGIN
    proc_dept_payroll_report(10);
END;
/

DECLARE
    v_updated_count NUMBER;
BEGIN
    proc_bulk_salary_increment(
        p_department_id => 20,
        p_increment_pct => 10,
        p_rows_updated  => v_updated_count
    );
    DBMS_OUTPUT.PUT_LINE('Caller verified rows updated: ' || v_updated_count);
END;
/

BEGIN
    proc_bulk_insert_attendance(p_include_error_rows => FALSE);
END;
/
