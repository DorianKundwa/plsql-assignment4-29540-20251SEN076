INSERT INTO departments VALUES (10, 'Information Technology', 'Kigali');
INSERT INTO departments VALUES (20, 'Finance & Accounting', 'Kigali');
INSERT INTO departments VALUES (30, 'Human Resources', 'Nyamata');
INSERT INTO departments VALUES (40, 'Empty Department (For Error Testing)', 'Musanze');

INSERT INTO roles VALUES (1, 'Software Engineer', 40000, 120000);
INSERT INTO roles VALUES (2, 'Database Administrator', 50000, 130000);
INSERT INTO roles VALUES (3, 'Financial Analyst', 45000, 100000);
INSERT INTO roles VALUES (4, 'HR Specialist', 35000, 85000);
INSERT INTO roles VALUES (5, 'Intern (No Allowances)', 15000, 30000);

INSERT INTO employees VALUES (101, 'Alice', 'Uwase', 'alice.uwase@auca.ac.rw', '0788100101', TO_DATE('2024-01-15', 'YYYY-MM-DD'), 10, 1, 60000, 5000);
INSERT INTO employees VALUES (102, 'Bob', 'Mugisha', 'bob.mugisha@auca.ac.rw', '0788100102', TO_DATE('2024-03-10', 'YYYY-MM-DD'), 10, 2, 75000, 6000);
INSERT INTO employees VALUES (103, 'Chantal', 'Mukamana', 'chantal.m@auca.ac.rw', '0788100103', TO_DATE('2024-06-01', 'YYYY-MM-DD'), 10, 1, 55000, 4000);
INSERT INTO employees VALUES (104, 'David', 'Habimana', 'david.h@auca.ac.rw', '0788100104', TO_DATE('2025-01-20', 'YYYY-MM-DD'), 20, 3, 62000, 4500);
INSERT INTO employees VALUES (105, 'Esther', 'Ingabire', 'esther.i@auca.ac.rw', '0788100105', TO_DATE('2025-02-14', 'YYYY-MM-DD'), 20, 3, 58000, 3000);
INSERT INTO employees VALUES (106, 'Frank', 'Niyonzima', 'frank.n@auca.ac.rw', '0788100106', TO_DATE('2025-05-10', 'YYYY-MM-DD'), 30, 4, 48000, 2500);
INSERT INTO employees VALUES (107, 'Grace', 'Mutoni', 'grace.m@auca.ac.rw', '0788100107', TO_DATE('2025-08-01', 'YYYY-MM-DD'), 10, 5, 20000, 1000);

INSERT INTO allowances VALUES (1, 1, 'Transport Allowance', 3000, 'Y');
INSERT INTO allowances VALUES (2, 1, 'Internet Stipend', 2000, 'Y');
INSERT INTO allowances VALUES (3, 2, 'Transport Allowance', 3000, 'Y');
INSERT INTO allowances VALUES (4, 2, 'On-Call DBA Hazard Pay', 4500, 'Y');
INSERT INTO allowances VALUES (5, 3, 'Transport Allowance', 3000, 'Y');
INSERT INTO allowances VALUES (6, 3, 'Audit Season Allowance', 2500, 'N');
INSERT INTO allowances VALUES (7, 4, 'Transport Allowance', 2500, 'Y');
INSERT INTO allowances VALUES (8, 4, 'Communication Stipend', 1500, 'Y');

INSERT INTO attendance (employee_id, attendance_date, status) VALUES (101, TO_DATE('2026-10-26', 'YYYY-MM-DD'), 'Present');
INSERT INTO attendance (employee_id, attendance_date, status) VALUES (102, TO_DATE('2026-10-26', 'YYYY-MM-DD'), 'Present');
INSERT INTO attendance (employee_id, attendance_date, status) VALUES (103, TO_DATE('2026-10-26', 'YYYY-MM-DD'), 'Leave');
INSERT INTO attendance (employee_id, attendance_date, status) VALUES (104, TO_DATE('2026-10-26', 'YYYY-MM-DD'), 'Present');
INSERT INTO attendance (employee_id, attendance_date, status) VALUES (105, TO_DATE('2026-10-26', 'YYYY-MM-DD'), 'Absent');

COMMIT;
