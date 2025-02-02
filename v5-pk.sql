/**
  @Трофимов Александр 11-305
 */

CREATE TABLE temp_authors AS SELECT * FROM Authors;
CREATE TABLE temp_genres AS SELECT * FROM Genres;
CREATE TABLE temp_readers AS SELECT * FROM Readers;
CREATE TABLE temp_books AS SELECT * FROM Books;
CREATE TABLE temp_loans AS SELECT * FROM Loans;

-- Удаление внешних ключей
ALTER TABLE Books DROP CONSTRAINT books_author_id_fkey;
ALTER TABLE Books DROP CONSTRAINT books_genre_id_fkey;
ALTER TABLE Loans DROP CONSTRAINT loans_reader_id_fkey;
ALTER TABLE Loans DROP CONSTRAINT loans_book_id_fkey;

-- Удаление старых первичных ключей
ALTER TABLE Authors DROP CONSTRAINT authors_pkey;
ALTER TABLE Genres DROP CONSTRAINT genres_pkey;
ALTER TABLE Readers DROP CONSTRAINT readers_pkey;
ALTER TABLE Books DROP CONSTRAINT books_pkey;

-- Добавление новых первичных ключей
ALTER TABLE Authors ADD PRIMARY KEY (name);
ALTER TABLE Genres ADD PRIMARY KEY (name);
ALTER TABLE Readers ADD PRIMARY KEY (email);
ALTER TABLE Books ADD PRIMARY KEY (isbn);

-- Обновление столбцов связей
ALTER TABLE Books
    ADD COLUMN author_name VARCHAR(100),
    ADD COLUMN genre_name VARCHAR(100);

UPDATE Books b SET
                   author_name = a.name,
                   genre_name = g.name
FROM temp_books tb
         LEFT JOIN temp_authors a ON tb.author_id = a.id
         LEFT JOIN temp_genres g ON tb.genre_id = g.id
WHERE b.isbn = tb.isbn;

ALTER TABLE Books
    DROP COLUMN author_id,
    DROP COLUMN genre_id;

ALTER TABLE Loans
    ADD COLUMN reader_email VARCHAR(100),
    ADD COLUMN book_isbn CHAR(13);

UPDATE Loans l SET
                   reader_email = r.email,
                   book_isbn = b.isbn
FROM temp_loans tl
         JOIN temp_readers r ON tl.reader_id = r.id
         JOIN temp_books b ON tl.book_id = b.id
WHERE l.loan_date = tl.loan_date;

ALTER TABLE Loans
    DROP COLUMN reader_id,
    DROP COLUMN book_id;

-- Восстановление внешних ключей
ALTER TABLE Books
    ADD FOREIGN KEY (author_name) REFERENCES Authors(name),
    ADD FOREIGN KEY (genre_name) REFERENCES Genres(name);

ALTER TABLE Loans
    ADD FOREIGN KEY (reader_email) REFERENCES Readers(email),
    ADD FOREIGN KEY (book_isbn) REFERENCES Books(isbn);

-- Удаление временных таблиц
DROP TABLE temp_authors;
DROP TABLE temp_genres;
DROP TABLE temp_readers;
DROP TABLE temp_books;
DROP TABLE temp_loans;

-- Удаление суррогатных ключей
ALTER TABLE Authors DROP COLUMN id;
ALTER TABLE Genres DROP COLUMN id;
ALTER TABLE Readers DROP COLUMN id;
ALTER TABLE Books DROP COLUMN id;




-- rollback

-- Создание временных таблиц
CREATE TABLE temp_authors AS SELECT * FROM Authors;
CREATE TABLE temp_genres AS SELECT * FROM Genres;
CREATE TABLE temp_readers AS SELECT * FROM Readers;
CREATE TABLE temp_books AS SELECT * FROM Books;
CREATE TABLE temp_loans AS SELECT * FROM Loans;

-- Восстановление суррогатных ключей
ALTER TABLE Authors ADD COLUMN id SERIAL;
ALTER TABLE Genres ADD COLUMN id SERIAL;
ALTER TABLE Readers ADD COLUMN id SERIAL;
ALTER TABLE Books ADD COLUMN id SERIAL;

-- Удаление новых первичных ключей
ALTER TABLE Authors DROP CONSTRAINT IF EXISTS authors_pkey;
ALTER TABLE Genres DROP CONSTRAINT IF EXISTS genres_pkey;
ALTER TABLE Readers DROP CONSTRAINT IF EXISTS readers_pkey;
ALTER TABLE Books DROP CONSTRAINT IF EXISTS books_pkey;

-- Добавление старых первичных ключей
ALTER TABLE Authors ADD PRIMARY KEY (id);
ALTER TABLE Genres ADD PRIMARY KEY (id);
ALTER TABLE Readers ADD PRIMARY KEY (id);
ALTER TABLE Books ADD PRIMARY KEY (id);

-- Добавление старых столбцов связей
ALTER TABLE Books
    ADD COLUMN author_id INTEGER,
    ADD COLUMN genre_id INTEGER;

-- Обновление столбца author_id
UPDATE Books b
SET author_id = (
    SELECT a2.id
    FROM temp_authors a
             JOIN Authors a2 ON a.name = a2.name
    WHERE b.author_name = a.name
)
WHERE EXISTS (
    SELECT 1
    FROM temp_authors a
             JOIN Authors a2 ON a.name = a2.name
    WHERE b.author_name = a.name
);

-- Обновление столбца genre_id
UPDATE Books b
SET genre_id = (
    SELECT g2.id
    FROM temp_genres g
             JOIN Genres g2 ON g.name = g2.name
    WHERE b.genre_name = g.name
)
WHERE EXISTS (
    SELECT 1
    FROM temp_genres g
             JOIN Genres g2 ON g.name = g2.name
    WHERE b.genre_name = g.name
);

-- Удаление новых столбцов связей
ALTER TABLE Books
    DROP COLUMN author_name,
    DROP COLUMN genre_name;

-- Обновление столбца reader_id и book_id в Loans
ALTER TABLE Loans
    ADD COLUMN reader_id INTEGER,
    ADD COLUMN book_id INTEGER;

UPDATE Loans l
SET reader_id = (
    SELECT r2.id
    FROM temp_readers r
             JOIN Readers r2 ON r.email = r2.email
    WHERE l.reader_email = r.email
),
    book_id = (
        SELECT b2.id
        FROM temp_books b
                 JOIN Books b2 ON b.isbn = b2.isbn
        WHERE l.book_isbn = b.isbn
    )
WHERE EXISTS (
    SELECT 1
    FROM temp_readers r
             JOIN Readers r2 ON r.email = r2.email
    WHERE l.reader_email = r.email
) AND EXISTS (
    SELECT 1
    FROM temp_books b
             JOIN Books b2 ON b.isbn = b2.isbn
    WHERE l.book_isbn = b.isbn
);

-- Удаление новых столбцов связей в Loans
ALTER TABLE Loans
    DROP COLUMN reader_email,
    DROP COLUMN book_isbn;

-- Восстановление внешних ключей
ALTER TABLE Books
    ADD FOREIGN KEY (author_id) REFERENCES Authors(id),
    ADD FOREIGN KEY (genre_id) REFERENCES Genres(id);

ALTER TABLE Loans
    ADD FOREIGN KEY (reader_id) REFERENCES Readers(id),
    ADD FOREIGN KEY (book_id) REFERENCES Books(id);

-- Удаление временных таблиц
DROP TABLE temp_authors;
DROP TABLE temp_genres;
DROP TABLE temp_readers;
DROP TABLE temp_books;
DROP TABLE temp_loans;

