/**
  @Трофимов Александр
 */

ALTER TABLE Books
    ALTER COLUMN isbn TYPE VARCHAR(13);

ALTER TABLE Books
    ADD COLUMN description TEXT;

ALTER TABLE Readers
    ADD COLUMN phone VARCHAR(15);

ALTER TABLE Readers
    ALTER COLUMN phone SET NOT NULL;

ALTER TABLE Books
    ADD CONSTRAINT check_year_published CHECK (year_published >= 1800);

ALTER TABLE Readers
    ADD CONSTRAINT unique_email UNIQUE (email);

--  rollback

ALTER TABLE Readers
    ALTER COLUMN phone DROP NOT NULL;

ALTER TABLE Books
    DROP CONSTRAINT check_year_published;


ALTER TABLE Readers
    DROP CONSTRAINT unique_email;
