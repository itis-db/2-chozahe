/**
  @Трофимов Александр
 */

-- Вставляем 50 авторов
INSERT INTO Authors (name)
SELECT
    (ARRAY['Stephen King', 'J.K. Rowling', 'George Orwell', 'Agatha Christie', 'Ernest Hemingway',
        'Jane Austen', 'Leo Tolstoy', 'Mark Twain', 'Charles Dickens', 'Fyodor Dostoevsky',
        'J.R.R. Tolkien', 'Harper Lee', 'Dan Brown', 'George R.R. Martin', 'John Grisham',
        'Margaret Atwood', 'Toni Morrison', 'Kurt Vonnegut', 'Ray Bradbury', 'Isaac Asimov',
        'Neil Gaiman', 'Paulo Coelho', 'Khaled Hosseini', 'Gabriel Marquez', 'Hermann Hesse',
        'Virginia Woolf', 'Franz Kafka', 'Albert Camus', 'Arthur Conan Doyle', 'H.P. Lovecraft',
        'Jules Verne', 'Mary Shelley', 'Bram Stoker', 'Oscar Wilde', 'Lewis Carroll',
        'H.G. Wells', 'Edgar Poe', 'Emily Bronte', 'Charlotte Bronte', 'F. Scott Fitzgerald',
        'Homer', 'Dante Alighieri', 'Miguel de Cervantes', 'Victor Hugo', 'Alexandre Dumas',
        'Anton Chekhov', 'Herman Melville', 'Jack London', 'Rudyard Kipling', 'James Joyce'])[i]
FROM generate_series(1, 50) as s(i);

-- Вставляем 20 жанров
INSERT INTO Genres (name)
SELECT
    (ARRAY['Fiction', 'Mystery', 'Thriller', 'Romance', 'Science Fiction',
        'Fantasy', 'Historical', 'Horror', 'Biography', 'Poetry',
        'Young Adult', 'Children', 'Adventure', 'Crime', 'Drama',
        'Non-Fiction', 'Self-Help', 'Classic', 'Satire', 'Philosophy'])[i]
FROM generate_series(1, 20) as s(i);

-- Вставляем 100 читателей
INSERT INTO Readers (name, email, phone)
SELECT
    (ARRAY['John','Emma','Liam','Olivia','Noah','Ava','William','Sophia','James','Isabella',
        'Oliver','Charlotte','Benjamin','Amelia','Elijah','Mia','Lucas','Harper','Mason','Evelyn'])[FLOOR(random()*20+1)],
    'user' || s || '@library.com',
    '+1' || lpad(FLOOR(random()*9999999999)::bigint::text, 10, '0')
FROM generate_series(1,100) as s;

-- Вставляем 200 книг
INSERT INTO Books (title, author_id, genre_id, year_published, isbn, description)
SELECT
    (ARRAY['The','A','My','Your','Our'])[FLOOR(random()*5+1)] || ' ' ||
    (ARRAY['Secret','Lost','Dark','Mysterious','Forgotten'])[FLOOR(random()*5+1)] || ' ' ||
    (ARRAY['World','Journey','Dream','Legacy','Promise'])[FLOOR(random()*5+1)],
    (SELECT id FROM Authors ORDER BY random() LIMIT 1),
    (SELECT id FROM Genres ORDER BY random() LIMIT 1),
    FLOOR(random()*(2023-1800)+1800),
    lpad(FLOOR(random()*9999999999999)::bigint::text, 13, '0'),
    'A ' || (ARRAY['captivating','thought-provoking','heartwarming','chilling','epic'])[FLOOR(random()*5+1)] || ' ' ||
    (ARRAY['story','tale','novel','saga','account'])[FLOOR(random()*5+1)] || ' about ' ||
    (ARRAY['love','betrayal','adventure','discovery','survival'])[FLOOR(random()*5+1)]
FROM generate_series(1,200);

INSERT INTO Loans (reader_id, book_id, loan_date, return_date)
SELECT
    reader_id,
    book_id,
    loan_date,
    CASE
        WHEN random() < 0.7 THEN loan_date + (FLOOR(random() * 30) + 1) * INTERVAL '1 day'
        ELSE NULL
        END AS return_date
FROM (
         SELECT DISTINCT
             r.id AS reader_id,
             b.id AS book_id,
             CURRENT_DATE - INTERVAL '3 years' + FLOOR(random() * 1095) * INTERVAL '1 day' AS loan_date
         FROM Readers r
                  CROSS JOIN Books b
         WHERE MOD(b.id, 100) = MOD(r.id, 100) -- Распределяем книги между пользователями
         LIMIT 200 -- Ограничиваем количество записей до 200
     ) AS subquery
ON CONFLICT (reader_id, book_id, loan_date) DO NOTHING;
