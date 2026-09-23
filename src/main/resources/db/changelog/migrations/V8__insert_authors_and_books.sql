INSERT INTO learn.author (first_name, second_name)
VALUES ('ivan', 'nailow'),
       ('nail', 'kant')
ON CONFLICT DO NOTHING;

INSERT INTO learn.books_info (label, pages_count, author_id)
VALUES ('War', 67, 1)
ON CONFLICT (label) DO NOTHING;
