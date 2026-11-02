CREATE OR REPLACE PROCEDURE proc_bulk_salary_increment (
    p_department_id IN  employees.department_id%TYPE,
    p_increment_pct IN  NUMBER,
    p_rows_updated  OUT NUMBER
) IS
    TYPE t_sal_adj_rec IS RECORD (
        emp_id     employees.employee_id%TYPE,
        first_name employees.first_name%TYPE,
        old_salary employees.salary%TYPE,
        new_salary employees.salary%TYPE
    );

    TYPE t_sal_adj_tab IS TABLE OF t_sal_adj_rec;
    v_sal_collection t_sal_adj_tab;

BEGIN
    p_rows_updated := 0;

    IF p_increment_pct IS NULL OR p_increment_pct <= 0 OR p_increment_pct > 50 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Increment percentage must be between 0.1% and 50%.');
    END IF;

    SELECT employee_id,
           first_name,
           salary AS old_salary,
           ROUND(salary * (1 + (p_increment_pct / 100)), 2) AS new_salary
    BULK COLLECT INTO v_sal_collection
    FROM employees
    WHERE department_id = p_department_id;

    IF v_sal_collection.COUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Notice: No employees found in Department ' || p_department_id || ' for bulk increment.');
        RETURN;
    END IF;

    FORALL i IN v_sal_collection.FIRST .. v_sal_collection.LAST
        UPDATE employees
        SET salary = v_sal_collection(i).new_salary
        WHERE employee_id = v_sal_collection(i).emp_id;

    p_rows_updated := SQL%ROWCOUNT;

    FOR i IN v_sal_collection.FIRST .. v_sal_collection.LAST LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Bulk Updated Emp ID ' || v_sal_collection(i).emp_id || ' (' || v_sal_collection(i).first_name || '): ' ||
            '$' || v_sal_collection(i).old_salary || ' -> $' || v_sal_collection(i).new_salary ||
            ' | Rows Affected (SQL%BULK_ROWCOUNT): ' || SQL%BULK_ROWCOUNT(i)
        );
    END LOOP;

    FORALL i IN v_sal_collection.FIRST .. v_sal_collection.LAST
        INSERT INTO payroll_audit_log (employee_id, old_salary, new_salary, operation_type)
        VALUES (
            v_sal_collection(i).emp_id,
            v_sal_collection(i).old_salary,
            v_sal_collection(i).new_salary,
            'BULK_INCREMENT_' || p_increment_pct || '%'
        );

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Total records updated and audited via FORALL: ' || p_rows_updated);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_rows_updated := 0;
        DBMS_OUTPUT.PUT_LINE('Error in proc_bulk_salary_increment: ' || SQLERRM);
        RAISE;
END proc_bulk_salary_increment;
/
