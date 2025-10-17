-- Create Database
CREATE DATABASE OnlineBookstore;

-- Switch to the database
USE OnlineBookstore;

-- Create Tables
DROP TABLE IF EXISTS Books;
CREATE TABLE Books (
    Book_ID SERIAL PRIMARY KEY,
    Title VARCHAR(100),
    Author VARCHAR(100),
    Genre VARCHAR(50),
    Published_Year INT,
    Price NUMERIC(10, 2),
    Stock INT
);
DROP TABLE IF EXISTS customers;
CREATE TABLE Customers (
    Customer_ID SERIAL PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(15),
    City VARCHAR(50),
    Country VARCHAR(150)
);
DROP TABLE IF EXISTS orders;
CREATE TABLE Orders (
    Order_ID SERIAL PRIMARY KEY,
    Customer_ID INT REFERENCES Customers(Customer_ID),
    Book_ID INT REFERENCES Books(Book_ID),
    Order_Date DATE,
    Quantity INT,
    Total_Amount NUMERIC(10, 2)
);

SELECT * FROM Books;
SELECT * FROM Customers;
SELECT * FROM Orders;


-- Import Data into Books Table
LOAD DATA LOCAL INFILE "D:/SQL/Practice Files/Books.csv"
INTO TABLE Books
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Book_ID, Title, Author, Genre, Published_Year, Price, Stock);
SHOW VARIABLES LIKE 'secure_file_priv';
SET GLOBAL local_infile = 1;

-- Import Data into Customers Table
LOAD DATA LOCAL INFILE "D:/SQL/Practice Files/Customers.csv"
INTO TABLE Customers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Customer_ID, Name, Email, Phone, City, Country);

-- Import Data into Orders Table
LOAD DATA LOCAL INFILE "D:/SQL/Practice Files/Orders.csv"
INTO TABLE Orders
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Order_ID, Customer_ID, Book_ID, Order_Date, Quantity, Total_Amount);


-- 1) Retrieve all books in the "Fiction" genre:
SELECT * FROM Books
WHERE genre = "Fiction";


-- 2) Find books published after the year 1950:
SELECT * FROM Books
WHERE published_Year > 1950;

-- 3) List all customers from the Canada:
SELECT * FROM Customers 
WHERE country LIKE '%Canada%';

-- 4) Show orders placed in November 2023:
SELECT * FROM orders
WHERE Order_date BETWEEN '2023-11-01' AND '2023-11-30';

-- 5) Retrieve the total stock of books available:
SELECT sum(stock) AS Total_Stock
FROM BOOKS;

-- 6) Find the details of the most expensive book:
SELECT * FROM Books
ORDER BY Price DESC
LIMIT 1;

-- 7) Show all customers who ordered more than 1 quantity of a book:
SELECT * FROM Orders
WHERE Quantity >1;

-- 8) Retrieve all orders where the total amount exceeds $20:
SELECT * FROM Orders
WHERE Total_Amount > 20;

-- 9) List all genres available in the Books table:
SELECT DISTINCT Genre FROM Books;

-- 10) Find the book with the lowest stock:
SELECT * FROM Books
ORDER BY Stock ASC
LIMIT 1;

-- 11) Calculate the total revenue generated from all orders:
SELECT SUM(Total_Amount) AS revenue FROM ORDERS;


-- Advance Questions : 

-- 1) Retrieve the total number of books sold for each genre:

SELECT b.Genre, SUM(o.Quantity) AS Total_book_sold
FROM Orders o
JOIN Books b
ON o.book_id = b.book_id
GROUP BY b.Genre;

-- 2) Find the average price of books in the "Fantasy" genre:

SELECT AVG(Price) AS Average_Price
FROM Books
WHERE Genre = 'Fantasy';

-- 3) List customers who have placed at least 2 orders:

SELECT c.Customer_id, c.name, COUNT(Order_id) AS Order_count
FROM Orders o
JOIN Customers c 
ON c.Customer_id = o.Customer_id
GROUP BY c.Customer_id 
HAVING COUNT(Order_id) >=2;

-- 4) Find the most frequently ordered book:

SELECT o.Book_id, b.Title, COUNT(Order_id) AS Count_order
FROM Orders o
JOIN Books b 
ON b.Book_id = o.Book_id
GROUP BY o.Book_id, b.Title
ORDER BY Count_order DESC LIMIT 1;

-- 5) Show the top 3 most expensive books of 'Fantasy' Genre:

SELECT * FROM Books
WHERE Genre = 'Fantasy'
ORDER BY Price DESC LIMIT 3;

-- 6) Retrieve the total quantity of books sold by each author:

SELECT b.Author, SUM(o.Quantity) AS Total_books_sold
FROM Orders o
JOIN Books b
ON b.Book_id = o.Book_id
GROUP BY b.Author;

-- 7) List the cities where customers who spent over $30 are located:

SELECT DISTINCT c.City, o.Total_Amount AS Spent_Amount
FROM customers c
JOIN orders o
ON c.Customer_id = o.Customer_id
WHERE o.Total_Amount > 30;

-- 8) Find the customer who spent the most on orders:

SELECT c.Customer_id, c.name, SUM(o.Total_Amount) AS Highest_spent
FROM customers c
JOIN orders o
ON c.Customer_id = o.Customer_id
GROUP BY c.Customer_id, c.name
ORDER BY Highest_spent DESC LIMIT 1;

-- 9) Calculate the stock remaining after fulfilling all orders:

SELECT b.Book_id, b.Title, b.Stock, COALESCE(SUM(o.Quantity),0) AS Order_quantity,
	b.stock - COALESCE(SUM(o.quantity),0) AS Remaining_stock
FROM books b
LEFT JOIN orders o 
ON o.Book_id = b.Book_id
GROUP BY b.Book_id
ORDER BY b.book_id;
