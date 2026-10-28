# Smart Event Management System (MySQL)

A MySQL 8.0+ practice project for the **Smart Event Management System** brief. It creates a relational database, adds sample records, and runs examples for CRUD, filtering, grouping, aggregate functions, keys, joins, subqueries, date/time functions, string functions, window functions, and `CASE`.

## Project files

```text
smart-event-management-mysql/
├── event_management.sql
└── README.md
```

## Requirements

- MySQL Server 8.0 or newer
- MySQL Workbench (recommended)
- Git (optional, for GitHub upload)

> MySQL 8.0+ is required for CTEs and window functions. `CHECK` constraints are enforced in modern MySQL versions.

## Run in MySQL Workbench

1. Open MySQL Workbench and connect to your local MySQL server.
2. Choose **File → Open SQL Script** and select `event_management.sql`.
3. Click the lightning-bolt **Execute** button to run the whole script.
4. In the **Schemas** panel, refresh and expand `smart_event_management`.
5. The script selects the project database, drops/recreates its tables, inserts demonstration data, and executes the report queries.

**Important:** This script intentionally resets the tables in `smart_event_management` each time it runs. Do not run it against a database containing data you need to keep.

## Database schema

| Table | Purpose | Primary key | Relationships |
|---|---|---|---|
| `Venues` | Venue name, city/location, capacity | `venue_id` | Referenced by `Events` |
| `Organizers` | Event organizer contact information | `organizer_id` | Referenced by `Events` |
| `Events` | Date, venue, organizer, ticket price and seats | `event_id` | Foreign keys to `Venues` and `Organizers` |
| `Attendees` | Attendee contact information | `attendee_id` | Referenced by `Tickets` |
| `Tickets` | Event bookings, booking date and status | `ticket_id` | Foreign keys to `Events` and `Attendees`; unique `(event_id, attendee_id)` |
| `Payments` | Payment amount, status and date | `payment_id` | Foreign key to `Tickets` |

### Relationship overview

- One venue can host many events.
- One organizer can manage many events.
- One event can have many ticket bookings.
- One attendee can book tickets for different events.
- Each ticket can have a payment record.
- A unique constraint prevents the same attendee from booking the same event more than once.

## Topics covered

1. Create database and tables
2. Insert sample data
3. CRUD examples (`SELECT`, commented `INSERT`, `UPDATE`, `DELETE`)
4. `WHERE`, `HAVING`, `LIMIT`
5. `AND`, `OR`, `NOT`
6. `ORDER BY`, `GROUP BY`
7. `SUM`, `AVG`, `MAX`, `MIN`, `COUNT`
8. Primary keys, foreign keys, and unique constraints
9. `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, and a `UNION`-based full-join emulation
10. Subqueries
11. `MONTH()`, `MONTHNAME()`, `DATEDIFF()`, `DATE_FORMAT()`
12. `UPPER()`, `TRIM()`, `COALESCE()`
13. `RANK()` and cumulative/running totals using window functions
14. `CASE` expressions for demand and payment labels
15. Combined ticket/payment report

## Notes about MySQL

- MySQL does **not** support `FULL OUTER JOIN` directly. The script demonstrates a `UNION`-based emulation.
- “Revenue” is calculated from payments whose status is `Success`, rather than counting failed or pending payments.
- The task asks for “ticket sales”; the running total example uses successful payment amounts as the revenue measure.
- The upcoming-event examples use `NOW()`/`CURDATE()`, so their output changes over time.
- `available_seats` is provided as a project field and sample values are not automatically adjusted when a ticket is inserted. A production system would use transactions/triggers or application logic to maintain seat counts.

## Push to GitHub

1. Create a new **empty** GitHub repository, for example `smart-event-management-mysql`.
2. Extract this project ZIP.
3. Open a terminal in the extracted folder and run:

```bash
git init
git add event_management.sql README.md
git commit -m "Add Smart Event Management MySQL project"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/smart-event-management-mysql.git
git push -u origin main
```

Replace `YOUR-USERNAME` with your GitHub username and use your own repository URL. Do not put passwords or other secrets in the SQL file or repository.

## Suggested viva preparation

Be ready to explain:
- Why primary and foreign keys are used.
- The difference between `WHERE` and `HAVING`.
- How `LEFT JOIN` differs from `INNER JOIN`.
- Why MySQL needs an alternative to `FULL OUTER JOIN`.
- How `GROUP BY` and aggregate functions produce reports.
- How `RANK()` and `SUM() OVER (...)` work.
- Why failed/pending payments are excluded from revenue.

## Troubleshooting

- **Unknown database/table:** execute the entire SQL script from the beginning.
- **Window function or CTE syntax error:** check that the server is MySQL 8.0+.
- **Foreign key error when deleting:** delete dependent payment and ticket records first, or use a carefully designed transaction.
- **No rows in a report:** check sample dates and filters; upcoming-event results change with the current date.

---
Educational project scaffold. Review the queries and understand the logic before presenting or submitting the project.
