CREATE OR REPLACE FUNCTION fn_calc_income_tax (
    p_gross_income IN NUMBER
) RETURN NUMBER
DETERMINISTIC
IS
    v_tax NUMBER(10, 2);
BEGIN
    IF p_gross_income IS NULL OR p_gross_income < 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Gross income cannot be NULL or negative.');
    END IF;

    v_tax := CASE
        WHEN p_gross_income <= 30000 THEN 0
        WHEN p_gross_income <= 60000 THEN (p_gross_income - 30000) * 0.15
        ELSE (30000 * 0.15) + ((p_gross_income - 60000) * 0.25)
    END;

    RETURN ROUND(v_tax, 2);
END fn_calc_income_tax;
/
