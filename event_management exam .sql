/*
Project: Smart Event Management System
Database: MySQL 8.0+
How to run: Open this file in MySQL Workbench and execute the entire script.
Note: This script recreates the project database named smart_event_management.
*/

CREATE DATABASE IF NOT EXISTS smart_event_management;
USE smart_event_management;

-- Reset tables so the script can be run repeatedly.
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Payments;
DROP TABLE IF EXISTS Tickets;
DROP TABLE IF EXISTS Attendees;
DROP TABLE IF EXISTS Events;
DROP TABLE IF EXISTS Organizers;
DROP TABLE IF EXISTS Venues;
SET FOREIGN_KEY_CHECKS = 1;

-- 1. Create tables
CREATE TABLE Venues (
    venue_id INT AUTO_INCREMENT PRIMARY KEY,
    venue_name VARCHAR(120) NOT NULL,
    location VARCHAR(120) NOT NULL,
    capacity INT NOT NULL CHECK (capacity > 0)
);

CREATE TABLE Organizers (
    organizer_id INT AUTO_INCREMENT PRIMARY KEY,
    organizer_name VARCHAR(120) NOT NULL,
    contact_email VARCHAR(150),
    phone_number VARCHAR(25)
);

CREATE TABLE Events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    event_name VARCHAR(150) NOT NULL,
    event_date DATETIME NOT NULL,
    venue_id INT NOT NULL,
    organizer_id INT NOT NULL,
    ticket_price DECIMAL(10,2) NOT NULL CHECK (ticket_price >= 0),
    total_seats INT NOT NULL CHECK (total_seats > 0),
    available_seats INT NOT NULL CHECK (available_seats >= 0),
    CONSTRAINT fk_events_venue FOREIGN KEY (venue_id) REFERENCES Venues(venue_id),
    CONSTRAINT fk_events_organizer FOREIGN KEY (organizer_id) REFERENCES Organizers(organizer_id),
    CONSTRAINT chk_available_seats CHECK (available_seats <= total_seats)
);

CREATE TABLE Attendees (
    attendee_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    email VARCHAR(150) UNIQUE,
    phone_number VARCHAR(25)
);

CREATE TABLE Tickets (
    ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT NOT NULL,
    attendee_id INT NOT NULL,
    booking_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Confirmed', 'Cancelled', 'Pending') NOT NULL DEFAULT 'Pending',
    CONSTRAINT fk_tickets_event FOREIGN KEY (event_id) REFERENCES Events(event_id),
    CONSTRAINT fk_tickets_attendee FOREIGN KEY (attendee_id) REFERENCES Attendees(attendee_id),
    CONSTRAINT uq_attendee_event UNIQUE (event_id, attendee_id)
);

CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL,
    amount_paid DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (amount_paid >= 0),
    payment_status ENUM('Success', 'Failed', 'Pending') NOT NULL DEFAULT 'Pending',
    payment_date DATETIME NULL,
    CONSTRAINT fk_payments_ticket FOREIGN KEY (ticket_id) REFERENCES Tickets(ticket_id)
);

-- 2. Sample data (enough to demonstrate all report queries)
INSERT INTO Venues (venue_name, location, capacity) VALUES
('Riverfront Convention Hall', 'Ahmedabad', 1000),
('City Arts Auditorium', 'Surat', 500),
('Tech Park Arena', 'Vadodara', 800),
('Community Centre', 'Rajkot', 250),
('Open Learning Hall', 'Ahmedabad', 300);

INSERT INTO Organizers (organizer_name, contact_email, phone_number) VALUES
('Aarav Shah', 'aarav@example.com', '9000000001'),
('Neha Patel', 'neha@example.com', '9000000002'),
('Imran Khan', 'imran@example.com', '9000000003'),
('Meera Joshi', 'meera@example.com', '9000000004'),
('Dev Trivedi', 'dev@example.com', '9000000005');

INSERT INTO Events
(event_name, event_date, venue_id, organizer_id, ticket_price, total_seats, available_seats) VALUES
('SQL Bootcamp', DATE_ADD(NOW(), INTERVAL 10 DAY), 1, 1, 500.00, 100, 15),
('Design Futures', DATE_ADD(NOW(), INTERVAL 20 DAY), 2, 2, 750.00, 200, 80),
('Cloud Conference', DATE_ADD(NOW(), INTERVAL 30 DAY), 3, 1, 1200.00, 300, 180),
('December Music Night', STR_TO_DATE(CONCAT(YEAR(CURDATE()), '-12-15 18:30:00'), '%Y-%m-%d %H:%i:%s'), 1, 3, 900.00, 150, 100),
('Data Analytics Meetup', DATE_ADD(NOW(), INTERVAL 5 DAY), 4, 2, 400.00, 80, 50),
('Community Workshop', DATE_ADD(NOW(), INTERVAL 40 DAY), 5, 4, 250.00, 60, 60),
('Past Tech Summit', DATE_SUB(NOW(), INTERVAL 20 DAY), 3, 3, 1000.00, 120, 0),
('Free Career Talk', DATE_ADD(NOW(), INTERVAL 15 DAY), 4, 5, 0.00, 100, 70);

INSERT INTO Attendees (name, email, phone_number) VALUES
('Riya Shah', 'riya@example.com', '9100000001'),
('Kabir Patel', 'kabir@example.com', '9100000002'),
('Sara Khan', 'sara@example.com', '9100000003'),
('Arjun Mehta', 'arjun@example.com', '9100000004'),
('Pooja Desai', 'pooja@example.com', '9100000005'),
('Ishaan Joshi', 'ishaan@example.com', '9100000006'),
('Nisha Verma', 'nisha@example.com', '9100000007'),
('Om Parmar', 'om@example.com', '9100000008'),
('Tara Shah', 'tara@example.com', '9100000009'),
('Yusuf Ali', 'yusuf@example.com', '9100000010');

INSERT INTO Tickets (event_id, attendee_id, booking_date, status) VALUES
(1, 1, DATE_SUB(NOW(), INTERVAL 2 DAY), 'Confirmed'),
(1, 2, DATE_SUB(NOW(), INTERVAL 1 DAY), 'Confirmed'),
(1, 3, NOW(), 'Pending'),
(2, 1, DATE_SUB(NOW(), INTERVAL 3 DAY), 'Confirmed'),
(2, 4, NOW(), 'Confirmed'),
(3, 2, DATE_SUB(NOW(), INTERVAL 8 DAY), 'Confirmed'),
(3, 5, NOW(), 'Cancelled'),
(4, 6, NOW(), 'Pending'),
(5, 7, DATE_SUB(NOW(), INTERVAL 4 DAY), 'Confirmed'),
(5, 8, NOW(), 'Pending'),
(7, 9, DATE_SUB(NOW(), INTERVAL 10 DAY), 'Confirmed');

INSERT INTO Payments (ticket_id, amount_paid, payment_status, payment_date) VALUES
(1, 500.00, 'Success', NOW()),
(2, 500.00, 'Success', NOW()),
(3, 0.00, 'Pending', NULL),
(4, 750.00, 'Success', NOW()),
(5, 750.00, 'Failed', NOW()),
(6, 1200.00, 'Success', NOW()),
(7, 0.00, 'Failed', NOW()),
(8, 0.00, 'Pending', NULL),
(9, 400.00, 'Success', NOW()),
(10, 0.00, 'Pending', NULL),
(11, 1000.00, 'Success', NOW());

-- 3. CRUD operations
-- Search all events
SELECT * FROM Events;
-- Search all venues / organizers / attendees / tickets / payments
SELECT * FROM Venues;
SELECT * FROM Organizers;
SELECT * FROM Attendees;
SELECT * FROM Tickets;
SELECT * FROM Payments;

-- Add a sample event (commented to avoid adding duplicates on every run)
-- INSERT INTO Events (event_name, event_date, venue_id, organizer_id, ticket_price, total_seats, available_seats)
-- VALUES ('New Sample Event', DATE_ADD(NOW(), INTERVAL 60 DAY), 2, 4, 350, 100, 100);

-- Update example
-- UPDATE Events SET ticket_price = 550.00 WHERE event_id = 1;
-- Delete example (delete dependent payment/ticket rows first if needed)
-- DELETE FROM Events WHERE event_id = 8;

-- 4. WHERE, HAVING, LIMIT
-- Upcoming events in a specific city
SELECT e.event_id, e.event_name, e.event_date, v.location
FROM Events e JOIN Venues v ON v.venue_id = e.venue_id
WHERE e.event_date >= NOW() AND v.location = 'Ahmedabad'
ORDER BY e.event_date;

-- Top 5 highest revenue-generating events (successful payments only)
SELECT e.event_id, e.event_name, COALESCE(SUM(CASE WHEN p.payment_status = 'Success' THEN p.amount_paid ELSE 0 END), 0) AS total_revenue
FROM Events e
LEFT JOIN Tickets t ON t.event_id = e.event_id
LEFT JOIN Payments p ON p.ticket_id = t.ticket_id
GROUP BY e.event_id, e.event_name
ORDER BY total_revenue DESC
LIMIT 5;

-- Attendees who booked tickets in the last 7 days
SELECT DISTINCT a.attendee_id, a.name, t.booking_date
FROM Attendees a JOIN Tickets t ON t.attendee_id = a.attendee_id
WHERE t.booking_date >= DATE_SUB(NOW(), INTERVAL 7 DAY)
ORDER BY t.booking_date DESC;

-- 5. AND, OR, NOT
-- Events scheduled in December AND having more than 50% seats available
SELECT event_name, event_date, available_seats, total_seats
FROM Events
WHERE MONTH(event_date) = 12
  AND available_seats > total_seats * 0.50;

-- Attendees with a Confirmed ticket OR a Pending payment
SELECT DISTINCT a.attendee_id, a.name
FROM Attendees a
JOIN Tickets t ON t.attendee_id = a.attendee_id
LEFT JOIN Payments p ON p.ticket_id = t.ticket_id
WHERE t.status = 'Confirmed' OR p.payment_status = 'Pending';

-- Events that are NOT fully booked
SELECT event_name, total_seats, available_seats
FROM Events
WHERE NOT (available_seats = 0);

-- 6. ORDER BY and GROUP BY
SELECT event_name, event_date FROM Events ORDER BY event_date ASC;

-- Count attendees per event (bookings)
SELECT e.event_id, e.event_name, COUNT(t.ticket_id) AS attendee_count
FROM Events e LEFT JOIN Tickets t ON t.event_id = e.event_id
GROUP BY e.event_id, e.event_name
ORDER BY attendee_count DESC;

-- Total revenue per event
SELECT e.event_id, e.event_name,
       COALESCE(SUM(CASE WHEN p.payment_status = 'Success' THEN p.amount_paid ELSE 0 END), 0) AS total_revenue
FROM Events e
LEFT JOIN Tickets t ON t.event_id = e.event_id
LEFT JOIN Payments p ON p.ticket_id = t.ticket_id
GROUP BY e.event_id, e.event_name
ORDER BY total_revenue DESC;

-- 7. Aggregate functions: SUM, AVG, MAX, MIN, COUNT
SELECT COALESCE(SUM(CASE WHEN payment_status = 'Success' THEN amount_paid ELSE 0 END), 0) AS total_revenue
FROM Payments;

SELECT e.event_id, e.event_name, COUNT(t.ticket_id) AS attendee_count
FROM Events e LEFT JOIN Tickets t ON t.event_id = e.event_id
GROUP BY e.event_id, e.event_name
ORDER BY attendee_count DESC
LIMIT 1;

SELECT AVG(ticket_price) AS average_ticket_price FROM Events;
SELECT MAX(ticket_price) AS maximum_ticket_price, MIN(ticket_price) AS minimum_ticket_price FROM Events;
SELECT COUNT(*) AS total_events FROM Events;

-- 8. Primary and foreign key relationship checks
-- Unique constraint prevents the same attendee from booking the same event twice.
-- This query should return no rows if there are no duplicate attendee/event pairs.
SELECT event_id, attendee_id, COUNT(*) AS booking_count
FROM Tickets
GROUP BY event_id, attendee_id
HAVING COUNT(*) > 1;

-- Foreign key relationship: each payment references an existing ticket.
SELECT p.payment_id, p.ticket_id
FROM Payments p
LEFT JOIN Tickets t ON t.ticket_id = p.ticket_id
WHERE t.ticket_id IS NULL;

-- 9. JOINs
-- INNER JOIN: event details with venue information
SELECT e.event_name, e.event_date, v.venue_name, v.location, v.capacity
FROM Events e INNER JOIN Venues v ON v.venue_id = e.venue_id;

-- LEFT JOIN: attendees who booked a ticket but have not completed a successful payment
SELECT a.attendee_id, a.name, e.event_name, t.ticket_id, p.payment_status
FROM Attendees a
JOIN Tickets t ON t.attendee_id = a.attendee_id
JOIN Events e ON e.event_id = t.event_id
LEFT JOIN Payments p ON p.ticket_id = t.ticket_id
WHERE p.payment_status IS NULL OR p.payment_status <> 'Success';

-- RIGHT JOIN: events without attendees
SELECT e.event_id, e.event_name, t.ticket_id
FROM Tickets t RIGHT JOIN Events e ON e.event_id = t.event_id
WHERE t.ticket_id IS NULL;

-- MySQL does not support FULL OUTER JOIN directly. This UNION emulates it:
-- show attendees with ticket bookings plus attendees without bookings.
SELECT a.attendee_id, a.name, t.ticket_id
FROM Attendees a LEFT JOIN Tickets t ON t.attendee_id = a.attendee_id
UNION
SELECT a.attendee_id, a.name, t.ticket_id
FROM Attendees a RIGHT JOIN Tickets t ON t.attendee_id = a.attendee_id;

-- 10. Subqueries
-- Events with successful revenue above the average event revenue
SELECT revenue_by_event.event_id, revenue_by_event.event_name, revenue_by_event.total_revenue
FROM (
    SELECT e.event_id, e.event_name,
           COALESCE(SUM(CASE WHEN p.payment_status = 'Success' THEN p.amount_paid ELSE 0 END), 0) AS total_revenue
    FROM Events e
    LEFT JOIN Tickets t ON t.event_id = e.event_id
    LEFT JOIN Payments p ON p.ticket_id = t.ticket_id
    GROUP BY e.event_id, e.event_name
) AS revenue_by_event
WHERE revenue_by_event.total_revenue > (
    SELECT AVG(event_revenue)
    FROM (
        SELECT e2.event_id,
               COALESCE(SUM(CASE WHEN p2.payment_status = 'Success' THEN p2.amount_paid ELSE 0 END), 0) AS event_revenue
        FROM Events e2
        LEFT JOIN Tickets t2 ON t2.event_id = e2.event_id
        LEFT JOIN Payments p2 ON p2.ticket_id = t2.ticket_id
        GROUP BY e2.event_id
    ) AS average_revenue
);

-- Attendees who have booked tickets for multiple events
SELECT a.attendee_id, a.name, COUNT(DISTINCT t.event_id) AS events_booked
FROM Attendees a JOIN Tickets t ON t.attendee_id = a.attendee_id
GROUP BY a.attendee_id, a.name
HAVING COUNT(DISTINCT t.event_id) > 1;

-- Organizers who have managed more than 3 events
SELECT o.organizer_id, o.organizer_name, COUNT(e.event_id) AS events_managed
FROM Organizers o JOIN Events e ON e.organizer_id = o.organizer_id
GROUP BY o.organizer_id, o.organizer_name
HAVING COUNT(e.event_id) > 3;

-- 11. Date and time functions
SELECT event_name, event_date, MONTH(event_date) AS event_month_number,
       MONTHNAME(event_date) AS event_month_name
FROM Events;

SELECT event_name, event_date,
       DATEDIFF(event_date, NOW()) AS days_remaining
FROM Events
WHERE event_date >= NOW()
ORDER BY event_date;

SELECT payment_id, payment_date,
       DATE_FORMAT(payment_date, '%Y-%m-%d %H:%i:%s') AS formatted_payment_date
FROM Payments;

-- 12. String manipulation
SELECT organizer_id, UPPER(organizer_name) AS organizer_name_uppercase
FROM Organizers;

SELECT attendee_id, name, TRIM(name) AS attendee_name_trimmed
FROM Attendees;

SELECT attendee_id, name, COALESCE(email, 'Not Provided') AS email_display
FROM Attendees;

-- 13. Window functions (MySQL 8.0+)
-- Rank events based on total successful revenue
WITH event_revenue AS (
    SELECT e.event_id, e.event_name,
           COALESCE(SUM(CASE WHEN p.payment_status = 'Success' THEN p.amount_paid ELSE 0 END), 0) AS total_revenue
    FROM Events e
    LEFT JOIN Tickets t ON t.event_id = e.event_id
    LEFT JOIN Payments p ON p.ticket_id = t.ticket_id
    GROUP BY e.event_id, e.event_name
)
SELECT event_id, event_name, total_revenue,
       RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM event_revenue;

-- Cumulative sum of ticket sales / successful payment revenue by payment date
SELECT payment_id, payment_date, amount_paid,
       SUM(CASE WHEN payment_status = 'Success' THEN amount_paid ELSE 0 END)
           OVER (ORDER BY payment_date, payment_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_revenue
FROM Payments;

-- Running attendee booking count per event
SELECT event_id, ticket_id, attendee_id, booking_date,
       COUNT(*) OVER (PARTITION BY event_id ORDER BY booking_date, ticket_id
                      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_attendee_count
FROM Tickets;

-- 14. CASE expressions
SELECT event_id, event_name, available_seats, total_seats,
       CASE
           WHEN available_seats < total_seats * 0.20 THEN 'High Demand'
           WHEN available_seats BETWEEN total_seats * 0.20 AND total_seats * 0.50 THEN 'Moderate Demand'
           ELSE 'Low Demand'
       END AS demand_category
FROM Events;

SELECT p.payment_id, p.ticket_id, p.payment_status,
       CASE
           WHEN p.payment_status = 'Success' THEN 'Successful'
           WHEN p.payment_status = 'Failed' THEN 'Failed'
           ELSE 'Pending'
       END AS payment_status_label
FROM Payments p;

-- 15. Additional useful report: ticket bookings and payment details
SELECT e.event_name, a.name AS attendee_name, t.booking_date, t.status AS ticket_status,
       p.amount_paid, p.payment_status, p.payment_date
FROM Tickets t
JOIN Events e ON e.event_id = t.event_id
JOIN Attendees a ON a.attendee_id = t.attendee_id
LEFT JOIN Payments p ON p.ticket_id = t.ticket_id
ORDER BY t.booking_date DESC;
