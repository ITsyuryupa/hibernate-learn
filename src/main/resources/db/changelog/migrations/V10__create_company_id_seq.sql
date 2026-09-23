-- Создаём последовательность только если её нет в БД
-- Если уже существует — changeSet 11 исправит INCREMENT BY
CREATE SEQUENCE IF NOT EXISTS employee_id_seq
    START WITH 1
    INCREMENT BY 50
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- Привязываем к колонке employee.id:
-- при DROP TABLE employee CASCADE последовательность удалится автоматически
ALTER SEQUENCE employee_id_seq OWNED BY employee.id;
