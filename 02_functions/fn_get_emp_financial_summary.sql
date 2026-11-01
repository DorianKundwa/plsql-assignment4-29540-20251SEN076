CREATE OR REPLACE FUNCTION fn_get_emp_financial_summary (
    p_employee_id IN employees.employee_id%TYPE
) RETURN VARCHAR2 IS
    v_emp_row employees%ROWTYPE;

    TYPE t_quarterly_bonuses IS VARRAY(4) OF NUMBER(10, 2);

    TYPE t_financial_summary_rec IS RECORD (
        emp_id            employees.employee_id%TYPE,
        full_name         VARCHAR2(120),
        monthly_basic     employees.salary%TYPE,
        role_allowance    NUMBER(10, 2),
        quarterly_bonuses t_quarterly_bonuses,
        annual_gross      NUMBER(12, 2),
        annual_tax        NUMBER(12, 2),
        annual_net        NUMBER(12, 2)
    );

    v_summary       t_financial_summary_rec;
    v_total_q_bonus NUMBER(10, 2) := 0;
BEGIN
    SELECT * INTO v_emp_row
    FROM employees
    WHERE employee_id = p_employee_id;

    v_summary.emp_id         := v_emp_row.employee_id;
    v_summary.full_name      := v_emp_row.first_name || ' ' || v_emp_row.last_name;
    v_summary.monthly_basic  := v_emp_row.salary;
    v_summary.role_allowance := fn_get_total_allowance(v_emp_row.role_id);

    v_summary.quarterly_bonuses := t_quarterly_bonuses(
        v_emp_row.bonus * 0.25,
        v_emp_row.bonus * 0.25,
        v_emp_row.bonus * 0.25,
        v_emp_row.bonus * 0.25
    );

    FOR i IN 1 .. v_summary.quarterly_bonuses.COUNT LOOP
        v_total_q_bonus := v_total_q_bonus + v_summary.quarterly_bonuses(i);
    END LOOP;

    v_summary.annual_gross := (v_summary.monthly_basic + v_summary.role_allowance) * 12 + v_total_q_bonus;
    v_summary.annual_tax   := fn_calc_income_tax(v_summary.monthly_basic + v_summary.role_allowance) * 12;
    v_summary.annual_net   := v_summary.annual_gross - v_summary.annual_tax;

    RETURN 'Emp [' || v_summary.emp_id || ' - ' || v_summary.full_name || '] ' ||
           'Monthly Basic: $' || v_summary.monthly_basic || ' | ' ||
           'Monthly Allowance: $' || v_summary.role_allowance || ' | ' ||
           'Annual Bonus (4 Quarters): $' || v_total_q_bonus || ' | ' ||
           'Annual Gross: $' || v_summary.annual_gross || ' | ' ||
           'Annual Tax: $' || v_summary.annual_tax || ' | ' ||
           'Annual Net: $' || v_summary.annual_net;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'ERROR: No employee found with ID ' || p_employee_id;
    WHEN TOO_MANY_ROWS THEN
        RETURN 'ERROR: Multiple employees matched ID ' || p_employee_id;
    WHEN OTHERS THEN
        RETURN 'ERROR: ' || SQLERRM;
END fn_get_emp_financial_summary;
/
