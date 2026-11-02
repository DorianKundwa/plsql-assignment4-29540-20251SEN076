CREATE OR REPLACE PROCEDURE proc_bulk_insert_attendance (
    p_include_error_rows IN BOOLEAN DEFAULT FALSE
) IS
    TYPE t_att_rec IS RECORD (
        emp_id   attendance.employee_id%TYPE,
        att_date attendance.attendance_date%TYPE,
        status   attendance.status%TYPE
    );

    TYPE t_att_list IS TABLE OF t_att_rec;
    v_att_batch t_att_list := t_att_list();

    e_bulk_dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_bulk_dml_errors, -24381);

    v_err_count NUMBER;
    v_bad_index NUMBER;
    v_err_code  NUMBER;
BEGIN
    v_att_batch.EXTEND(3);
    v_att_batch(1) := t_att_rec(101, TO_DATE('2026-10-27', 'YYYY-MM-DD'), 'Present');
    v_att_batch(2) := t_att_rec(102, TO_DATE('2026-10-27', 'YYYY-MM-DD'), 'Present');
    v_att_batch(3) := t_att_rec(103, TO_DATE('2026-10-27', 'YYYY-MM-DD'), 'Present');

    IF p_include_error_rows THEN
        v_att_batch.EXTEND(2);
        v_att_batch(4) := t_att_rec(101, TO_DATE('2026-10-26', 'YYYY-MM-DD'), 'Present');
        v_att_batch(5) := t_att_rec(9999, TO_DATE('2026-10-27', 'YYYY-MM-DD'), 'Present');
    END IF;

    FORALL i IN v_att_batch.FIRST .. v_att_batch.LAST SAVE EXCEPTIONS
        INSERT INTO attendance (employee_id, attendance_date, status)
        VALUES (v_att_batch(i).emp_id, v_att_batch(i).att_date, v_att_batch(i).status);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Bulk Attendance Insert Complete. All ' || SQL%ROWCOUNT || ' rows inserted without errors.');

EXCEPTION
    WHEN e_bulk_dml_errors THEN
        v_err_count := SQL%BULK_EXCEPTIONS.COUNT;
        DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('BULK DML WARNING: ' || SQL%ROWCOUNT || ' valid rows inserted, ' || v_err_count || ' rows failed.');

        FOR i IN 1 .. v_err_count LOOP
            v_bad_index := SQL%BULK_EXCEPTIONS(i).ERROR_INDEX;
            v_err_code  := SQL%BULK_EXCEPTIONS(i).ERROR_CODE;
            DBMS_OUTPUT.PUT_LINE(
                ' -> Failed at Batch Index #' || v_bad_index ||
                ' [EmpID: ' || v_att_batch(v_bad_index).emp_id ||
                ', Date: ' || TO_CHAR(v_att_batch(v_bad_index).att_date, 'YYYY-MM-DD') || ']' ||
                ' | Oracle Error: ' || SQLERRM(-v_err_code)
            );
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------');
        COMMIT;
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Unexpected error in proc_bulk_insert_attendance: ' || SQLERRM);
END proc_bulk_insert_attendance;
/
