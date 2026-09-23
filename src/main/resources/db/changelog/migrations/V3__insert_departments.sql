INSERT INTO department (name)
VALUES ('IT'),
       ('HR'),
       ('Finance'),
       ('Marketing'),
       ('R&D')
ON CONFLICT (name) DO NOTHING;
