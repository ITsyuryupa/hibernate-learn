package com.example.hibernatelearn;

import org.hibernate.resource.jdbc.spi.StatementInspector;

import java.util.concurrent.atomic.AtomicInteger;

/**
 * Перехватывает все SQL-запросы Hibernate и считает вызовы последовательности.
 * Регистрируется через hibernate.session_factory.statement_inspector.
 */
public class SequenceCallCounter implements StatementInspector {

    // static — чтобы можно было обращаться из BatchDemoRunner
    private static final AtomicInteger nextvalCount = new AtomicInteger(0);

    @Override
    public String inspect(String sql) {
        if (sql != null && sql.toLowerCase().contains("employee_id_seq")) {
            nextvalCount.incrementAndGet();
        }
        return sql; // sql не меняем, только считаем
    }

    public static int getNextvalCount() {
        return nextvalCount.get();
    }

    public static void reset() {
        nextvalCount.set(0);
    }
}
