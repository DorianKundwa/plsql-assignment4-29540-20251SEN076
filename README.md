# Employee Management, Allowance & Payroll System

**Course:** Database Development with PL/SQL (INSY 8311)  
 
  
**Assignment:** Group Assignment IV — Records, Collections, Cursors, Bulk Processing, Stored Procedures, Functions, and Exception Handling  

---

## Group Members

| Student Full Name | Student ID | Class Group |
| :--- | :--- | :--- |
| **Turashimye Kundwa Dorian** | 29540 | Group D |
| **Sugira Armel Davy** | 20251SEN076 | Group D |

---

## Project Overview

For this assignment, we built an Employee Management, Allowance and Payroll System in Oracle PL/SQL. The goal of this application is to handle core HR and payroll operations:
- Storing departments, roles with min/max salary bands, employees, allowances, and attendance.
- Calculating role allowances and progressive income taxes using PL/SQL functions.
- Registering employees with role salary validations, safe transactions, and implicit cursor inspection.
- Generating departmental payroll reports using explicit cursors and caching records into associative arrays.
- Running high-performance batch operations using `BULK COLLECT` and `FORALL`, including salary increments with audit logging and attendance batch imports using `SAVE EXCEPTIONS`.

---

## Database Schema Design

Our schema is normalized in 3NF and consists of 6 tables:

1. **`DEPARTMENTS`**: Holds company departments (`department_id`, `department_name`, `location`).
2. **`ROLES`**: Defines job roles and enforces salary boundaries (`role_id`, `role_name`, `min_salary`, `max_salary`).
3. **`EMPLOYEES`**: Stores employee records linked to departments and roles (`employee_id`, `first_name`, `last_name`, `email`, `phone_number`, `hire_date`, `department_id`, `role_id`, `salary`, `bonus`).
4. **`ALLOWANCES`**: Stores allowances attached to specific job roles (`allowance_id`, `role_id`, `allowance_name`, `allowance_amount`, `is_applicable`).
5. **`ATTENDANCE`**: Tracks employee daily attendance records (`attendance_id`, `employee_id`, `attendance_date`, `status`).
6. **`PAYROLL_AUDIT_LOG`**: Logs salary adjustments made by bulk procedures (`log_id`, `employee_id`, `old_salary`, `new_salary`, `operation_type`, `log_date`).

Indexes are also created on foreign keys (`department_id` and `role_id` in `EMPLOYEES`) to ensure fast JOIN operations during cursor processing.

---

## Execution Order

To test the application in Oracle SQL Developer, SQL*Plus, or Oracle Live SQL, run the scripts in the following order:

1. **Schema & Tables:**
   ```sql
   @00_schema/01_create_tables.sql
   ```
2. **Sample Data:**
   ```sql
   @00_schema/02_insert_sample_data.sql
   ```
3. **Functions (Compile first because procedures call them):**
   ```sql
   @02_functions/fn_get_total_allowance.sql
   @02_functions/fn_calc_income_tax.sql
   @02_functions/fn_get_emp_financial_summary.sql
   ```
4. **Procedures:**
   ```sql
   @01_procedures/proc_register_employee.sql
   @01_procedures/proc_dept_payroll_report.sql
   @01_procedures/proc_bulk_salary_increment.sql
   @01_procedures/proc_bulk_insert_attendance.sql
   ```
5. **Testing & Output:**
   Make sure to enable output before running tests:
   ```sql
   SET SERVEROUTPUT ON SIZE UNLIMITED;
   ```
   - Run success cases: `@03_tests/test_success_cases.sql`
   - Run error handling cases: `@03_tests/test_error_cases.sql`

---

## Academic Integrity & AI Statement

We used an AI assistant to help us review PL/SQL syntax patterns, format Markdown tables, and brainstorm realistic edge cases for exception testing. We wrote, tested, and reviewed the database schema, procedures, functions, and test blocks ourselves, and we are both fully prepared to explain and defend every line of code individually during class presentation.
