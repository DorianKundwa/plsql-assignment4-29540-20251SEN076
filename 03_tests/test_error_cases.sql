SET SERVEROUTPUT ON SIZE UNLIMITED;

DECLARE
    v_allowance NUMBER;
BEGIN
    v_allowance := fn_get_total_allowance(999);
    DBMS_OUTPUT.PUT_LINE('Returned value for invalid role: ' || v_allowance);

    DBMS_OUTPUT.PUT_LINE(fn_get_emp_financial_summary(9999));

    proc_dept_payroll_report(999);
END;
/

DECLARE
    v_low_salary NUMBER := 10000;
    v_status     VARCHAR2(200);
BEGIN
    proc_dept_payroll_report(40);

    proc_register_employee(
        p_emp_id     => 109,
        p_first_name => 'Patrick',
        p_last_name  => 'Kaka',
        p_email      => 'patrick.k@auca.ac.rw',
        p_phone      => '0788100109',
        p_dept_id    => 10,
        p_role_id    => 1,
        p_salary     => v_low_salary,
        p_bonus      => 1000,
        p_status_msg => v_status
    );
END;
/

DECLARE
    v_salary NUMBER := 55000;
    v_status VARCHAR2(200);
BEGIN
    proc_register_employee(
        p_emp_id     => 101,
        p_first_name => 'Duplicate',
        p_last_name  => 'User',
        p_email      => 'alice.uwase@auca.ac.rw',
        p_phone      => '0788000000',
        p_dept_id    => 10,
        p_role_id    => 1,
        p_salary     => v_salary,
        p_bonus      => 500,
        p_status_msg => v_status
    );
END;
/

DECLARE
    v_tax     NUMBER;
    v_updated NUMBER;
BEGIN
    BEGIN
        v_tax := fn_calc_income_tax(-5000);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Caught Expected Tax Error: ' || SQLERRM);
    END;

    BEGIN
        proc_bulk_salary_increment(10, 85, v_updated);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Caught Expected Bulk Increment Error: ' || SQLERRM);
    END;
END;
/

BEGIN
    proc_bulk_insert_attendance(p_include_error_rows => TRUE);
END;
/
