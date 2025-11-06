CREATE DATABASE lab6;

--PART 1
--TASK 1.1
-- Create table: employees
 CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT,
    salary DECIMAL(10, 2)
 );
-- Create table: departments
 CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
 );
-- Create table: projects
 CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id INT,
    budget DECIMAL(10, 2)
 );

--TASK 1.2
-- Insert data into employees
 INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES
 (1, 'John Smith', 101, 50000),
 (2, 'Jane Doe', 102, 60000),
 (3, 'Mike Johnson', 101, 55000),
 (4, 'Sarah Williams', 103, 65000),
 (5, 'Tom Brown', NULL, 45000);-- Insert data into departments
 INSERT INTO departments (dept_id, dept_name, location) VALUES
 (101, 'IT', 'Building A'),
 (102, 'HR', 'Building B'),
 (103, 'Finance', 'Building C'),
 (104, 'Marketing', 'Building D');
-- Insert data into projects
 INSERT INTO projects (project_id, project_name, dept_id,
budget) VALUES
 (1, 'Website Redesign', 101, 100000),
 (2, 'Employee Training', 102, 50000),
 (3, 'Budget Analysis', 103, 75000),
 (4, 'Cloud Migration', 101, 150000),
 (5, 'AI Research', NULL, 200000);

--PART 2
--TASK 2.1
SELECT e.emp_name, d.dept_name
FROM employees e CROSS JOIN departments d;
--Q:How many rows does the result contain? Calculate N × M where N = number of employees, M = number of departments
--A: 5*4=20

--TASK 2.2
--А
SELECT e.emp_name, d.dept_name
FROM employees e , departments d;
--also 20 rows

--В
SELECT e.emp_name, d.dept_name
FROM employees e INNER JOIN departments d ON TRUE;
--also 20 rows

--TASK 2.3
SELECT e.emp_name, p.project_name FROM employees e CROSS JOIN projects p;

--PART 3
--TASK 3.1
SELECT e.emp_name, d.dept_name, d.location
 FROM employees e
 INNER JOIN departments d ON e.dept_id = d.dept_id;
--Q: How many rows are returned? Why is Tom Brown not included?
--A: 4 rows. Because Tom has null in dept id but departments table does not have such id

--TASK 3.2
 SELECT emp_name, dept_name, location
 FROM employees
 INNER JOIN departments USING (dept_id);
--Q: What's the difference in output columns compared to the ON version?
--A: Output is the same. But USING the dept_id column will not be duplicated - SQL automatically joins it from both tables.

--TASK 3.3
SELECT emp_name, departments.dept_name, departments.location
FROM employees NATURAL INNER JOIN departments;

--TASK 3.4
SELECT e.emp_name, d.dept_name, p.project_name
FROM employees e
    INNER JOIN departments d ON e.dept_id = d.dept_id
    INNER JOIN projects p ON  d.dept_id =p.dept_id;

--PART 4
--TASK 4.1
SELECT e.emp_name, e.dept_id as dept_id_from_emp, d.dept_id, d.dept_name
FROM employees e LEFT JOIN departments d ON d.dept_id = e.dept_id;
--Q: How is Tom Brown represented in the results?
--А: Because in a left join, if the left side does not match the right side, it does not discard the row from the left side, but fills it with a null value

--TASK 4.2
SELECT emp_name, dept_id ,dept_name
FROM employees LEFT JOIN departments USING (dept_id);

--TASK 4.3
SELECT e.emp_name, e.dept_id as dept_id_from_emp, d.dept_id, d.dept_name
FROM employees e LEFT JOIN departments d ON d.dept_id = e.dept_id
WHERE d.dept_id IS NULL;

--TASK 4.4
SELECT d.dept_name, COUNT(e.emp_id) AS emp_count
FROM departments d LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_name
ORDER BY emp_count DESC;

--PART 5
--TASK 5.1
SELECT d.dept_name, e.emp_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;

--TASK 5.2
SELECT d.dept_name, e.emp_name
FROM departments d
LEFT JOIN  employees e ON e.dept_id = d.dept_id;

--TASK 5.3
SELECT d.dept_name, e.emp_name
FROM employees e
RIGHT JOIN departments d ON d.dept_id = e.dept_id
WHERE e.emp_id IS NULL;

--PART 6
--TASK 6.1
SELECT e.emp_name, d.dept_name
FROM employees e
FULL JOIN departments d ON d.dept_id = e.dept_id;
--Q: Which records have NULL values on the left side? Which have NULL on the right side?
--A: Tom Brown from left side has null value. Marketing from right side has null value

--TASK 6.2
SELECT d.dept_name , p.project_name
FROM departments d
FULL JOIN projects p ON d.dept_id = p.dept_id;

--TASK 6.3
SELECT  e.emp_name, d.dept_name
FROM employees e FULL JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL OR d.dept_id IS NULL;

--PART 7
--TASK 7.1
SELECT e.emp_name, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id AND d.location = 'Building A';

--TASK 7.2
SELECT e.emp_name, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';
--Q: Compare the results of Query 1 and Query 2. Explain the difference
--A: First query Shows all employees, but dept_name is only populated for those from the "Building A" department.

--PART 8
--TASK 8.1
SELECT e.emp_name , d.dept_name, p.project_name
FROM employees e
LEFT JOIN departments d ON d.dept_id = e.dept_id
LEFT JOIN projects p ON  p.dept_id = d.dept_id
order by d.dept_name , e.emp_name;

--TASK 8.2
ALTER TABLE employees ADD COLUMN manager_id INT;

-- Update with sample data
UPDATE employees SET manager_id = 3 WHERE emp_id = 1;
UPDATE employees SET manager_id = 3 WHERE emp_id = 2;
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
UPDATE employees SET manager_id = 3 WHERE emp_id = 4;
UPDATE employees SET manager_id = 3 WHERE emp_id = 5;

 SELECT
    e.emp_name AS employee,
    m.emp_name AS manager
 FROM employees e
 LEFT JOIN employees m ON e.manager_id = m.emp_id;

--TASK 8.2
 SELECT d.dept_name, AVG(e.salary) AS avg_salary
 FROM departments d
 INNER JOIN employees e ON d.dept_id = e.dept_id
 GROUP BY d.dept_id, d.dept_name
 HAVING AVG(e.salary) > 50000;

--Q1: What is the difference between INNER JOIN and LEFT JOIN?
--А: INNER Shows only those rows that are in the given tables (matches). LEFT Shows all rows from the left table, even if there are no matches in the right table. Unmatched values are replaced with NULL.

--Q2: When would you use CROSS JOIN in a practical scenario
--A: Combining sets without actual relationships Sometimes tables aren't directly related, but you want to combine their values. For example, to calculate all possible pairs of clients for recommendation analysis or comparison.

--Q3:Explain why the position of a filter condition (ON vs WHERE) matters for outer joins but not for inner joins.
--A: The difference between ON and WHERE is only important for OUTER JOINs (e.g., LEFT JOINs), because LEFT JOINs preserve all rows from the left table,even if there are no matches.In INNER JOINs, only matches are preserved,so a filter in ON or WHERE produces the same result.

--Q4: What is the result of: SELECT COUNT(*) FROM table1 CROSS JOIN table2 if table1 has 5 rows and table2 has 10 rows?
--A: 5 * 10 = 50

--Q5: How does NATURAL JOIN determine which columns to join on?
--A: NATURAL JOIN automatically joins tables by all columns with the same name and compatible data types.You don't have to manually specify which fields to use—SQL does it automatically.

--Q6:What are the potential risks of using NATURAL JOIN?
--A:You lose control over the connection logic. Added a new column with the same name - the result was different. Duplicate columns disappear from the output.

--Q7:Convert this LEFT JOIN to a RIGHT JOIN: SELECT * FROM A LEFT JOIN B ON A.id = B.id
--A: SELECT * FROM B LEFT JOIN A A.id = B.id

--Q8: When should you use FULL OUTER JOIN instead of other join types?
--A:We use FULL OUTER JOIN when we want to see all rows from both tables,including those that have no matches.
