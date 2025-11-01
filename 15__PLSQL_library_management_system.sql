
-- Create the database
CREATE DATABASE library_management_system;
USE library_management_system;


-- 1. LANGUAGE (Static table as suggested in PDF)
CREATE TABLE LANGUAGE (
    language_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE
);


-- 2. PUBLISHER
CREATE TABLE PUBLISHER (
    publisher_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    address VARCHAR(255)
);


-- 3. BOOK (References LANGUAGE and PUBLISHER)
CREATE TABLE BOOK (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    language_id INT NOT NULL,
    mrp DECIMAL(10, 2),
    publisher_id INT,
    published_date DATE,
    volume INT DEFAULT 1,
    status ENUM('Available', 'Issued', 'Lost') DEFAULT 'Available',
    FOREIGN KEY (language_id) REFERENCES LANGUAGE(language_id),
    FOREIGN KEY (publisher_id) REFERENCES PUBLISHER(publisher_id)
);


-- 4. AUTHOR
CREATE TABLE AUTHOR (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone_number VARCHAR(15),
    status ENUM('Active', 'Inactive') DEFAULT 'Active'
);


-- 5. BOOK_AUTHOR (Many-to-Many relationship table)
CREATE TABLE BOOK_AUTHOR (
    book_id INT,
    author_id INT,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES BOOK(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES AUTHOR(author_id) ON DELETE CASCADE
);


-- 6. MEMBER (References the problem context: Student registration)
CREATE TABLE MEMBER (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    branch_code VARCHAR(50), -- Added based on common educational context
    roll_number VARCHAR(20) UNIQUE,
    phone_number VARCHAR(15),
    email_id VARCHAR(100) UNIQUE,
    date_of_join DATE DEFAULT (CURRENT_DATE()),
    status ENUM('Active', 'Suspended', 'Deleted') DEFAULT 'Active'
);


-- 7. LATE_FEE_RULE (For defining the fine structure)
CREATE TABLE LATE_FEE_RULE (
    from_days INT, -- Start of the delay period
    to_days INT,   -- End of the delay period (NULL for > 30 days)
    amount DECIMAL(10, 2) NOT NULL,
    per_day BOOLEAN DEFAULT FALSE, -- TRUE if fine is applied per day (for > 30 days)
    PRIMARY KEY (from_days)
);

-- Note: The fines will be calculated by application logic based on this table, 
-- but we must store the rules here.

-- 8. BOOK_ISSUE (Issue transaction)
CREATE TABLE BOOK_ISSUE (
    issue_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    date_of_issue DATE DEFAULT (CURRENT_DATE()),
    -- Expected return date is 14 days (two weeks) after issue date
    expected_date_of_return DATE AS (DATE_ADD(date_of_issue, INTERVAL 14 DAY)) STORED,
    status ENUM('Issued', 'Returned', 'Overdue') DEFAULT 'Issued',
    FOREIGN KEY (book_id) REFERENCES BOOK(book_id),
    FOREIGN KEY (member_id) REFERENCES MEMBER(member_id)
);


-- 9. BOOK_RETURN (Return transaction - linked by Issue_Id)
CREATE TABLE BOOK_RETURN (
    issue_id INT PRIMARY KEY, -- PK and FK to BOOK_ISSUE
    actual_date_of_return DATE DEFAULT (CURRENT_DATE()),
    late_days INT,
    late_fee DECIMAL(10, 2) DEFAULT 0.00,
    FOREIGN KEY (issue_id) REFERENCES BOOK_ISSUE(issue_id)
);

-- Optional: Create a separate table for Librarians, as seen in your DDL
CREATE TABLE LIBRARIAN (
    librarian_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone_number VARCHAR(15)
);

-- Optional: Create a separate table for Categories (renamed from your original DDL)
CREATE TABLE CATEGORY (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE
);
-- If you use this, you would add a FK (category_id) to the BOOK table.

-- Note: In a real system, the late_days and late_fee fields in BOOK_RETURN would 
-- typically be calculated by a stored procedure or application logic upon return.
