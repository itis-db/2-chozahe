/**
  @Трофимов Александр
 */

-- 1

WITH PopularBooks AS (
    SELECT b.title, COUNT(l.book_id) AS loan_count
    FROM Books b
             JOIN Loans l ON b.id = l.book_id
    GROUP BY b.title
    ORDER BY loan_count DESC
    LIMIT 5
)
SELECT title, loan_count
FROM PopularBooks;

-- 2

SELECT r.name AS reader_name, b.title AS book_title, l.loan_date, l.return_date
FROM Readers r
         JOIN Loans l ON r.id = l.reader_id
         JOIN Books b ON l.book_id = b.id
ORDER BY r.name, l.loan_date;

-- 3

(SELECT a.name AS entity_name, 'Author' AS entity_type
 FROM Authors a
 WHERE a.name LIKE 'A%')
UNION
(SELECT g.name AS entity_name, 'Genre' AS entity_type
 FROM Genres g
 WHERE g.name LIKE 'A%')
ORDER BY entity_name;
