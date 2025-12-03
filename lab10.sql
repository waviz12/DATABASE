CREATE DATABASE lab10;

--PART 3

--TASK 3.1
CREATE TABLE accounts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    balance DECIMAL(10, 2) DEFAULT 0.00
 );
 CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    shop VARCHAR(100) NOT NULL,
    product VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
 );-- Insert test data
 INSERT INTO accounts (name, balance) VALUES
    ('Alice', 1000.00),
    ('Bob', 500.00),
    ('Wally', 750.00);
 INSERT INTO products (shop, product, price) VALUES
    ('Joe''s Shop', 'Coke', 2.50),
    ('Joe''s Shop', 'Pepsi', 3.00);

--TASK 3.2
 BEGIN;
 UPDATE accounts SET balance = balance - 100.00
    WHERE name = 'Alice';
 UPDATE accounts SET balance = balance + 100.00
    WHERE name = 'Bob';
 COMMIT;

SELECT * FROM accounts;
--a) What are the balances of Alice and Bob after the transaction?
--A: Alice`s balance after transaction is 900 Bob`s balance is 600

--b) Why is it important to group these two UPDATE statements in a single transaction?
--A: It is critical to group these two UPDATE statements (Alice decreases balance,
-- Bob increases balance) into one transaction to protect the data,
-- which guarantees the Atomicity property (atomicity) within the ACID property of the data.

--c) What would happen if the system crashed between the two UPDATE statements without a transaction?
--Q: $100.00 was withdrawn from Alice's account but never credited to Bob's account.
-- These $100 effectively disappeared from the total amount of money managed by the system.


--TASK 3.3
BEGIN;
UPDATE accounts SET balance = balance - 500.00
                WHERE name = 'Alice';
SELECT * FROM accounts WHERE name = 'Alice';-- Oops! Wrong amount, let's undo
ROLLBACK;
SELECT * FROM accounts WHERE name = 'Alice';

--a) What was Alice's balance after the UPDATE but before ROLLBACK?
--A: Balance was 400

--b) What is Alice's balance after ROLLBACK?
--A: after Rollback Alise gets her money again. 900

--c) In what situations would you use ROLLBACK in a real application?
--A: Attempt to withdraw more money than is in the account.You are trying to insert data into a table but accidentally exceed the maximum field length.


--TASK 3.4
BEGIN;
UPDATE accounts SET balance = balance - 100.00
                WHERE name = 'Alice';
SAVEPOINT my_savepoint;
UPDATE accounts SET balance = balance + 100.00
                WHERE name = 'Bob';-- Oops, should transfer to Wally instead
ROLLBACK TO my_savepoint;
UPDATE accounts SET balance = balance + 100.00
                WHERE name = 'Wally';
COMMIT;
SELECT * FROM accounts;
--a) After COMMIT, what are the balances of Alice, Bob, and Wally?
--A: Alice`s balance is 800 Bob`s 600 Wally`s 850

--b) Was Bob's account ever credited? Why or why not in the final state?
--A:Yes, Bob's account was replenished, but we used the rollback where we set a save point and canceled our request.

--c) What is the advantage of using SAVEPOINT over starting a new transaction?
--Because we don't need to create a new transaction, which would take us time. And when we make a mistake, we can go back there to change it.


--TASK 3.5
--Terminal 1:
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT * FROM products WHERE shop = 'Joe''s Shop';-- Wait for Terminal 2 to make changes and COMMIT-- Then re-run:
SELECT * FROM products WHERE shop = 'Joe''s Shop';
COMMIT;

--Terminal 2:
BEGIN;
DELETE FROM products WHERE shop = 'Joe''s Shop';
INSERT INTO products (shop, product, price)
   VALUES ('Joe''s Shop', 'Fanta', 3.50);
COMMIT;


--a) In Scenario A, what data does Terminal 1 see before and after Terminal 2 commits?
--A: Scenario A uses the READ COMMITTED isolation level. This isolation level ensures that a transaction (T1) sees only data that was committed by other transactions (T2) before T1 attempted to read it.

--b) In Scenario B, what data does Terminal 1 see?
--A: Terminal 1 (T1) will see the same dataset in both SELECT queries, but will likely fail when attempting to COMMIT

--c) Explain the difference in behavior between READ COMMITTED and SERIALIZABLE.
--READ COMMITTED: Allows you to see changes from other transactions after they've been committed. Susceptible to "Non-repeatable Read" and "Phantom Read" anomalies. (High concurrency).
--SERIALIZABLE: Ensures your transaction sees the same snapshot of data from start to finish. Prevents all read anomalies. (Low concurrency, possible serialization errors.)


--TASK 3.6
--Terminal 1:
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT MAX(price), MIN(price) FROM products
       WHERE shop = 'Joe''s Shop';-- Wait for Terminal 2
SELECT MAX(price), MIN(price) FROM products
       WHERE shop = 'Joe''s Shop';
COMMIT;

--Terminal 2:
BEGIN;
INSERT INTO products (shop, product, price)
    VALUES ('Joe''s Shop', 'Sprite', 4.00);
 COMMIT;

--a) Does Terminal 1 see the new product inserted by Terminal 2?
--A: No

--b) What is a phantom read?
--A: Phantom read is an anomaly that can occur when concurrent transactions are executed in databases.

-- c) Which isolation level prevents phantom reads?
--A: SERIALIZABLE

--TASK 3.7
--Terminal 1:
 BEGIN TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
 SELECT * FROM products WHERE shop = 'Joe''s Shop';-- Wait for Terminal 2 to UPDATE but NOT commit
 SELECT * FROM products WHERE shop = 'Joe''s Shop';-- Wait for Terminal 2 to ROLLBACK
 SELECT * FROM products WHERE shop = 'Joe''s Shop';
 COMMIT;

--Terminal 2:
BEGIN;
UPDATE products SET price = 99.99
        WHERE product = 'Fanta';-- Wait here (don't commit yet)-- Then:
ROLLBACK;

--a) Did Terminal 1 see the price of 99.99? Why is this problematic?
--A: YES. This is problematic because the 99.99 price was ROLLBACK and never existed in the database.

--b) What is a dirty read?
--A: A dirty read is the most critical and undesirable anomaly of transactional isolation, in which one transaction reads data that has been modified by another transaction but not yet committed.

--c) Why should READ UNCOMMITTED be avoided in most applications?
--A: READ UNCOMMITTED should be avoided because it can show incorrect, temporary, or inconsistent data. This can lead to wrong results and broken business logic.
