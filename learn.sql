-- =====================================================================
-- SQL ПРАКТИКУМ (PostgreSQL)
-- База данных: learn (порт 5450)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 0. ОЧИСТКА (если захочется накатить всё заново)
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS employee CASCADE;
DROP TABLE IF EXISTS department CASCADE;

-- ---------------------------------------------------------------------
-- 1. DDL: СОЗДАНИЕ ТАБЛИЦ
-- ---------------------------------------------------------------------

-- Таблица отделов (Department)
CREATE TABLE department (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- Таблица сотрудников (Employee) с внешним ключом на department
CREATE TABLE employee (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    salary NUMERIC(10, 2) CHECK (salary >= 0),
    department_id INT REFERENCES department(id) ON DELETE SET NULL,
    birth_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------------------------------
-- 2. DML: НАПОЛНЕНИЕ ДАННЫМИ
-- ---------------------------------------------------------------------

INSERT INTO department (name) VALUES 
('IT'),
('HR'),
('Finance'),
('Marketing'),
('R&D');

INSERT INTO employee (first_name, last_name, salary, department_id, birth_date) VALUES 
('Иван', 'Иванов', 120000.00, 1, '1990-05-15'),
('Анна', 'Смирнова', 180000.00, 1, '1988-11-20'),
('Петр', 'Сидоров', 95000.00, 2, '1995-03-01'),
('Елена', 'Кузнецова', 140000.00, 3, '1992-07-10'),
('Дмитрий', 'Попов', 110000.00, 1, '1994-01-25'),
('Ольга', 'Васильева', 85000.00, 4, '1998-09-05'),
('Сергей', 'Морозов', 220000.00, NULL, '1985-12-30'); -- сотрудник без отдела

-- ---------------------------------------------------------------------
-- 3. БАЗОВАЯ ВЫБОРКА И ФИЛЬТРАЦИЯ (SELECT, WHERE, ORDER BY, LIMIT)
-- ---------------------------------------------------------------------

-- Все сотрудники
SELECT * FROM employee;

-- Сотрудники с зарплатой больше 100 000
SELECT first_name, last_name, salary 
FROM employee 
WHERE salary > 100000;

-- Поиск по шаблону (LIKE / ILIKE для case-insensitive в Postgres)
SELECT * 
FROM employee 
WHERE last_name ILIKE 'иван%';

-- Сортировка по зарплате (по убыванию) с ограничением на 3 записи
SELECT first_name, last_name, salary 
FROM employee 
ORDER BY salary DESC 
LIMIT 3;

-- ---------------------------------------------------------------------
-- 4. АГРЕГАЦИИ И ГРУППИРОВКА (COUNT, AVG, SUM, GROUP BY, HAVING)
-- ---------------------------------------------------------------------

-- Общая статистика по зарплатам
SELECT 
    COUNT(*) AS total_employees,
    MIN(salary) AS min_salary,
    MAX(salary) AS max_salary,
    ROUND(AVG(salary), 2) AS avg_salary,
    SUM(salary) AS total_payroll
FROM employee;

-- Средняя зарплата по каждому отделу (только где средняя > 100 000)
SELECT 
    department_id,
    COUNT(*) AS employees_count,
    ROUND(AVG(salary), 2) AS avg_salary
FROM employee
WHERE department_id IS NOT NULL
GROUP BY department_id
HAVING AVG(salary) > 100000;

-- ---------------------------------------------------------------------
-- 5. ОБЪЕДИНЕНИЕ ТАБЛИЦ (JOINs)
-- ---------------------------------------------------------------------

-- INNER JOIN: только сотрудники с отделом
SELECT 
    e.first_name, 
    e.last_name, 
    e.salary, 
    d.name AS department_name
FROM employee e
INNER JOIN department d ON e.department_id = d.id;

-- LEFT JOIN: все сотрудники, даже если отдел NULL
SELECT 
    e.first_name, 
    e.last_name, 
    d.name AS department_name
FROM employee e
LEFT JOIN department d ON e.department_id = d.id;

-- RIGHT JOIN: все отделы, даже где пока нет сотрудников
SELECT 
    d.name AS department_name, 
    COUNT(e.id) AS employee_count
FROM employee e
RIGHT JOIN department d ON e.department_id = d.id
GROUP BY d.name;

-- ---------------------------------------------------------------------
-- 6. ПОДЗАПРОСЫ И CTE (WITH)
-- ---------------------------------------------------------------------

-- Сотрудники, чья зарплата выше средней по компании
SELECT first_name, last_name, salary 
FROM employee 
WHERE salary > (SELECT AVG(salary) FROM employee);

-- Пример с Common Table Expression (CTE)
WITH HighEarners AS (
    SELECT * 
    FROM employee 
    WHERE salary >= 140000
)
SELECT he.first_name, he.last_name, d.name AS department
FROM HighEarners he
LEFT JOIN department d ON he.department_id = d.id;

-- ---------------------------------------------------------------------
-- 7. ОКОННЫЕ ФУНКЦИИ (WINDOW FUNCTIONS)
-- ---------------------------------------------------------------------

-- Ранжирование сотрудников по зарплате внутри каждого отдела
SELECT 
    first_name,
    last_name,
    salary,
    department_id,
    DENSE_RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) as rank_in_dept
FROM employee
WHERE department_id IS NOT NULL;
