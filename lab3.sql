CREATE TABLE departments (
                             dept_id SERIAL PRIMARY KEY,
                             dept_name VARCHAR(100) NOT NULL,
                             budget NUMERIC(12,2) DEFAULT 0
);

CREATE TABLE employees (
                           emp_id SERIAL PRIMARY KEY,
                           first_name VARCHAR(50) NOT NULL,
                           last_name VARCHAR(50) NOT NULL,
                           salary NUMERIC(10,2) DEFAULT 0,
                           hire_date DATE DEFAULT CURRENT_DATE,
                           manager_id INT REFERENCES employees(emp_id),
                           dept_id INT REFERENCES departments(dept_id)
);

CREATE TABLE projects (
                          project_id SERIAL PRIMARY KEY,
                          project_name VARCHAR(100) NOT NULL,
                          start_date DATE DEFAULT CURRENT_DATE,
                          end_date DATE,
                          budget NUMERIC(12,2) DEFAULT 0
);

-- ======================
-- Part B: INSERT
-- ======================
-- B1
INSERT INTO employees (first_name, last_name, salary)
VALUES ('John', 'Doe', 50000);

-- B2
INSERT INTO employees (first_name, last_name)
VALUES ('Jane', 'Smith');

-- B3
INSERT INTO employees (first_name, last_name, salary)
VALUES
    ('Alice', 'Brown', 60000),
    ('Bob', 'White', 55000);

-- B4
INSERT INTO employees (first_name, last_name, salary, hire_date)
VALUES
    ('Chris', 'Green', 40000 * 1.1, CURRENT_DATE - INTERVAL '30 days');

-- B5
CREATE TEMP TABLE temp_employees (
                                     fname VARCHAR(50),
                                     lname VARCHAR(50),
                                     sal NUMERIC(10,2)
);

INSERT INTO temp_employees VALUES
                               ('Mark','Black',45000),
                               ('Lily','Adams',47000);

INSERT INTO employees (first_name,last_name,salary)
SELECT fname,lname,sal FROM temp_employees;

-- ======================
-- Part C: UPDATE
-- ======================
-- C1
UPDATE employees
SET salary = salary * 1.05
WHERE dept_id IS NULL;

-- C2
UPDATE employees
SET salary = salary + 2000
WHERE salary < 50000
  AND hire_date < CURRENT_DATE - INTERVAL '365 days';

-- C3
UPDATE employees
SET salary = CASE
                 WHEN dept_id = 1 THEN salary * 1.1
                 WHEN dept_id = 2 THEN salary * 1.2
                 ELSE salary
    END;

-- C4
UPDATE employees
SET dept_id = DEFAULT
WHERE dept_id IS NULL;

-- C5 (COALESCE fix)
UPDATE departments d
SET budget = (
    SELECT COALESCE(AVG(e.salary),0) * 1.2
    FROM employees e
    WHERE e.dept_id = d.dept_id
);

-- C6
UPDATE employees
SET salary = salary * 1.03,
    hire_date = hire_date - INTERVAL '7 days';

-- ======================
-- Part D: DELETE
-- ======================
-- D1
DELETE FROM employees
WHERE salary < 30000;

-- D2
DELETE FROM employees
WHERE salary > 100000 OR dept_id IS NULL;

-- D3
DELETE FROM employees
WHERE dept_id IN (
    SELECT dept_id FROM departments WHERE budget < 10000
);

-- D4
DELETE FROM projects
WHERE end_date < CURRENT_DATE
RETURNING project_id, project_name;

-- ======================
-- Part E: NULL
-- ======================
-- E1
INSERT INTO employees (first_name, last_name, salary, hire_date, dept_id)
VALUES ('NullGuy','Test',NULL,NULL,NULL);

-- E2
UPDATE employees
SET salary = 40000
WHERE salary IS NULL;

-- E3
DELETE FROM employees
WHERE hire_date IS NULL;

-- ======================
-- Part F: RETURNING
-- ======================
-- F1
INSERT INTO employees (first_name,last_name,salary)
VALUES ('Return','Case',70000)
RETURNING emp_id, first_name || ' ' || last_name AS full_name;

-- F2
UPDATE employees
SET salary = salary + 1000
WHERE emp_id = 1
RETURNING emp_id, salary AS new_salary, salary - 1000 AS old_salary;

-- F3
DELETE FROM employees
WHERE emp_id = 2
RETURNING *;

-- ======================
-- Part G: Advanced Patterns
-- ======================
-- G1 Conditional INSERT
INSERT INTO departments (dept_name, budget)
SELECT 'HR', 20000
WHERE NOT EXISTS (
    SELECT 1 FROM departments WHERE dept_name = 'HR'
);

-- G2 UPDATE with subquery
UPDATE projects p
SET budget = p.budget + (
    SELECT SUM(e.salary)*0.1
    FROM employees e
    WHERE e.dept_id = p.project_id
)
WHERE EXISTS (
    SELECT 1 FROM employees e WHERE e.dept_id = p.project_id
);

-- G3 Bulk insert + update
INSERT INTO employees (first_name,last_name,salary)
VALUES
    ('Mass','One',35000),
    ('Mass','Two',37000),
    ('Mass','Three',39000);

UPDATE employees
SET salary = salary * 1.02
WHERE last_name LIKE 'Mass%';

-- G4 Archive migration
CREATE TABLE employee_archive AS
    TABLE employees WITH NO DATA;

INSERT INTO employee_archive
SELECT * FROM employees WHERE hire_date < CURRENT_DATE - INTERVAL '3650 days';

DELETE FROM employees
WHERE hire_date < CURRENT_DATE - INTERVAL '3650 days';

-- G5 Business rule (fix JOIN dept_id)
UPDATE projects p
SET end_date = end_date + INTERVAL '30 days'
WHERE EXISTS (
    SELECT 1
    FROM employees e
             JOIN departments d ON e.dept_id = d.dept_id
    WHERE d.budget < 20000
);
