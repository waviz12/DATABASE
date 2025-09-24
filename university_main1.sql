CREATE DATABASE university_main
    WITH
    OWNER = postgres
    TEMPLATE = template0
    ENCODING = 'UTF8';

-- Архивная база
CREATE DATABASE university_archive
    WITH
    CONNECTION LIMIT = 50
    TEMPLATE = template0;

-- Тестовая база (шаблон)
CREATE DATABASE university_test
    WITH
    CONNECTION LIMIT = 10
    TEMPLATE = template0
    IS_TEMPLATE = true;

-- Посмотреть все базы и их параметры
SELECT datname, datistemplate, datconnlimit, encoding
FROM pg_database
WHERE datname IN ('university_main', 'university_archive', 'university_test');



CREATE TABLESPACE student_data
    LOCATION '/Users/daniyartanerbergen/pgdata/students';
CREATE TABLESPACE course_data
    OWNER CURRENT_USER
    LOCATION '/Users/daniyartanerbergen/pgdata/courses';

-- 3. Создаём базу university_distributed с кодировкой LATIN9, используя tablespace student_data
CREATE DATABASE university_distributed
    WITH
    ENCODING = 'LATIN9'
    TABLESPACE = student_data
    TEMPLATE = template0;
CREATE TABLE students (
                          student_id serial PRIMARY KEY,
                          first_name varchar(50),
                          last_name varchar(50),
                          email varchar(100),
                          phone char(15),
                          date_of_birth date,
                          enrollment_date date,
                          gpa numeric(4,2),
                          is_active boolean,
                          graduation_year smallint
);

-- Создание таблицы professors
CREATE TABLE professors (
                            professor_id serial PRIMARY KEY,
                            first_name varchar(50),
                            last_name varchar(50),
                            email varchar(100),
                            office_number varchar(20),
                            hire_date date,
                            salary numeric(12,2),
                            is_tenured boolean,
                            years_experience integer
);

-- Создание таблицы courses
CREATE TABLE courses (
                         course_id serial PRIMARY KEY,
                         course_code char(8),
                         course_title varchar(100),
                         description text,
                         credits smallint,
                         max_enrollment integer,
                         course_fee numeric(10,2),
                         is_online boolean,
                         created_at timestamp without time zone
);

-- Создание таблицы class_schedule
CREATE TABLE class_schedule (
                                schedule_id serial PRIMARY KEY,
                                course_id integer,
                                professor_id integer,
                                classroom varchar(20),
                                class_date date,
                                start_time time without time zone,
                                end_time time without time zone,
                                duration interval
);

-- Создание таблицы student_records
CREATE TABLE student_records (
                                 record_id serial PRIMARY KEY,
                                 student_id integer,
                                 course_id integer,
                                 semester varchar(20),
                                 year integer,
                                 grade char(2),
                                 attendance_percentage numeric(4,1),
                                 submission_timestamp timestamp with time zone,
                                 last_updated timestamp with time zone
);
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema='public';
-- ========================
-- Part 2: Create Tables
-- ========================

-- Таблица students
CREATE TABLE students (
                          student_id serial PRIMARY KEY,
                          first_name varchar(50),
                          last_name varchar(50),
                          email varchar(100),
                          phone char(15),
                          date_of_birth date,
                          enrollment_date date,
                          gpa numeric(4,2),
                          is_active boolean,
                          graduation_year smallint
);

-- Таблица professors
CREATE TABLE professors (
                            professor_id serial PRIMARY KEY,
                            first_name varchar(50),
                            last_name varchar(50),
                            email varchar(100),
                            office_number varchar(20),
                            hire_date date,
                            salary numeric(12,2),
                            is_tenured boolean,
                            years_experience integer
);

-- Таблица courses
CREATE TABLE courses (
                         course_id serial PRIMARY KEY,
                         course_code char(8),
                         course_title varchar(100),
                         description text,
                         credits smallint,
                         max_enrollment integer,
                         course_fee numeric(10,2),
                         is_online boolean,
                         created_at timestamp without time zone
);

-- Таблица class_schedule
CREATE TABLE class_schedule (
                                schedule_id serial PRIMARY KEY,
                                course_id integer,
                                professor_id integer,
                                classroom varchar(20),
                                class_date date,
                                start_time time without time zone,
                                end_time time without time zone,
                                duration interval
);

-- Таблица student_records
CREATE TABLE student_records (
                                 record_id serial PRIMARY KEY,
                                 student_id integer,
                                 course_id integer,
                                 semester varchar(20),
                                 year integer,
                                 grade char(2),
                                 attendance_percentage numeric(4,1),
                                 submission_timestamp timestamp with time zone,
                                 last_updated timestamp with time zone
);



-- 3.1 Modifying Existing Tables
ALTER TABLE students
    ADD COLUMN middle_name varchar(30),
    ADD COLUMN student_status varchar(20) DEFAULT 'ACTIVE',
    ALTER COLUMN phone TYPE varchar(20),
    ALTER COLUMN gpa SET DEFAULT 0.00;

ALTER TABLE professors
    ADD COLUMN department_code char(5),
    ADD COLUMN research_area text,
    ALTER COLUMN years_experience TYPE smallint,
    ALTER COLUMN is_tenured SET DEFAULT false,
    ADD COLUMN last_promotion_date date;

ALTER TABLE courses
    ADD COLUMN prerequisite_course_id integer,
    ADD COLUMN difficulty_level smallint,
    ALTER COLUMN course_code TYPE varchar(10),
    ALTER COLUMN credits SET DEFAULT 3,
    ADD COLUMN lab_required boolean DEFAULT false;

-- 3.2 Column Management for Specialized Tables
ALTER TABLE class_schedule
    ADD COLUMN room_capacity integer,
    DROP COLUMN duration,
    ADD COLUMN session_type varchar(15),
    ALTER COLUMN classroom TYPE varchar(30),
    ADD COLUMN equipment_needed text;

ALTER TABLE student_records
    ADD COLUMN extra_credit_points numeric(4,1) DEFAULT 0.0,
    ALTER COLUMN grade TYPE varchar(5),
    ADD COLUMN final_exam_date date,
    DROP COLUMN last_updated;

-- ========================
-- Part 4: Additional Supporting Tables
-- ========================

-- Таблица departments
CREATE TABLE departments (
                             department_id serial PRIMARY KEY,
                             department_name varchar(100),
                             department_code char(5),
                             building varchar(50),
                             phone varchar(15),
                             budget numeric(12,2),
                             established_year integer
);

-- Таблица library_books
CREATE TABLE library_books (
                               book_id serial PRIMARY KEY,
                               isbn char(13),
                               title varchar(200),
                               author varchar(100),
                               publisher varchar(100),
                               publication_date date,
                               price numeric(10,2),
                               is_available boolean,
                               acquisition_timestamp timestamp without time zone
);

-- Таблица student_book_loans
CREATE TABLE student_book_loans (
                                    loan_id serial PRIMARY KEY,
                                    student_id integer,
                                    book_id integer,
                                    loan_date date,
                                    due_date date,
                                    return_date date,
                                    fine_amount numeric(10,2),
                                    loan_status varchar(20)
);

-- Lookup table: grade_scale
CREATE TABLE grade_scale (
                             grade_id serial PRIMARY KEY,
                             letter_grade char(2),
                             min_percentage numeric(4,1),
                             max_percentage numeric(4,1),
                             gpa_points numeric(4,2)
);

-- Lookup table: semester_calendar
CREATE TABLE semester_calendar (
                                   semester_id serial PRIMARY KEY,
                                   semester_name varchar(20),
                                   academic_year integer,
                                   start_date date,
                                   end_date date,
                                   registration_deadline timestamp with time zone,
                                   is_current boolean
);



ALTER TABLE professors ADD COLUMN department_id integer;
ALTER TABLE students ADD COLUMN advisor_id integer;
ALTER TABLE courses ADD COLUMN department_id integer;
SELECT column_name, data_type, column_default-- проверка
FROM information_schema.columns
WHERE table_name='students';
-- Drop tables if they exist
DROP TABLE IF EXISTS student_book_loans;
DROP TABLE IF EXISTS library_books;
DROP TABLE IF EXISTS grade_scale;

-- Recreate grade_scale with additional column description
CREATE TABLE grade_scale (
                             grade_id serial PRIMARY KEY,
                             letter_grade char(2),
                             min_percentage numeric(4,1),
                             max_percentage numeric(4,1),
                             gpa_points numeric(4,2),
                             description text
);

-- Drop and recreate semester_calendar with CASCADE
DROP TABLE IF EXISTS semester_calendar CASCADE;

CREATE TABLE semester_calendar (
                                   semester_id serial PRIMARY KEY,
                                   semester_name varchar(20),
                                   academic_year integer,
                                   start_date date,
                                   end_date date,
                                   registration_deadline timestamp with time zone,
                                   is_current boolean
);
UPDATE pg_database
SET datistemplate = false
WHERE datname = 'university_test';

-- Теперь можно удалить
DROP DATABASE IF EXISTS university_test;

DROP DATABASE IF EXISTS university_distributed;

-- Create new backup database from university_main
CREATE DATABASE university_backup
    TEMPLATE university_main;
SELECT datname, datistemplate, datconnlimit, encoding
FROM pg_database
WHERE datname = 'university_backup';

