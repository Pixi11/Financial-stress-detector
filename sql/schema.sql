-- 1st Table
CREATE TABLE dim_users (
    user_id       INTEGER PRIMARY KEY,
    gender        VARCHAR(10),
    education     VARCHAR(20),
    marriage      VARCHAR(10),
    age           INTEGER,
    credit_limit  NUMERIC(12,2),  
    age_group     VARCHAR(5)     -- '20s', '30s', '40s', '50+' 
);

-- 2nd Table
CREATE TABLE dim_time (
    time_id     VARCHAR(7) PRIMARY KEY,  
    year        INTEGER,
    month       INTEGER,
    quarter     INTEGER,
    month_name  VARCHAR(15)
);

--3rd Table
CREATE TABLE fact_transactions (
    txn_id               SERIAL PRIMARY KEY,  
    user_id              INTEGER REFERENCES dim_users(user_id),
    time_id              VARCHAR(7) REFERENCES dim_time(time_id),
    bill_amount          NUMERIC(12,2),
    payment_amount       NUMERIC(12,2),
    payment_ratio        NUMERIC(6,4),   -- how much they paid vs bill (0 to 1)
    repayment_status     INTEGER,        -- -1=paid full, 0=min, 1-9=months late
    defaulted_next_month INTEGER         -- 1=yes defaulted, 0=no
);

--4th Table
CREATE TABLE fact_macro_indicators (
    time_id              VARCHAR(7) PRIMARY KEY REFERENCES dim_time(time_id),
    unemployment_rate    NUMERIC(5,2),
    inflation_rate       NUMERIC(5,2),
    interest_rate        NUMERIC(5,2),
    consumer_confidence  NUMERIC(6,2)
);
