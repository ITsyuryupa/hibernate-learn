package com.example.hibernatelearn;

import com.example.hibernatelearn.model.Department;
import com.example.hibernatelearn.model.Employee;
import com.example.hibernatelearn.repository.DepartmentRepository;
import com.example.hibernatelearn.repository.EmployeeRepository;
import jakarta.persistence.EntityManagerFactory;
import org.hibernate.stat.Statistics;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

@Component
public class BatchDemoRunner {

    @Bean
    CommandLineRunner demo(EmployeeRepository employeeRepo,
                           DepartmentRepository departmentRepo,
                           EntityManagerFactory emf) {
        return args -> {
            Statistics stats = emf.unwrap(org.hibernate.SessionFactory.class).getStatistics();

            // ─────────────────────────────────────────────────
            // СЕКЦИЯ 1: Batch-FETCH demo
            // ─────────────────────────────────────────────────
            stats.clear();
            employeeRepo.findAll();

            System.out.println("\n╔══════════════════════════════════════════╗");
            System.out.println("║         Batch-FETCH demo                 ║");
            System.out.println("╠══════════════════════════════════════════╣");
            System.out.printf("║ Всего сотрудников в БД  : %4d           ║%n", employeeRepo.count());
            System.out.printf("║ entity fetch count      : %4d           ║%n", stats.getEntityFetchCount());
            System.out.printf("║ prepare statement count : %4d           ║%n", stats.getPrepareStatementCount());
            System.out.printf("║ batch_fetch_size (cfg)  : %4s           ║%n",
                    emf.getProperties().getOrDefault("hibernate.default_batch_fetch_size", "N/A"));
            System.out.println("╚══════════════════════════════════════════╝");

            // ─────────────────────────────────────────────────
            // СЕКЦИЯ 2: allocationSize demo
            //
            // Вставляем 60 сотрудников. allocationSize=50 означает:
            //   1-й nextval → резервирует 50 ID для сотрудников 1..50
            //   2-й nextval → резервирует 50 ID для сотрудников 51..60
            //   Итого: 2 вызова nextval вместо 60!
            //
            // SequenceCallCounter перехватывает SQL и точно считает вызовы.
            // ─────────────────────────────────────────────────
            Department dept = departmentRepo.findById(1L)
                    .orElseThrow(() -> new IllegalStateException("Department id=1 не найден"));

            int insertCount = 60;
            List<Employee> newEmployees = new ArrayList<>(insertCount);
            for (int i = 1; i <= insertCount; i++) {
                Employee e = new Employee();
                e.setFirstName("Demo" + i);
                e.setLastName("Seq");
                e.setSalary(50_000.0);
                e.setDepartment(dept);
                newEmployees.add(e);
            }

            stats.clear();
            SequenceCallCounter.reset(); // обнуляем счётчик nextval перед вставкой

            employeeRepo.saveAll(newEmployees);

            int actualNextvalCalls  = SequenceCallCounter.getNextvalCount();
            int expectedNextvalCalls = (int) Math.ceil((double) insertCount / 50);

            System.out.println("\n╔══════════════════════════════════════════════════════════╗");
            System.out.println("║              allocationSize = 50  demo                  ║");
            System.out.println("╠══════════════════════════════════════════════════════════╣");
            System.out.printf("║ Вставлено сотрудников              : %4d               ║%n", insertCount);
            System.out.printf("║ entity insert count (Hibernate)    : %4d               ║%n", stats.getEntityInsertCount());
            System.out.printf("║ prepare statement count (всего SQL): %4d               ║%n", stats.getPrepareStatementCount());
            System.out.println("╠══════════════════════════════════════════════════════════╣");
            System.out.printf("║ Реальных вызовов nextval           : %4d               ║%n", actualNextvalCalls);
            System.out.printf("║ Ожидаемых вызовов nextval          : %4d  (ceil(60/50))║%n", expectedNextvalCalls);
            System.out.printf("║ allocationSize работает корректно  : %s                ║%n",
                    actualNextvalCalls == expectedNextvalCalls ? "✅ ДА " : "❌ НЕТ");
            System.out.println("╠══════════════════════════════════════════════════════════╣");
            System.out.println("║ Без allocationSize было бы 60 вызовов nextval!           ║");
            System.out.println("╚══════════════════════════════════════════════════════════╝\n");

            // Откатываем тестовые данные
            employeeRepo.deleteAll(newEmployees);
            System.out.println("[cleanup] Тестовые сотрудники удалены.\n");
        };
    }
}
