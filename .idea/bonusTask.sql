CREATE DATABASE bonus_lab;

CREATE TABLE customers(
    customer_id SERIAL PRIMARY KEY,
    iin CHAR(12) UNIQUE ,
    full_name VARCHAR NOT NULL ,
    phone CHAR(20) UNIQUE ,
    email VARCHAR UNIQUE ,
    status VARCHAR NOT NULL CHECK (status IN ('active','blocked','frozen') ),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    daily_limit_kzt NUMERIC
);

CREATE TABLE accounts(
    account_id SERIAL PRIMARY KEY ,
    customer_id INTEGER REFERENCES customers(customer_id),
    account_number CHAR(34) UNIQUE NOT NULL ,
    currency CHAR(3) NOT NULL CHECK ( currency IN ('KZT','USD','EUR','RUB')),
    balance NUMERIC,
    is_active BOOLEAN,
    opened_at TIMESTAMP WITH TIME ZONE,
    closed_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE transactions(
    transaction_id SERIAL PRIMARY KEY ,
    from_account_id INTEGER REFERENCES accounts(account_id),
    to_account_id INTEGER REFERENCES accounts(account_id),
    amount NUMERIC,
    currency CHAR(3),
    exchange_rate NUMERIC,
    amount_kzt NUMERIC,
    type VARCHAR CHECK ( type IN ('transfer','deposit','withdrawal')),
    status VARCHAR CHECK ( status IN ('pending','completed','failed','reversed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    description TEXT
);

CREATE TABLE exchange_rates(
    rate_id SERIAL PRIMARY KEY ,
    from_currency CHAR(3),
    to_currency CHAR(3),
    rate NUMERIC,
    valid_from TIMESTAMP WITH TIME ZONE,
    valid_to TIMESTAMP WITH TIME ZONE
);

CREATE TABLE audit_log(
    log_id SERIAL PRIMARY KEY ,
    table_name VARCHAR,
    record_id INTEGER,
    action VARCHAR NOT NULL CHECK ( action IN ('INSERT','UPDATE','DELETE')),
    old_values jsonb,
    new_values jsonb,
    changed_by VARCHAR,
    changed_at TIMESTAMP WITH TIME ZONE,
    ip_address VARCHAR
);


INSERT INTO customers VALUES
                        (1,'061111111111','Sakenuly Daniyar','87719696000','d_sakenuly@gmail.com','active',CURRENT_TIMESTAMP,5000000.0),
                        (2,'061111111122','Abl Edil','87772059900','abl@gmail.com','active',CURRENT_TIMESTAMP,5000000.0),
                        (3,'061111111133','Damir Baldash','87772052006','damir@gmail.com','active',CURRENT_TIMESTAMP,5000000.0),
                        (4,'051111111144','Daulet Kopzhasar','87772052005','dauka@gmail.com','active',CURRENT_TIMESTAMP,5000000.0),
                        (5,'061111111155','Baha Abdenov','87772057700','baha@gmail.com','active',CURRENT_TIMESTAMP,5000000.0),
                        (6,'071111111166','Tima Moldabaev','87772056600','tima@gmail.com','blocked',CURRENT_TIMESTAMP,5000000.0),
                        (7,'061111111177','Nurs VIP','87772055500','nurs@gmail.com','active',CURRENT_TIMESTAMP,5000000.0),
                        (8,'081111111188','Ers Bekzhan','8777204400','ers@gmail.com','blocked',CURRENT_TIMESTAMP,5000000.0),
                        (9,'061111111199','Beka','87772053300','beka@gmail.com','active',CURRENT_TIMESTAMP,5000000.0),
                        (10,'061111111100','Leo Messi','87772052200','lep@gmail.com','blocked',CURRENT_TIMESTAMP,5000000.0);

INSERT INTO  accounts VALUES
                        --SAKEN MEIRZHAN
                        (101,1,'KZ10111111111111111111111111111111','KZT',500000,TRUE,CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '1 month'),

                        --Abl Edil
                        (201,2,'KZ20122222222222222222222222222222','KZT',500000,TRUE,CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '2 month'),

                        --Damir Baldash
                        (301,3,'KZ30133333333333333333333333333333','KZT',500000,TRUE,CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '4 month'),
                        (302,3,'KZ30233333333333333333EURREURREU','EUR',500000,TRUE,CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '4 month'),

                        --Daulet Kopzhasar
                        (401,4,'KZ40144444444444444444444444444444','RUB',500000,TRUE,CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '5 month'),

                        --Baha Abdenov
                         (501,5,'KZ50155555555555555555555555555555','KZT',500000,TRUE,CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '6 month'),

                        --Tima Moldabaev
                        (601,6,'KZ60166666666666666666666666666666','KZT',500000,TRUE,CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

                        -- Nurs VIP
                        (701,7,'KZ70177777777777777777777777777777','KZT',500000,TRUE,CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '7 month'),

                        --Ers Bekzhan
                        (801,8,'KZ80188888888888888888888888888888','USD',50,FALSE,CURRENT_TIMESTAMP - INTERVAL '7 month', CURRENT_TIMESTAMP ),

                        --Beka
                         (901,9,'KZ90199999999999999999999999999999','KZT',500000,TRUE,CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '9 month'),

                        -- Leo Messi
                        (1001,10,'KZ10010000000000000000000000000000','KZT',500000,TRUE,CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '10 month');


INSERT INTO transactions VALUES
                        (1, 101, 201, 20000, 'KZT', 1, 20000, 'transfer', 'completed', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Saken → Abl'),
                        (2, 201, 301, 15000, 'KZT', 1, 15000, 'transfer', 'completed', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Abl → Damir'),
                        (3, 302, 301, 100, 'EUR', 600.47, 60047, 'transfer', 'completed', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'EUR → KZT'), --09.12.25 курс евро тенге 600,47
                        (4, 401, 101, 5000, 'RUB', 6.67, 33350, 'transfer', 'completed', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'RUB → KZT'),--09.12.25 курс рубль тенге 6,67
                        (5, NULL, 501, 100000, 'KZT', 1, 100000, 'deposit', 'completed', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Deposit to Baha'),
                        (6, 601, NULL, 3000, 'KZT', 1, 3000, 'withdrawal', 'completed', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Withdrawal Tima'),
                        (7, 701, 901, 25000, 'KZT', 1, 25000, 'transfer', 'pending', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Nurs → Beka'),
                        (8, 801, 901, 20, 'USD', 516.07, 10321, 'transfer', 'failed', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Ers → Beka'),--09.12.25 курс доллор тенге 516,07
                        (9, 901, 101, 10000, 'KZT', 1, 10000, 'transfer', 'completed', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Beka → Saken'),
                        (10, 1001, 201, 5000, 'KZT', 1, 5000, 'transfer', 'completed', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Messi → Abl');

INSERT INTO exchange_rates VALUES
                        (1, 'USD', 'KZT', 516.07, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '1 day'),
                        (2, 'EUR', 'KZT',600.47 , CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '1 day'),
                        (3, 'RUB', 'KZT', 6.67,  CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '1 day'),
                        (4, 'KZT', 'USD', 0.0019, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '1 day'),
                        (5, 'KZT', 'EUR', 0.0017, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '1 day'),
                        (6, 'KZT', 'RUB', 0.15, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '1 day');

INSERT INTO audit_log VALUES
                        (1, 'customers', 1, 'UPDATE', NULL, '{"status":"active"}', 'system', CURRENT_TIMESTAMP, '127.0.0.1'),
                        (2, 'accounts', 101, 'UPDATE', NULL, '{"balance":480000}', 'system', CURRENT_TIMESTAMP, '127.0.0.1'),
                        (3, 'transactions', 1, 'INSERT', NULL, '{"amount":20000}', 'system', CURRENT_TIMESTAMP, '127.0.0.1'),
                        (4, 'customers', 6, 'UPDATE', '{"status":"active"}', '{"status":"blocked"}', 'admin', CURRENT_TIMESTAMP, '127.0.0.1'),
                        (5, 'accounts', 801, 'UPDATE', '{"is_active":true}', '{"is_active":false}', 'system', CURRENT_TIMESTAMP, '127.0.0.1'),
                        (6, 'transactions', 8, 'INSERT', NULL, '{"status":"failed"}', 'system', CURRENT_TIMESTAMP, '127.0.0.1'),
                        (7, 'customers', 10, 'UPDATE', '{"status":"active"}', '{"status":"blocked"}', 'system', CURRENT_TIMESTAMP, '127.0.0.1'),
                        (8, 'accounts', 501, 'UPDATE', '{"balance":500000}', '{"balance":600000}', 'baha', CURRENT_TIMESTAMP, '127.0.0.1'),
                        (9, 'transactions', 10, 'INSERT', NULL, '{"amount":5000}', 'system', CURRENT_TIMESTAMP, '127.0.0.1'),
                        (10, 'customers', 3, 'UPDATE', '{"status":"active"}', '{"status":"active"}', 'system', CURRENT_TIMESTAMP, '127.0.0.1');



CREATE OR REPLACE PROCEDURE process_transfer(
    p_from_acc CHAR(34),
    p_to_acc   CHAR(34),
    p_amount   NUMERIC,
    p_currency CHAR(3),
    p_descr    TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    from_id INT;
    to_id   INT;
    from_cust INT;
    to_cust INT;
    from_balance NUMERIC;
    from_curr CHAR(3);
    to_curr CHAR(3);

    lim NUMERIC;
    sum_today NUMERIC;
    rate_for_receiver NUMERIC;
    rate_to_kzt NUMERIC;
    amount_to_receiver NUMERIC;
    amount_in_kzt NUMERIC;
    new_tx_id INT;
    current_ip VARCHAR := COALESCE(inet_client_addr(), '127.0.0.1')::VARCHAR;
BEGIN

    SELECT account_id, customer_id, balance, currency
    INTO from_id, from_cust, from_balance, from_curr
    FROM accounts
    WHERE account_number = p_from_acc AND is_active = TRUE
    FOR UPDATE;

    IF NOT FOUND THEN
        INSERT INTO audit_log("table_name", action, changed_at, new_values, changed_by, ip_address)
        VALUES ('accounts','FAIL', NOW(), jsonb_build_object('reason','sender not found', 'account', p_from_acc), 'system', current_ip);
        RAISE EXCEPTION 'Sender account not found';
    END IF;

    SELECT account_id, customer_id, currency
    INTO to_id, to_cust, to_curr
    FROM accounts
    WHERE account_number = p_to_acc AND is_active = TRUE
    FOR UPDATE;

    IF NOT FOUND THEN
        INSERT INTO audit_log("table_name", action, changed_at, new_values, changed_by, ip_address)
        VALUES ('accounts','FAIL', NOW(), jsonb_build_object('reason','receiver not found', 'account', p_to_acc), 'system', current_ip);
        RAISE EXCEPTION 'Receiver account not found';
    END IF;

    IF (SELECT status FROM customers WHERE customer_id = from_cust) <> 'active' THEN
        INSERT INTO audit_log("table_name", action, changed_at, new_values, changed_by, ip_address)
        VALUES ('customers','FAIL', NOW(), jsonb_build_object('reason','sender not active', 'customer_id', from_cust), 'system', current_ip);
        RAISE EXCEPTION 'Sender is not active';
    END IF;

    IF from_balance < p_amount THEN
        INSERT INTO audit_log("table_name", action, changed_at, new_values, changed_by, ip_address)
        VALUES ('accounts','FAIL', NOW(), jsonb_build_object('reason','not enough money', 'needed', p_amount, 'available', from_balance), 'system', current_ip);
        RAISE EXCEPTION 'Not enough money';
    END IF;

    IF from_curr = 'KZT' THEN
        rate_to_kzt := 1;
        amount_in_kzt := p_amount;
    ELSE
        SELECT rate INTO rate_to_kzt
        FROM exchange_rates
        WHERE from_currency = from_curr
          AND to_currency = 'KZT'
          AND now() BETWEEN valid_from AND valid_to
        LIMIT 1;

        IF rate_to_kzt IS NULL THEN
            INSERT INTO audit_log("table_name", action, changed_at, new_values, changed_by, ip_address)
            VALUES ('exchange_rates','FAIL', NOW(), jsonb_build_object('reason','no exchange rate to KZT', 'currency', from_curr), 'system', current_ip);
            RAISE EXCEPTION 'Exchange rate to KZT missing';
        END IF;

        amount_in_kzt := p_amount * rate_to_kzt;
    END IF;

    SELECT daily_limit_kzt INTO lim
    FROM customers WHERE customer_id = from_cust;

    SELECT COALESCE(SUM(amount_kzt),0)
    INTO sum_today
    FROM transactions
    WHERE "from_account_id" = from_id
      AND created_at::date = CURRENT_DATE
      AND status = 'completed';

    IF sum_today + amount_in_kzt > lim THEN
        INSERT INTO audit_log("table_name", action, changed_at, new_values, changed_by, ip_address)
        VALUES (
            'transactions',
            'FAIL',
            NOW(),
            jsonb_build_object('reason', 'daily limit exceeded', 'current_spent', sum_today, 'limit', lim, 'new_amount_kzt', amount_in_kzt),
            'system',
            current_ip
        );
        RAISE EXCEPTION 'Daily limit exceeded';
    END IF;

    IF from_curr = to_curr THEN
        rate_for_receiver := 1;
        amount_to_receiver := p_amount;
    ELSE
        SELECT rate INTO rate_for_receiver
        FROM exchange_rates
        WHERE from_currency = from_curr
          AND to_currency = to_curr
          AND now() BETWEEN valid_from AND valid_to
        LIMIT 1;

        IF rate_for_receiver IS NULL THEN
            INSERT INTO audit_log("table_name", action, changed_at, new_values, changed_by, ip_address)
            VALUES ('exchange_rates','FAIL', NOW(), jsonb_build_object('reason','no exchange rate for transfer', 'from', from_curr, 'to', to_curr), 'system', current_ip);
            RAISE EXCEPTION 'Exchange rate for transfer missing';
        END IF;

        amount_to_receiver := p_amount * rate_for_receiver;
    END IF;

    BEGIN
        UPDATE accounts
        SET balance = balance - p_amount
        WHERE account_id = from_id;

        UPDATE accounts
        SET balance = balance + amount_to_receiver
        WHERE account_id = to_id;

    EXCEPTION WHEN OTHERS THEN

        INSERT INTO audit_log("table_name", action, changed_at, new_values, changed_by, ip_address)
        VALUES (
            'accounts',
            'FAIL',
            NOW(),
            jsonb_build_object('reason', 'balance update failed', 'from_id', from_id, 'to_id', to_id, 'sqlstate', SQLSTATE, 'message', SQLERRM),
            'system',
            current_ip
        );
        RAISE EXCEPTION 'Balance update failed';
    END;

    INSERT INTO transactions(
        "from_account_id", "to_account_id", amount, currency,
        exchange_rate, amount_kzt, type, status, created_at, completed_at, description
    )
    VALUES (
        from_id, to_id, p_amount, from_curr,
        rate_for_receiver, amount_in_kzt, 'transfer', 'completed', NOW(), NOW(), p_descr
    )
    RETURNING transaction_id INTO new_tx_id;
    INSERT INTO audit_log("table_name", action, record_id, changed_by, new_values, changed_at, ip_address)
    VALUES (
        'transactions',
        'INSERT',
        new_tx_id,
        'procedural_system',
        jsonb_build_object('from',p_from_acc,'to',p_to_acc,'amount',p_amount, 'amount_kzt', amount_in_kzt),
        NOW(),
        current_ip
    );

END;
$$;

SELECT account_id, balance FROM accounts WHERE account_id IN (101, 201);
CALL process_transfer(
    p_from_acc := 'KZ10111111111111111111111111111111',
    p_to_acc   := 'KZ20122222222222222222222222222222',
    p_amount   := 100000,
    p_currency := 'KZT',
    p_descr    := 'Test: Saken -> Abl KZT'
);

SELECT account_id, balance FROM accounts WHERE account_id IN (101, 201);

--Success the different currency
SELECT account_id, balance FROM accounts WHERE account_id IN (101, 401);
CALL process_transfer(
    p_from_acc := 'KZ40144444444444444444444444444444',
    p_to_acc   := 'KZ10111111111111111111111111111111',
    p_amount   := 10000,
    p_currency := 'RUB',
    p_descr    := 'Test: Daulet -> Saken RUB->KZT'
);
SELECT account_id, balance FROM accounts WHERE account_id IN (101, 401);

--ERRORS
--Test 1: Not enough money
CALL process_transfer(
    p_from_acc := 'KZ20122222222222222222222222222222',
    p_to_acc   := 'KZ70177777777777777777777777777777',
    p_amount   := 1000000,
    p_currency := 'KZT',
    p_descr    := 'Test: Not enough money'
);

--Test2: Sender blocked
CALL process_transfer(
    p_from_acc := 'KZ60166666666666666666666666666666', -- Tima (Blocked)
    p_to_acc   := 'KZ70177777777777777777777777777777', -- Nurs (KZT)
    p_amount   := 100,
    p_currency := 'KZT',
    p_descr    := 'Test: Sender blocked'
);

--Test3: Limit exceeded'
CALL process_transfer(
    p_from_acc := 'KZ10111111111111111111111111111111',
    p_to_acc   := 'KZ70177777777777777777777777777777',
    p_amount   := 5000000,
    p_currency := 'KZT',
    p_descr    := 'Test: Limit exceeded'
);


--TASK 2
CREATE OR REPLACE VIEW customer_balance_summary AS
WITH CurrentRates AS (
    SELECT
        from_currency,
        rate
    FROM
        exchange_rates
    WHERE
        to_currency = 'KZT'

        AND now() BETWEEN valid_from AND valid_to

    UNION ALL

    SELECT
        'KZT' AS from_currency,
        1.0 AS rate
),
AccountBalancesKZT AS (

    SELECT
        a.customer_id,
        a.account_number,
        a.currency,
        a.balance,

        a.balance * COALESCE(cr.rate, 0) AS balance_kzt
    FROM
        accounts a
    LEFT JOIN
        CurrentRates cr ON a.currency = cr.from_currency
    WHERE
        a.is_active = TRUE
),
DailySpentKZT AS (
    SELECT
        a.customer_id,
        COALESCE(SUM(t.amount_kzt), 0) AS daily_spent_kzt
    FROM
        transactions t
    JOIN
        accounts a ON t.from_account_id = a.account_id
    WHERE
        t.status = 'completed'
        AND t.created_at::date = CURRENT_DATE
    GROUP BY
        a.customer_id
),
CustomerSummary AS (
     SELECT
        c.customer_id,
        c.full_name,
        c.status,
        c.daily_limit_kzt,
        SUM(ab.balance_kzt) AS total_balance_kzt,
        COALESCE(ds.daily_spent_kzt, 0) AS daily_spent_kzt,

        CASE
            WHEN c.daily_limit_kzt > 0
            THEN ROUND((COALESCE(ds.daily_spent_kzt, 0) / c.daily_limit_kzt) * 100, 2)
            ELSE 0.00
        END AS limit_utilization_percent
    FROM
        customers c
    JOIN
        AccountBalancesKZT ab ON c.customer_id = ab.customer_id
    LEFT JOIN
        DailySpentKZT ds ON c.customer_id = ds.customer_id
    GROUP BY
        c.customer_id, c.full_name, c.status, c.daily_limit_kzt, ds.daily_spent_kzt
)
SELECT
    cs.customer_id,
    cs.full_name,
    cs.status,
    ab.account_number,
    ab.currency,
    ab.balance,
    ab.balance_kzt,
    cs.total_balance_kzt,
    cs.daily_limit_kzt,
    cs.daily_spent_kzt,
    cs.limit_utilization_percent,

    RANK() OVER (ORDER BY cs.total_balance_kzt DESC) AS rank_by_total_kzt
FROM
    CustomerSummary cs
JOIN
    AccountBalancesKZT ab ON cs.customer_id = ab.customer_id
ORDER BY
    cs.total_balance_kzt DESC, cs.customer_id, ab.currency;

SELECT * FROM customer_balance_summary;


--TASK 2.1
CREATE OR REPLACE VIEW daily_transaction_report AS
WITH DailyAggregates AS (

    SELECT
        t.created_at::date AS transaction_date,
        t.type AS transaction_type,
        COUNT(t.transaction_id) AS transaction_count,
        SUM(t.amount_kzt) AS total_volume_kzt,
        AVG(t.amount_kzt) AS average_amount_kzt
    FROM
        transactions t
    WHERE
        t.status = 'completed'
    GROUP BY
        t.created_at::date, t.type
),
RunningTotals AS (

    SELECT
        transaction_date,
        transaction_type,
        transaction_count,
        total_volume_kzt,
        average_amount_kzt,

        SUM(total_volume_kzt) OVER (ORDER BY transaction_date, transaction_type) AS cumulative_volume_kzt,

        SUM(transaction_count) OVER (ORDER BY transaction_date, transaction_type) AS cumulative_count
    FROM
        DailyAggregates
),
DailyGrowth AS (

    SELECT
        rt.transaction_date,
        rt.transaction_type,
        rt.transaction_count,
        rt.total_volume_kzt,
        rt.average_amount_kzt,
        rt.cumulative_volume_kzt,
        rt.cumulative_count,

        LAG(rt.total_volume_kzt, 1) OVER (
            PARTITION BY rt.transaction_type
            ORDER BY rt.transaction_date
        ) AS previous_day_volume_kzt
    FROM
        RunningTotals rt
)
SELECT
    dg.transaction_date,
    dg.transaction_type,
    dg.transaction_count,
    dg.total_volume_kzt,
    dg.average_amount_kzt,
    dg.cumulative_volume_kzt,
    dg.cumulative_count,

    CASE
        WHEN dg.previous_day_volume_kzt IS NULL OR dg.previous_day_volume_kzt = 0
        THEN NULL
        ELSE ROUND(
            ((dg.total_volume_kzt - dg.previous_day_volume_kzt) / dg.previous_day_volume_kzt) * 100,
            2
        )
    END AS day_over_day_growth_percent

FROM
    DailyGrowth dg
ORDER BY
    dg.transaction_date, dg.transaction_type;


--TASK 2.3
CREATE OR REPLACE VIEW suspicious_activity_view
WITH (security_barrier=true)
AS
WITH LargeTransactions AS (
    SELECT
        transaction_id,
        'Large Volume' AS suspicion_reason
    FROM
        transactions
    WHERE
        amount_kzt > 5000000
),
HourlyCounts AS (
    SELECT
        t.transaction_id,
        a.customer_id,
        t.type,
        COUNT(t.transaction_id) OVER (PARTITION BY a.customer_id, date_trunc('hour', t.created_at)) AS hourly_transaction_count
    FROM
        transactions t
    JOIN
        accounts a ON t.from_account_id = a.account_id
    WHERE
        t.type = 'transfer'
),
HighFrequencyCustomers AS (
    SELECT
        transaction_id,
        'High Frequency' AS suspicion_reason
    FROM
        HourlyCounts
    WHERE
        hourly_transaction_count > 10
),
RapidTransferTimeDiff AS (
    SELECT
        t.transaction_id,
        t.from_account_id,
        t.created_at,
        t.created_at - LAG(t.created_at, 1) OVER (
            PARTITION BY t.from_account_id
            ORDER BY t.created_at
        ) AS time_diff_since_last_tx
    FROM
        transactions t
    WHERE
        t.type = 'transfer'
        AND t.from_account_id IS NOT NULL
),
RapidTransfers AS (
    SELECT
        transaction_id,
        'Rapid Sequential' AS suspicion_reason
    FROM
        RapidTransferTimeDiff
    WHERE
        time_diff_since_last_tx < INTERVAL '1 minute'
        AND time_diff_since_last_tx IS NOT NULL
),
SuspiciousSummary AS (
    SELECT * FROM LargeTransactions
    UNION ALL
    SELECT * FROM HighFrequencyCustomers
    UNION ALL
    SELECT * FROM RapidTransfers
)
SELECT
    t.transaction_id,
    c_from.full_name AS sender_name,
    c_to.full_name AS receiver_name,
    t.created_at,
    t.amount,
    t.currency,
    t.amount_kzt,
    t.description,
    t.status,
    STRING_AGG(DISTINCT ss.suspicion_reason, ', ') AS suspicion_reasons
FROM
    transactions t
JOIN
    SuspiciousSummary ss ON t.transaction_id = ss.transaction_id
JOIN
    accounts a_from ON t.from_account_id = a_from.account_id
LEFT JOIN
    accounts a_to ON t.to_account_id = a_to.account_id
JOIN
    customers c_from ON a_from.customer_id = c_from.customer_id
LEFT JOIN
    customers c_to ON a_to.customer_id = c_to.customer_id
GROUP BY
    t.transaction_id, c_from.full_name, c_to.full_name, t.created_at, t.amount, t.currency, t.amount_kzt, t.description, t.status
ORDER BY
    t.created_at DESC;

SELECT * FROM suspicious_activity_view;


--TASK 3
CREATE INDEX idx_transactions_outbound_search
ON transactions (from_account_id, created_at DESC, status);

CREATE UNIQUE INDEX idx_accounts_covering_full_data
ON accounts (account_number)
INCLUDE (account_id, customer_id, balance, currency);

CREATE INDEX idx_accounts_active_only
ON accounts (account_id, customer_id)
WHERE is_active = TRUE;

CREATE UNIQUE INDEX idx_customers_email_lower ON customers (LOWER(email));

CREATE INDEX idx_audit_log_jsonb_gin ON audit_log USING GIN (new_values);

CREATE INDEX idx_customers_iin_hash ON customers USING HASH (iin);


--TASK 4
ALTER TABLE transactions ADD COLUMN is_salary_batch BOOLEAN DEFAULT FALSE;

CREATE TABLE salary_batch_reports (
    report_id BIGSERIAL PRIMARY KEY,
    company_account CHAR(34) NOT NULL,
    batch_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    total_payments INTEGER,
    successful_count INTEGER,
    failed_count INTEGER,
    total_amount_paid NUMERIC,
    failed_details JSONB,
    processed_by VARCHAR
);

CREATE MATERIALIZED VIEW salary_batch_summary AS
SELECT
    company_account,
    batch_time,
    total_payments,
    successful_count,
    failed_count,
    total_amount_paid
FROM
    salary_batch_reports
ORDER BY batch_time DESC;



CREATE OR REPLACE PROCEDURE process_salary_batch(
    p_company_acc CHAR(34),
    p_payments_json JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
    company_id INT;
    company_acc_id INT;
    company_balance NUMERIC;
    total_batch_amount NUMERIC;

    payment_record JSONB;
    v_iin CHAR(12);
    v_amount NUMERIC;
    v_descr TEXT;

    successful_count INTEGER := 0;
    failed_count INTEGER := 0;
    failed_details JSONB := '[]'::jsonb;
    receiver_acc_id INT;
    receiver_cust_id INT;
    new_tx_id INT;
    update_list jsonb := '[]'::jsonb;
    lock_key BIGINT;
    current_ip VARCHAR := COALESCE(inet_client_addr(), '127.0.0.1')::VARCHAR;

BEGIN

    SELECT account_id, balance, customer_id INTO company_acc_id, company_balance, company_id FROM accounts WHERE account_number = p_company_acc AND is_active = TRUE FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Company account not found or inactive: %', p_company_acc; END IF;
    lock_key := company_id;
    IF pg_try_advisory_xact_lock(lock_key) THEN NULL; ELSE RAISE EXCEPTION 'Concurrent batch processing detected for company ID %', company_id; END IF;

    SELECT COALESCE(SUM((elem->>'amount')::NUMERIC), 0) INTO total_batch_amount FROM jsonb_array_elements(p_payments_json) AS elem;
    IF company_balance < total_batch_amount THEN RAISE EXCEPTION 'Total batch amount (%.2f) exceeds available balance (%.2f)', total_batch_amount, company_balance; END IF;


    FOR payment_record IN SELECT jsonb_array_elements(p_payments_json)
    LOOP

        BEGIN

            v_iin := payment_record->>'iin';
            v_amount := (payment_record->>'amount')::NUMERIC;
            v_descr := payment_record->>'description';

            SELECT a.account_id, a.customer_id INTO receiver_acc_id, receiver_cust_id
            FROM customers c JOIN accounts a ON c.customer_id = a.customer_id
            WHERE c.iin = v_iin AND a.currency = 'KZT' AND a.is_active = TRUE;

            IF NOT FOUND THEN RAISE EXCEPTION 'Receiver IIN not found or account inactive: %', v_iin; END IF;

            update_list := jsonb_insert(update_list, ARRAY['0'], jsonb_build_object('id', company_acc_id, 'change', v_amount * -1), TRUE );
            update_list := jsonb_insert(update_list, ARRAY['0'], jsonb_build_object('id', receiver_acc_id, 'change', v_amount), TRUE );

            INSERT INTO transactions(from_account_id, to_account_id, amount, currency, exchange_rate, amount_kzt, type, status, is_salary_batch, description, created_at, completed_at)
            VALUES (company_acc_id, receiver_acc_id, v_amount, 'KZT', 1, v_amount, 'transfer', 'completed', TRUE, v_descr, NOW(), NOW())
            RETURNING transaction_id INTO new_tx_id;

            successful_count := successful_count + 1;

        EXCEPTION WHEN OTHERS THEN
            failed_count := failed_count + 1;
            failed_details := failed_details || jsonb_build_object('iin', v_iin, 'amount', v_amount, 'reason', SQLERRM);


        END;
    END LOOP;

    IF successful_count > 0 THEN
        WITH GroupedUpdates AS (SELECT (elem->>'id')::INT AS account_id, SUM((elem->>'change')::NUMERIC) AS total_change FROM jsonb_array_elements(update_list) AS elem GROUP BY 1)
        UPDATE accounts a SET balance = a.balance + gu.total_change FROM GroupedUpdates gu WHERE a.account_id = gu.account_id;
    END IF;

    INSERT INTO salary_batch_reports(company_account, total_payments, successful_count, failed_count, total_amount_paid, failed_details, processed_by)
    VALUES (p_company_acc, successful_count + failed_count, successful_count, failed_count, total_batch_amount, failed_details, current_ip);

    REFRESH MATERIALIZED VIEW salary_batch_summary;

    INSERT INTO audit_log("table_name", action, changed_at, new_values, changed_by, ip_address)
    VALUES ('salary_batch', 'COMPLETED', NOW(), jsonb_build_object('company', p_company_acc, 'success', successful_count, 'failed', failed_count, 'total_amount', total_batch_amount), 'system', current_ip);

EXCEPTION WHEN OTHERS THEN
    INSERT INTO audit_log("table_name", action, changed_at, new_values, changed_by, ip_address)
    VALUES ('salary_batch', 'INSERT', NOW(), jsonb_build_object('company', p_company_acc, 'error', SQLERRM), 'system', current_ip);
    RAISE;
END;
$$;


SELECT balance, account_id FROM accounts WHERE account_number = 'KZ10111111111111111111111111111111';

DO $$
DECLARE
    company_account CHAR(34) := 'KZ10111111111111111111111111111111';
    batch_data JSONB;
BEGIN
    batch_data := '[
        {"iin": "061111111122", "amount": 100000, "description": "Salary for Ablai Edil (Payment 1: SUCCESS)"},
        {"iin": "999999999999", "amount": 20000, "description": "Non-existent employee (Payment 2: MUST FAIL)"},
        {"iin": "061111111133", "amount": 50000, "description": "Salary for Damir Baldash (Payment 3: SUCCESS)"}
    ]';

    CALL process_salary_batch(
        p_company_acc := company_account,
        p_payments_json := batch_data
    );
    RAISE NOTICE 'Procedure completed';
END $$;


SELECT balance FROM accounts WHERE account_number = 'KZ10111111111111111111111111111111';

SELECT balance FROM accounts WHERE customer_id = 2;


SELECT
    batch_time,
    total_payments,
    successful_count,
    failed_count,
    total_amount_paid,
    failed_details
FROM salary_batch_reports
ORDER BY report_id DESC
LIMIT 1;


SELECT * FROM salary_batch_summary LIMIT 1;

SELECT transaction_id, amount_kzt, status, is_salary_batch
FROM transactions
ORDER BY transaction_id DESC
LIMIT 3;
