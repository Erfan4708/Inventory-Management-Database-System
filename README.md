# Inventory Management Database System

This project is a database system designed for managing inventory in a store. The system accounts for various entities such as stores, warehouses, locations, customers, users, and catalogs. Below is a detailed explanation of the system, its design, and the SQL queries used.

## Database Design

Our university project required us to document the design process and establish relationships and attributes. The database design and its descriptions are illustrated below:

![image](https://github.com/Erfan4708/Inventory-Management-Database-System/blob/main/Diagrams/project%20E-R%20-%20original.png)

### Create Table Queries

The `CREATE TABLE` SQL queries for this design are included in the following file:

- [Create Table Queries](https://github.com/Erfan4708/Inventory-Management-Database-System/blob/main/Queries/Tabels.sql)

### Sample Queries

We have written and tested several SQL queries based on this design. You can review these queries here:

- [Sample Queries](https://github.com/Erfan4708/Inventory-Management-Database-System/blob/main/Queries/Queries.sql)

### Data Insertion Script

To test these queries, we wrote a C# script that inserts sample data into the database. The script ensures that the database is populated with the necessary sample data for testing purposes.

### Database Normalization

We normalized the database design to the Third Normal Form (3NF) to ensure data integrity and minimize redundancy. The normalized design is shown below:

![image](https://github.com/Erfan4708/Inventory-Management-Database-System/blob/main/Diagrams/project%20E-R%20-%203NF.png)

