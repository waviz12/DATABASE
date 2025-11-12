CREATE DATABASE lab7;


--PART 1
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
CREATE VIEW employee_details
    AS
    SELECT e.emp_name, e.salary, d.dept_name, d.location
    FROM employees e JOIN departments d on d.dept_id = e.dept_id;

SELECT * FROM employee_details;

--Q: How many rows are returned? A: 4 rows
--Q: Why doesn't Tom Brown appear? A: Because the view was created with inner join. Inner join returns if our condition is true. If we want to show all employees we should use Left join

--TASK 2.2
CREATE VIEW dept_statistics
    AS
    SELECT d.dept_name as department_name ,
           count(e.emp_id) as count_emp,
           avg(e.salary),
           max(e.salary),
           min(e.salary)
    FROM departments d left join employees e on d.dept_id = e.dept_id
    GROUP BY d.dept_name;

SELECT * FROM dept_statistics
ORDER BY count_emp DESC;;

--TASK 2.3

CREATE VIEW project_overview
    AS
    WITH depCount AS(
        SELECT
            dept_id,
            count(emp_id) as team_size
        FROM employees
        GROUP BY dept_id
    )

    SELECT p.project_name,
           p.budget,
           d.dept_name,
           d.location,
           COALESCE(dep.team_size,0) as emp_count
    FROM projects p
        INNER JOIN
        departments d ON d.dept_id = p.dept_id
    LEFT JOIN
        depCount dep ON d.dept_id = dep.dept_id;

SELECT * FROM project_overview
ORDER BY budget;

--TASK 2.4
drop view high_earners;
CREATE VIEW high_earners AS
    SELECT
        e.emp_name,
        e.salary,
        d.dept_name
    FROM employees e
        LEFT JOIN
        departments d
        ON d.dept_id = e.dept_id
    where salary >= 55000;
select * from high_earners;
--Q: What happens when you query this view? A: View returns employees which salary is greater than 55000
--Q: Can you see all high-earning employees? A: Yes

--PART 3

--TASK 3.1
CREATE  OR REPLACE VIEW employee_details AS
    SELECT e.emp_name, e.salary, d.dept_name, d.location,
              CASE
                WHEN e.salary > 60000 THEN 'High'
                WHEN e.salary > 50000 THEN 'Medium'
                ELSE 'Standard'
       END AS salary_grade
       FROM employees e INNER JOIN departments d on d.dept_id = e.dept_id;
SELECT * FROM employee_details;

--TASK 3.2
ALTER VIEW high_earners RENAME TO top_performers;
SELECT * FROM top_performers;

--TASK 3.3
CREATE or replace VIEW temp_view AS SELECT emp_name, salary FROM employees WHERE salary < 50000;
SELECT * FROM temp_view;

DROP VIEW temp_view;

--PART 4

--TASK 4.1
CREATE VIEW employee_salaries AS
    SELECT emp_id,
           emp_name,
           dept_id,
           salary
    FROM employees;

--TASK 4.2
UPDATE employee_salaries set salary = 52000 where emp_name = 'John Smith';
SELECT * FROM employees WHERE emp_name = 'John Smith';
--Q:Did the underlying table get updated? A: Yes underlying is updated

--TASK 4.3
INSERT INTO employee_salaries values (6, 'Alice Johnson',102,58000);
--Q: Was the insert successful? A: YES
-- Check the employees table
SELECT * FROM employees;

--TASK 4.4
CREATE VIEW it_employees
    AS
    SELECT *
    FROM employees
    WHERE  dept_id = 101 WITH LOCAL CHECK OPTION ;

INSERT INTO it_employees (emp_id, emp_name, dept_id, salary)
VALUES (7, 'Bob Wilson', 103, 60000);
--Q: What error message do you receive?
--A: ОШИБКА: новая строка нарушает ограничение-проверку для представления "it_employees" Подробности: Ошибочная строка содержит (7, Bob Wilson, 103, 60000.00).
-- Why? A: Because if we want to insert data with this view first of all it checks. Does the data satisfied local condition.

--PART 5

--TASK 5.1
drop materialized view dept_summary_mv;
CREATE MATERIALIZED VIEW dept_summary_mv
    AS WITH emp_stat AS(SELECT dept_id, count(emp_id)  as total_emp,coalesce(sum(salary),0) as sum_sal FROM employees GROUP BY dept_id),
            project_stat AS (SELECT dept_id, count(project_id) as total_proj, coalesce(sum(budget)) as total_bud FROM projects GROUP BY dept_id)
       SELECT d.dept_id,
              d.dept_name,
              e_stat.total_emp as total_emp,
              e_stat.sum_sal as sum_salary,
              pro.total_proj as total_proj,
              pro.total_bud as total_buget
    FROM departments d LEFT JOIN emp_stat e_stat ON d.dept_id = e_stat.dept_id
    LEFT JOIN project_stat pro ON pro.dept_id = e_stat.dept_id with data ;


SELECT * FROM dept_summary_mv ORDER BY total_emp DESC;

--TASK 5.2
INSERT INTO employees values (8,'Charlie Brown',101,54000);
SELECT * FROM dept_summary_mv;
REFRESH MATERIALIZED VIEW dept_summary_mv;
SELECT * FROM dept_summary_mv;

--TASK 5.3
CREATE UNIQUE INDEX dept_summary_idx on dept_summary_mv (dept_id);

REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;
--Q: What's the advantage of CONCURRENTLY option? A:The main and most significant benefit of the CONCURRENTLY option when updating materialized views (especially in PostgreSQL) is that it maintains data availability.

--TASK 5.4
CREATE MATERIALIZED VIEW project_stats_mv AS with emp as
    (SELECT dept_id, count(emp_id) as emp_count from employees  group by dept_id)
    SELECT p.project_name, p.budget, d.dept_name, coalesce(e.emp_count)
    FROM projects p LEFT JOIN departments d ON d.dept_id = p.dept_id
    LEFT JOIN emp  e ON e.dept_id = p.dept_id
with no data ;

SELECT * FROM project_stats_mv;
--Q:  What error do you get? A:The CREATE MATERIALIZED VIEW ... WITH NO DATA command creates the view structure in the database catalog, but does not execute the underlying SELECT query to load data into the materialized table itself.
--Q:  How do you fix it? A: To correct the error and populate the materialized view with data, you must use the REFRESH MATERIALIZED VIEW command.

--PART 6

--TASK 6.1
CREATE ROLE analyst NOLOGIN ;
CREATE ROLE data_viewer LOGIN PASSWORD 'viewer123';
CREATE ROLE report_user PASSWORD 'report456';

SELECT rolname FROM pg_roles WHERE rolname NOT LIKE 'pg_%';

--TASK 6.2
CREATE ROLE db_creator LOGIN PASSWORD 'creator789' CREATEDB ;
CREATE ROLE user_manager CREATEROLE LOGIN PASSWORD 'manager101';
CREATE ROLE admin_user SUPERUSER LOGIN PASSWORD 'admin999';
DROP ROLE admin_user;

--TASK 6.3
GRANT SELECT ON employees,departments,projects TO analyst;
GRANT ALL ON employee_details TO data_viewer;
GRANT SELECT ,INSERT ON employees TO report_user;

--TASK 6.4
CREATE ROLE hr_team;
CREATE ROLE finance_team;
CREATE ROLE it_team;

CREATE ROLE hr_user1 PASSWORD 'hr001';
CREATE ROLE hr_user2 PASSWORD 'hr002';
CREATE ROLE finance_user1 PASSWORD 'fin001';

GRANT hr_team TO hr_user1;
GRANT hr_team TO hr_user2;
GRANT finance_team TO finance_user1;

GRANT SELECT,UPDATE ON employees TO hr_team;
GRANT SELECT ON dept_statistics TO finance_team;

--TASK 6.5
REVOKE UPDATE ON employees FROM hr_team;
REVOKE hr_team FROM hr_user2;
REVOKE ALL ON employee_details FROM data_viewer;

--TASK 6.6
ALTER ROLE analyst LOGIN PASSWORD 'analyst123';
ALTER ROLE user_manager WITH SUPERUSER ;
ALTER ROLE analyst PASSWORD NULL ;
ALTER ROLE data_viewer CONNECTION LIMIT 5;

--PART 7

--TASK 7.1
CREATE ROLE read_only NOLOGIN ;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;

CREATE ROLE junior_analyst LOGIN PASSWORD 'junior123';
CREATE ROLE senior_analyst LOGIN PASSWORD 'senior123';

GRANT read_only TO junior_analyst;
GRANT read_only TO senior_analyst;

GRANT INSERT, UPDATE ON employees TO senior_analyst;

--TASK 7.2
CREATE ROLE project_manager LOGIN PASSWORD 'pm123';
ALTER VIEW dept_statistics OWNER TO project_manager;
ALTER TABLE projects OWNER TO project_manager;

SELECT tablename, tableowner
FROM pg_tables
WHERE schemaname = 'public';

--TASK 7.3
CREATE ROLE temp_owner LOGIN ;
CREATE TABLE temp_table(
    id int
);

ALTER TABLE temp_table OWNER TO temp_owner;
REASSIGN OWNED BY temp_owner TO postgres;

DROP OWNED BY temp_owner;
DROP ROLE temp_owner;

--TASK 7.4
CREATE VIEW hr_employee_view AS SELECT emp_name FROM employees WHERE dept_id = 102;

GRANT SELECT ON hr_employee_view TO hr_team;

CREATE VIEW finance_employee_view AS SELECT emp_id, emp_name, salary FROM employees;

GRANT SELECT ON finance_employee_view TO finance_team;

--PART 8

--TASK 8.1
CREATE VIEW dept_dashboard AS WITH empStat
    AS(SELECT dept_id,count(emp_id) as total_emp,avg(salary) avg_salary from employees group by dept_id),
    projectStat AS  (SELECT dept_id, count(project_id) as count_proj,sum(budget) as total_budget from projects group by dept_id)
    SELECT
        d.dept_name, d.location,
        em.total_emp,em.avg_salary,
        pro.total_budget, pro.count_proj,
        ROUND(
            COALESCE(pro.total_budget,0.00)/ NULLIF(COALESCE(em.total_emp,0),0),2
        ) as budget_per_employee
    FROM departments d LEFT JOIN empStat em ON em.dept_id = d.dept_id
    LEFT JOIN projectStat pro ON pro.dept_id = em.dept_id;

SELECT * FROM dept_dashboard;

--TASK 8.2
ALTER TABLE projects ADD COLUMN created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE VIEW high_budget_projects AS
    SELECT p.project_name,
           p.budget,
           p.created_date ,
           d.dept_name,
           CASE
               WHEN p.budget > 150000 THEN 'Critical Review Required'
               WHEN p.budget > 100000 THEN 'Management Approval Needed'
               ELSE 'Standard Process'
            END AS  approval_status
    FROM projects p LEFT JOIN departments d
        ON d.dept_id = p.dept_id
    WHERE budget > 75000;

SELECT * FROM high_budget_projects;


--TASK 8.3

--LEVEL 1
CREATE ROLE viewer_role;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO viewer_role;

--LEVEL 2
CREATE ROLE entry_role;
GRANT viewer_role TO entry_role;
GRANT INSERT ON employees,projects TO entry_role;

--LEVEL 3
CREATE ROLE analyst_role;
GRANT entry_role TO analyst_role;
GRANT UPDATE ON employees, projects TO analyst_role;

--LEVEL 4
CREATE ROLE manager_role;
GRANT analyst_role TO manager_role;
GRANT DELETE ON employees, projects TO manager_role;

CREATE USER alice PASSWORD 'alice123';
CREATE USER bob PASSWORD 'bob123';
CREATE USER charlie PASSWORD 'charlie123';

GRANT viewer_role TO alice;
GRANT analyst_role TO bob;
GRANT manager_role TO charlie;
