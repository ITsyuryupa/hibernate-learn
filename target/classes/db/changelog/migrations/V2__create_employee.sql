CREATE TABLE IF NOT EXISTS employee
(
    id            SERIAL PRIMARY KEY,
    first_name    VARCHAR(50)    NOT NULL,
    last_name     VARCHAR(50)    NOT NULL,
    salary        NUMERIC(10, 2) CHECK (salary >= 0),
    department_id INT REFERENCES department (id) ON DELETE SET NULL,
    birth_date    DATE,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
