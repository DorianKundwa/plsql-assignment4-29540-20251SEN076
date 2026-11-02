CREATE OR REPLACE PROCEDURE proc_register_employee (
    p_emp_id     IN     employees.employee_id%TYPE,
    p_first_name IN     employees.first_name%TYPE,
    p_last_name  IN     employees.last_name%TYPE,
    p_email      IN     employees.email%TYPE,
    p_phone      IN     employees.phone_number%TYPE,
    p_dept_id    IN     employees.department_id%TYPE,
    p_role_id    IN     employees.role_id%TYPE,
    p_salary     IN OUT employees.salary%TYPE,
    p_bonus      IN     employees.bonus%TYPE,
    p_status_msg    OUT VARCHAR2
) IS
    v_role_rec roles%ROWTYPE;
    e_salary_out_of_bounds EXCEPTION;
BEGIN
    SELECT * INTO v_role_rec
    FROM roles
    WHERE role_id = p_role_id;

    IF p_salary < v_role_rec.min_salary THEN
        RAISE e_salary_out_of_bounds;
    ELSIF p_salary > v_role_rec.max_salary THEN
        DBMS_OUTPUT.PUT_LINE('Notice: Salary capped at maximum for role (' || v_role_rec.max_salary || ').');
        p_salary := v_role_rec.max_salary;
    END IF;

    SAVEPOINT before_emp_dml;

    INSERT INTO employees (
        employee_id, first_name, last_name, email, phone_number,
        hire_date, department_id, role_id, salary, bonus
    ) VALUES (
        p_emp_id, p_first_name, p_last_name, p_email, p_phone,
        SYSDATE, p_dept_id, p_role_id, p_salary, p_bonus
    );

    IF SQL%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('INSERT Success -> Rows inserted (SQL%ROWCOUNT): ' || SQL%ROWCOUNT);
    END IF;

    UPDATE employees
    SET bonus = NVL(bonus, 0) + 500
    WHERE employee_id = p_emp_id;

    IF SQL%NOTFOUND THEN
        DBMS_OUTPUT.PUT_LINE('Warning: Welcome bonus update affected no rows.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('UPDATE Success -> Welcome bonus applied. Rows updated: ' || SQL%ROWCOUNT);
    END IF;

    DELETE FROM attendance
    WHERE employee_id = p_emp_id AND status = 'Absent';

    IF SQL%NOTFOUND THEN
        DBMS_OUTPUT.PUT_LINE('DELETE Check -> SQL%NOTFOUND is TRUE (0 stale attendance rows removed).');
    ELSE
        DBMS_OUTPUT.PUT_LINE('DELETE Check -> Removed ' || SQL%ROWCOUNT || ' stale attendance rows.');
    END IF;

    IF NOT SQL%ISOPEN THEN
        DBMS_OUTPUT.PUT_LINE('Cursor Check -> SQL%ISOPEN is FALSE (Implicit cursor closed automatically).');
    END IF;

    COMMIT;
    p_status_msg := 'SUCCESS: Employee ' || p_first_name || ' ' || p_last_name || ' registered with salary $' || p_salary;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_status_msg := 'ERROR: Role ID ' || p_role_id || ' does not exist.';
        DBMS_OUTPUT.PUT_LINE(p_status_msg);
    WHEN e_salary_out_of_bounds THEN
        p_status_msg := 'ERROR: Salary ($' || p_salary || ') is below minimum ($' || v_role_rec.min_salary || ') for role ' || v_role_rec.role_name;
        DBMS_OUTPUT.PUT_LINE(p_status_msg);
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK TO before_emp_dml;
        p_status_msg := 'ERROR: Duplicate Employee ID (' || p_emp_id || ') or Email (' || p_email || ').';
        DBMS_OUTPUT.PUT_LINE(p_status_msg);
    WHEN OTHERS THEN
        ROLLBACK;
        p_status_msg := 'UNEXPECTED ERROR: ' || SQLERRM;
        DBMS_OUTPUT.PUT_LINE(p_status_msg);
END proc_register_employee;
/
