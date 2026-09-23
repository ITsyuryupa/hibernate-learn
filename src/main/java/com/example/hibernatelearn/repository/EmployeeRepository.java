package com.example.hibernatelearn.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.example.hibernatelearn.model.Employee;

public interface EmployeeRepository extends JpaRepository<Employee, Long> {
    // No custom methods needed for batch fetch demo
}
