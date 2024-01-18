# Northwind SQL Queries

This repository contains a collection of SQL queries designed for the Northwind database.

## Getting the Database

The Northwind sample database can be downloaded from the official Microsoft SQL Server samples repository. Follow the instructions provided in the repository to set up the database on your local SQL Server instance.

[Northwind and Pubs Sample Databases](https://github.com/Microsoft/sql-server-samples/tree/master/samples/databases/northwind-pubs)

### Important Setup Note

After creating the Northwind database, please verify the name of the `Order Details` table. In some instances, the table name may contain a space (i.e., `Order Details`). For consistency and to avoid potential issues in the future, it's recommended to rename this table by removing the space, resulting in `OrderDetails`.

## Queries

The `Northwind_sql_queries.sql` file contains a series of SQL queries ranging from basic to advanced, designed to run on the Northwind database.
