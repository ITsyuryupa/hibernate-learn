package com.example.hibernatelearn.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "department")
public class Department {
    @Id
    private Long id;
    private String name;
    // Getters and setters omitted for brevity
}
