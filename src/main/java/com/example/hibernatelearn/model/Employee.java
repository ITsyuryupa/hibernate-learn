package com.example.hibernatelearn.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "employee")
public class Employee {
    @Id
    private Long id;
    private String firstName;
    private String lastName;
    private Double salary;

    @ManyToOne
    private Department department;
    // Getters and setters omitted for brevity
}
