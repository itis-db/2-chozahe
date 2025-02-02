/**
 @Трофимов Александр
*/

DROP TABLE IF EXISTS Loans;
DROP TABLE IF EXISTS Books;
DROP TABLE IF EXISTS Authors;
DROP TABLE IF EXISTS Genres;
DROP TABLE IF EXISTS Readers;

CREATE TABLE IF NOT EXISTS Authors (
                                       id SERIAL PRIMARY KEY,
                                       name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS Genres (
                                      id SERIAL PRIMARY KEY,
                                      name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS Readers (
                                       id SERIAL PRIMARY KEY,
                                       name VARCHAR(100) NOT NULL,
                                       email VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS Books (
                                     id SERIAL PRIMARY KEY,
                                     title VARCHAR(255) NOT NULL,
                                     author_id INTEGER REFERENCES Authors(id) ON DELETE SET NULL,
                                     genre_id INTEGER REFERENCES Genres(id) ON DELETE SET NULL,
                                     year_published INTEGER CHECK (year_published > 0),
                                     isbn CHAR(13) UNIQUE NOT NULL
);


CREATE TABLE IF NOT EXISTS Loans (
                                     reader_id INTEGER REFERENCES Readers(id) ON DELETE CASCADE,
                                     book_id INTEGER REFERENCES Books(id) ON DELETE CASCADE,
                                     loan_date DATE NOT NULL,
                                     return_date DATE,
                                     PRIMARY KEY (reader_id, book_id, loan_date)
);




