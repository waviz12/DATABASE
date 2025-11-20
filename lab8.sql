CREATE DATABASE lab8;


--PART 1
 CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
 );
 CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    dept_id INT,
    salary DECIMAL(10,2),
 FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
 );
 CREATE TABLE projects (
    proj_id INT PRIMARY KEY,
    proj_name VARCHAR(100),
    budget DECIMAL(12,2),
    dept_id INT,
 FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
 );-- Insert sample data
 INSERT INTO departments VALUES
(101, 'IT', 'Building A'),
 (102, 'HR', 'Building B'),
 (103, 'Operations', 'Building C');
 INSERT INTO employees VALUES
 (1, 'John Smith', 101, 50000),
 (2, 'Jane Doe', 101, 55000),
 (3, 'Mike Johnson', 102, 48000),
 (4, 'Sarah Williams', 102, 52000),
 (5, 'Tom Brown', 103, 60000);
 INSERT INTO projects VALUES
 (201, 'Website Redesign', 75000, 101),
 (202, 'Database Migration', 120000, 101),
 (203, 'HR System Upgrade', 50000, 102);


--PART 2

--TASK 2.1
CREATE INDEX emp_salary_idx ON employees(salary);

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees';
--Q: How many indexes exist on the employees table? A: 2

--TASK 2.2

CREATE INDEX emp_dept_idx ON employees(dept_id);
SELECT * FROM employees WHERE dept_id = 101;
--Q: Why is it beneficial to index foreign key columns?
--A: Reduced blocking and improved concurrency, Improved referential integrity checking, Speeding up JOIN operations

--TASK 2.3
 SELECT
    tablename,
    indexname,
    indexdef
 FROM pg_indexes
 WHERE schemaname = 'public'
 ORDER BY tablename, indexname;
--Q: List all the indexes you see. Which ones were created automatically?
--A: projects_pkey, employees_pkey, departments_pkey

--PART 3

--TASK 3.1
CREATE INDEX emp_dept_salary_idx ON employees(dept_id,salary);

SELECT emp_name, salary
FROM employees
WHERE dept_id = 101 AND salary > 52000;
--Q:  Would this index be useful for a query that only filters by salary (without dept_id)? Why or why not?
--A: No, the emp_dept_salary_idx index on the (dept_id, salary) columns will not be used for a query filtering only by salary (without dept_id).

--TASK 3.2
CREATE INDEX emp_salary_dept_idx ON employees(salary,dept_id);

-- Query 1: Filters by dept_id first
 SELECT * FROM employees WHERE dept_id = 102 AND salary > 50000;
-- Query 2: Filters by salary first
 SELECT * FROM employees WHERE salary > 50000 AND dept_id = 102;

--Q: Does the order of columns in a multicolumn index matter? Explain.
--A: Yes, the order of columns in a multi-column index is critical to its performance and usage.

--PART 4

--TASK 4.1
ALTER TABLE employees ADD COLUMN email VARCHAR(100);
 UPDATE employees SET email = 'john.smith@company.com' WHERE emp_id = 1;
 UPDATE employees SET email = 'jane.doe@company.com' WHERE emp_id = 2;
 UPDATE employees SET email = 'mike.johnson@company.com' WHERE emp_id = 3;
 UPDATE employees SET email = 'sarah.williams@company.com' WHERE emp_id = 4;
 UPDATE employees SET email = 'tom.brown@company.com' WHERE emp_id = 5;

CREATE INDEX emp_email_idx ON employees(email);
 INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
 VALUES (6, 'New Employee', 101, 55000, 'john.smith@company.com');


--TASK 4.2
ALTER TABLE employees ADD COLUMN phone VARCHAR(20) UNIQUE;
 SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees' AND indexname LIKE '%phone%';
--Q:Did PostgreSQL automatically create an index? What type of index?
-- YES, btree

--PART 5

--TASK 5.1
CREATE INDEX emp_salary_desc_idx ON employees(salary desc );

SELECT emp_name, salary
FROM employees
ORDER BY salary DESC;

--TASK 5.2
CREATE INDEX proj_budget_nulls_first_idx ON projects(budget NULLS FIRST);
SELECT proj_name, budget
FROM projects
ORDER BY budget NULLS FIRST;

--PART 6

--TASK 6.1
CREATE INDEX emp_name_lower_idx ON employees(LOWER(emp_name));
SELECT * FROM employees WHERE LOWER(emp_name) = 'john smith';

--TASK 6.2
ALTER TABLE employees ADD COLUMN hire_date DATE;
UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;

CREATE INDEX emp_hire_year_idx ON employees(EXTRACT(YEAR FROM hire_date));

SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;


--PART 7

--TASK 7.1
ALTER INDEX emp_salary_idx RENAME TO employees_salary_index;
SELECT indexname FROM pg_indexes WHERE tablename = 'employees';

--TASK 7.2
DROP INDEX emp_salary_dept_idx;

--TASK 7.3
REINDEX INDEX employees_salary_index;


--PART 8

--TASK 8.1
 SELECT e.emp_name, e.salary, d.dept_name
 FROM employees e
 JOIN departments d ON e.dept_id = d.dept_id
 WHERE e.salary > 50000
 ORDER BY e.salary DESC;

CREATE INDEX emp_salary_filter_idx ON employees(salary) WHERE salary > 50000;

--TASK 8.2
CREATE INDEX proj_high_budget_idx ON projects(budget)
WHERE budget > 80000;

SELECT proj_name, budget
FROM projects
WHERE budget > 80000;

--TASK 8.3
EXPLAIN SELECT * FROM employees WHERE salary > 52000;

--PART 9

--TASK 9.1
CREATE INDEX dept_name_hash_idx ON departments USING HASH (dept_name);
SELECT * FROM departments WHERE dept_name = 'IT';

--TASK 9.2
CREATE INDEX proj_name_btree_idx ON projects(proj_name);
CREATE INDEX proj_name_hash_idx ON projects USING HASH (proj_name);

-- Equality search (both can be used)
SELECT * FROM projects WHERE proj_name = 'Website Redesign';
-- Range search (only B-tree can be used)
SELECT * FROM projects WHERE proj_name > 'Database';

--PART 10

--TASK 10.1
SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as index_size
 FROM pg_indexes
 WHERE schemaname = 'public'
 ORDER BY tablename, indexname;

--TASK 10.2
DROP INDEX IF EXISTS proj_name_hash_idx;

--TASK 10.3

CREATE VIEW index_documentation AS
SELECT
    tablename,
    indexname,
    indexdef,
 'Improves salary-based queries' as purpose
 FROM pg_indexes
 WHERE schemaname = 'public'
AND indexname LIKE '%salary%';
 SELECT * FROM index_documentation;
