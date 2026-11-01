CREATE OR REPLACE FUNCTION fn_get_total_allowance (
    p_role_id IN NUMBER
) RETURN NUMBER IS
    v_role_exists NUMBER;
    v_total_allowance NUMBER := 0;
    e_invalid_role_id EXCEPTION;
BEGIN
    IF p_role_id IS NULL OR p_role_id <= 0 THEN
        RAISE e_invalid_role_id;
    END IF;

    SELECT role_id INTO v_role_exists
    FROM roles
    WHERE role_id = p_role_id;

    SELECT NVL(SUM(allowance_amount), 0)
    INTO v_total_allowance
    FROM allowances
    WHERE role_id = p_role_id
      AND is_applicable = 'Y';

    RETURN v_total_allowance;
EXCEPTION
    WHEN e_invalid_role_id THEN
        DBMS_OUTPUT.PUT_LINE('Error in fn_get_total_allowance: Role ID must be a positive number.');
        RETURN -1;
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error in fn_get_total_allowance: Role ID ' || p_role_id || ' does not exist.');
        RETURN -1;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error in fn_get_total_allowance: ' || SQLERRM);
        RETURN -1;
END fn_get_total_allowance;
/
