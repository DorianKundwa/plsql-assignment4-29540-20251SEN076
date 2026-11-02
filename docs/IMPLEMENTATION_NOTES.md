# Implementation & Performance Notes

This document covers our design decisions, observations, and findings while developing and testing this project in **Oracle SQL Developer**.

---

## 1. Technical Requirements & Implementation

| Requirement | File / Object | What We Implemented & Observed |
| :--- | :--- | :--- |
| **`%ROWTYPE`** | `fn_get_emp_financial_summary`, `proc_register_employee` | Grabs the whole record directly from `EMPLOYEES` or `ROLES`. We found this prevents errors whenever table columns are added or modified. |
| **User-Defined Record** | `proc_dept_payroll_report`, `proc_bulk_salary_increment` | Created custom records to package calculated values (base salary, allowances, taxes, net salary) into a single entity. |
| **VARRAY** | `fn_get_emp_financial_summary` | Used a `VARRAY(4)` to represent the 4 quarterly bonus payouts. Since a year strictly has 4 quarters, a bounded array made the most sense. |
| **Associative Array** | `proc_dept_payroll_report` | Caches calculated payroll values in memory using `employee_id` as the key. This gave us instant in-memory lookups during attendance reporting. |
| **Nested Table** | `proc_bulk_salary_increment`, `proc_bulk_insert_attendance` | Dynamic in-memory collections used for bulk SQL (`BULK COLLECT` and `FORALL`). |
| **Implicit Cursors** | `proc_register_employee` | Monitored `SQL%ROWCOUNT`, `SQL%FOUND`, and `SQL%NOTFOUND` after DML. We confirmed `SQL%ISOPEN` always evaluates to `FALSE` right after the statement finishes. |
| **Explicit Cursors** | `proc_dept_payroll_report` | Managed manual `OPEN`, `FETCH`, and `CLOSE` lifecycle with `%ROWCOUNT` checks, along with a cursor `FOR` loop for attendance logs. |
| **Bulk SQL** | `proc_bulk_salary_increment`, `proc_bulk_insert_attendance` | Replaced row-by-row loops with `BULK COLLECT` and `FORALL` to cut context switching overhead. |
| **Bulk Error Handling** | `proc_bulk_insert_attendance` | Handled `ORA-24381` with `SAVE EXCEPTIONS` so valid rows are saved even when invalid rows are present in the batch. |
| **Exceptions** | Across all files | Handled predefined exceptions (`NO_DATA_FOUND`, `DUP_VAL_ON_INDEX`), custom exceptions, and `RAISE_APPLICATION_ERROR`. |

---

## 2. Practical Findings During Development in SQL Developer

As we worked on the application in Oracle SQL Developer, we noted several practical behaviors:

### A. Compilation Order
As we were compiling our code in SQL Developer, we found that compiling procedures before functions produced `PLS-00201: identifier 'FN_GET_TOTAL_ALLOWANCE' must be declared`. We realized that because `proc_dept_payroll_report` calls stored functions inside its cursor query, all functions must be compiled first in SQL Developer before compiling dependent procedures.

### B. Implicit Cursor Attributes Behavior
In `proc_register_employee`, we observed how Oracle manages implicit cursors:
- When checking `SQL%ISOPEN` after an `INSERT` or `UPDATE`, it always returned `FALSE`. We found this is because Oracle opens, executes, and automatically closes implicit cursors in one single step.
- We noticed `SQL%ROWCOUNT` gives the exact number of modified rows immediately after the DML, which allowed us to accurately confirm that our welcome bonus update affected exactly 1 row.

### C. Associative Arrays for Caching
In `proc_dept_payroll_report`, we initially thought about running a nested query inside the attendance loop to get the employee name for each attendance record. But as we tested this, we realized doing repeated SQL lookups inside a loop is inefficient. Instead, we cached each employee's calculated record into an associative array indexed by `employee_id` (`v_payroll_cache(emp_id) := emp_rec`). When printing the attendance section, we used `v_payroll_cache.EXISTS(...)` for an instant memory lookup without hitting the database tables again.

---

## 3. Performance Analysis: Row-by-Row vs. Bulk Processing

### The Context Switching Problem
While testing in SQL Developer, we analyzed how the database engine executes procedural loops versus bulk operations:
- Oracle uses two separate engines: the **PL/SQL Engine** (handles procedural flow, variables, conditions) and the **SQL Engine** (executes SQL statements and DML).
- In a traditional cursor `FOR` loop:
  ```sql
  FOR r IN (SELECT * FROM employees WHERE department_id = 20) LOOP
      UPDATE employees SET salary = r.salary * 1.1 WHERE employee_id = r.employee_id;
  END LOOP;
  ```
  For every single employee row, control switches back and forth between PL/SQL and SQL. If there are 10,000 employees, that produces **10,000 fetch context switches plus 10,000 DML context switches** (total 20,000 switches). We found this causes significant CPU wait time and slower execution.

### What We Found with `BULK COLLECT` and `FORALL`
When we implemented `proc_bulk_salary_increment`:
1. `BULK COLLECT` retrieves all qualifying rows from the SQL engine into memory in **one context switch**.
2. `FORALL` sends the entire array of update statements from the PL/SQL engine to the SQL engine in **one single batch call**.

| Comparison Metric | Standard Cursor Loop ($N = 10,000$) | `BULK COLLECT` + `FORALL` ($N = 10,000$) |
| :--- | :--- | :--- |
| **Fetch Context Switches** | 10,000 | 1 |
| **DML Context Switches** | 10,000 | 1 batch call |
| **Performance Impact** | Slower due to frequent engine switching | Noticeably faster execution |
| **Memory Trade-off** | Minimal PGA memory (1 row at a time) | Higher PGA usage (holds collection in memory) |

As we observed this memory trade-off, we noted that for very large production datasets (millions of rows), using `FETCH ... BULK COLLECT INTO ... LIMIT 1000` is best practice so the session doesn't consume excessive memory.

### Robustness with `SAVE EXCEPTIONS`
When testing batch inserts in `proc_bulk_insert_attendance`, we noticed that without `SAVE EXCEPTIONS`, a single constraint violation (like a duplicate primary key or non-existent foreign key) causes the entire batch to fail and roll back everything.
By adding `SAVE EXCEPTIONS`:
- Oracle lets all valid records insert successfully.
- It raises `ORA-24381` at the end of the statement.
- In our exception block, we mapped `ORA-24381` using `PRAGMA EXCEPTION_INIT`, checked `SQL%BULK_EXCEPTIONS.COUNT`, and looped through each error to print the failed batch index and the specific Oracle error code (`SQLERRM(-v_err_code)`). We then committed the valid rows.
