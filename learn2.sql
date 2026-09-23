-- 1. Создаём таблицу
CREATE TABLE IF NOT EXISTS sales (
                                     id SERIAL PRIMARY KEY,
                                     user_id INTEGER NOT NULL,
                                     amount INTEGER NOT NULL
);

-- 2. Очищаем таблицу (если нужно запустить заново)
TRUNCATE TABLE sales RESTART IDENTITY;

-- 3. Вставляем тестовые данные
INSERT INTO sales (user_id, amount) VALUES
                                        (1, 100),
                                        (1, 200),
                                        (2, 300),
                                        (2, 50),
                                        (3, 70);

-- 4. Проверяем исходные данные
SELECT * FROM sales ORDER BY user_id, id;

-- 5. Пример 1: GROUP BY + SUM(amount)
SELECT
    user_id,
    SUM(amount) AS user_total
FROM sales
GROUP BY user_id
ORDER BY user_id;

-- 6. Пример 2: GROUP BY + SUM(SUM(amount)) OVER()
SELECT
    user_id,
    SUM(amount) AS user_total,
    SUM(SUM(amount)) OVER () AS all_users_total
 --      ,SUM(amount) OVER () AS all_users_total2
FROM sales
GROUP BY user_id
ORDER BY user_id;

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    user_id,
    SUM(amount) AS user_total
FROM sales
GROUP BY user_id
HAVING SUM(amount) > 100;

-- 7. Пример 3: Полный запрос с процентом
SELECT
    user_id,
    SUM(amount) AS user_total,
    SUM(SUM(amount)) OVER () AS all_users_total,
    ROUND(
            100.0 * SUM(amount) / SUM(SUM(amount)) OVER (),
            2
    ) AS percent_of_all
FROM sales
GROUP BY user_id
ORDER BY user_id;

-- 8. Пример 4: Без колонки user_total
SELECT
    user_id,
    SUM(SUM(amount)) OVER () AS all_users_total,
    ROUND(
            100.0 * SUM(amount) / SUM(SUM(amount)) OVER (),
            2
    ) AS percent_of_all
FROM sales
GROUP BY user_id
ORDER BY user_id;

-- 9. Пример 5: Ошибка с «голым» amount (раскомментировать для проверки)
-- SELECT
--     user_id,
--     amount  -- ошибка: не агрегировано
-- FROM sales
-- GROUP BY user_id;