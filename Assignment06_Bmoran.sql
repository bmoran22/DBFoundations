--*************************************************************************--
-- Title: Assignment06
-- Author: BMoran
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-08-20,BMoran,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_BMoran')
	 Begin 
	  Alter Database [Assignment06DB_BMoran] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_BMoran;
	 End
	Create Database Assignment06DB_BMoran;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_BMoran;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'
GO 
-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
-- Tables Required 
--		1. Categories 2. Products 3. Employees 4. Inventories 
-- Create Categories Base View
CREATE or ALTER VIEW vCategories -- this was triggering a batch error until I added a GO after the Print above that was not included in the base code. Not sure if that is an issue or not. 
WITH SCHEMABINDING
AS
	SELECT CategoryID, CategoryName
	FROM dbo.Categories; 
GO

-- Create Products Base View
CREATE or ALTER VIEW vProducts
WITH SCHEMABINDING
AS
	SELECT ProductID, ProductName, CategoryID, UnitPrice
	FROM dbo.Products;
GO

-- Create Employees Base View
CREATE or ALTER VIEW vEmployees
WITH SCHEMABINDING
AS
	SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
	FROM dbo.Employees;
GO

-- Create Inventories Base View
CREATE or ALTER VIEW vInventories 
WITH SCHEMABINDING
AS
	SELECT InventoryID, InventoryDate, EmployeeID, ProductID, [Count]
	FROM dbo.Inventories;
GO

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

-- set category permissions 
DENY SELECT ON Categories to PUBLIC;
GRANT SELECT ON vCategories to PUBLIC;

-- set product permissions
DENY SELECT ON Products to PUBLIC;
GRANT SELECT ON vProducts to PUBLIC;

-- set Employees permissions
DENY SELECT ON Employees to PUBLIC;
GRANT SELECT ON vEmployees to PUBLIC;

-- set Inventory permissions
DENY SELECT ON Inventories to PUBLIC;
GRANT SELECT ON vInventories to PUBLIC;
GO

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
/* 
1. Columns Required:CategoryName, ProductName, UnitPrice 
2. Tables Required:
	- Categories 
	- Products 
3. Relationships
	- Categories <--> on Products on CategoryID
*/
/* Setup the Select Join Statement based on the criteria and mapping defined above int he problem 
SELECT CategoryName, ProductName, UnitPrice
FROM Categories as C
INNER JOIN Products as P
ON C.CategoryID = P.CategoryID
ORDER BY
	CategoryName ASC
	,ProductName ASC; 
GO */

--Setup Reporting View 
CREATE or ALTER VIEW vProductsByCategories
AS
	SELECT TOP 1000000
		C.CategoryName
		,P.ProductName
		,P.UnitPrice
	FROM vCategories as C -- was asked to use views from #1 instead of tables so modified these 
	INNER JOIN vProducts as P
	ON C.CategoryID = P.CategoryID
	ORDER BY
		C.CategoryName ASC, P.ProductName ASC; 
GO

-- SELECT * FROM vProductsByCategories; -- checking work 

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!
/* 
1. Columns Required: ProductName, [Count], InventoryDate
2. Tables Required:
	- Products
	- Inventories 
3. Relationships
	- Linked on ProductID  
Write base select statement based on the requirements above 
SELECT P.ProductName, I.InventoryDate, I.[Count]
FROM vProducts AS P
INNER JOIN vInventories AS I
ON P.ProductID = I.ProductID
ORDER BY 
	P.ProductName ASC*/
-- Create View based on SELECT statement written 

CREATE OR ALTER VIEW vInventoriesByProductsByDates
AS
	SELECT TOP 1000000
		P.ProductName
		,I.InventoryDate
		,I.[Count]
	FROM vProducts AS P
	INNER JOIN vInventories AS I
	ON P.ProductID = I.ProductID
	ORDER BY 
		P.ProductName ASC, I.InventoryDate ASC;
GO
-- SELECT * FROM vInventoriesByProductsByDates -- checking work
	
-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!
/*
	1. Columns Required: InventoryDate, EmployeeName
	2. Tables Required:
		- Employees
		- Inventories 
	3. Relationships
		- Linked on EmployeeID */

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

CREATE or ALTER VIEW vInventoriesByEmployeesByDates -- jumping straight to the combined view and SELECT statement after previous problem warm up 
AS
	SELECT DISTINCT TOP 1000000 -- using distinct this assignment since Group by was dinged for cost of query in previous assignment
		I.InventoryDate
		,E.EmployeeFirstName + ' ' + E.EmployeeLastName AS [Employee]
	FROM vEmployees as E
	INNER JOIN vInventories AS I
	ON E.EmployeeID = I.EmployeeID
	ORDER BY I.InventoryDate ASC;
GO
-- SELECT * FROM vInventoriesByEmployeesByDates -- checking work

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Need CategoryName, ProductName, InventoryDate, [Count]
-- Tables: Categories, Products, Inventories 
-- Relationships CategoryID and ProductID

CREATE or ALTER VIEW vInventoriesByProductsByCategories
AS
	SELECT TOP 10000000 
		C.CategoryName
		,P.ProductName
		,I.InventoryDate
		,I.[Count]
	FROM vCategories as C INNER JOIN vProducts as P
	ON C.CategoryID = P.CategoryID
	INNER JOIN vInventories as I
	ON P.ProductID = I.ProductID
	ORDER BY C.CategoryName ASC, P.ProductName ASC, I.InventoryDate, I.[Count] ASC; 
GO
-- SELECT * FROM vInventoriesByProductsByCategories -- checking work
	

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!
CREATE OR ALTER VIEW vInventoriesByProductsByEmployees
AS
	SELECT TOP 1000000
		C.CategoryName
		,P.ProductName
		,I.InventoryDate
		,I.[Count]
		,E.EmployeeFirstName + ' ' + E.EmployeeLastName as [Employee]
	FROM vCategories as C
	INNER JOIN vProducts as P
	ON C.CategoryID = P.CategoryID
	INNER JOIN Inventories as I 
	ON P.ProductID = I.ProductID
	INNER JOIN vEmployees AS E
	ON I.EmployeeID = E.EmployeeID
	ORDER BY 
		I.InventoryDate ASC
		,C.CategoryName ASC
		,P.ProductName ASC
		,E.EmployeeFirstName + ' ' + E.EmployeeLastName ASC;
GO

-- SELECT * FROM vInventoriesByProductsByEmployees -- checking work 


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

CREATE or ALTER VIEW vInventoriesForChaiAndChangByEmployees
AS
	SELECT TOP 1000000 
		c.CategoryName
		,p.ProductName
		,i.InventoryDate
		,i.[Count]
		,e.EmployeeFirstName + ' ' + EmployeeLastName AS [Employee Name]
	FROM vCategories AS c  
	INNER JOIN vProducts as p
	ON c.CategoryID = p.CategoryID
	INNER JOIN vInventories AS i
	ON p.ProductID = i.ProductID
	INNER JOIN vEmployees AS e 
	ON i.EmployeeID = e.EmployeeID
	WHERE 
		p.ProductID IN
			(SELECT ProductID
			FROM Products
			WHERE ProductName IN ('Chai', 'Chang'))
	ORDER BY
		i.InventoryDate ASC
		,c.CategoryName ASC
		,p.ProductName ASC;
GO 
-- SELECT * FROM vInventoriesForChaiAndChangByEmployees -- checking work

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
CREATE OR ALTER VIEW vEmployeesByManager
AS 
	SELECT TOP 1000000
		[Manager] = mgr.EmployeeFirstName + ' ' + mgr.EmployeeLastName
		,[Employee] = emp.EmployeeFirstName + ' ' + emp.EmployeeLastName
	FROM Employees as emp
	INNER JOIN Employees as mgr
	ON emp.ManagerID = mgr.EmployeeID -- first get the manager's ID then match that ID to the correct Employee ID
	ORDER BY
		mgr.EmployeeFirstName + ' ' + mgr.EmployeeLastName ASC
		,emp.EmployeeFirstName + ' ' + emp.EmployeeLastName ASC; -- this wasn't specified in the problem order by but seems required to get the answer to match the answer key?
GO
-- SELECT * FROM vEmployeesByManager -- checking work


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

/*-- Create a starting join statement connecting all 4 basic reporting views and add order by criteria 
-- this gets us close but we need Employee to be concatenated and Manager to be concatenated and we get duplicate columns
SELECT * 	
FROM vCategories as c
INNER JOIN vProducts as p
ON c.CategoryID = p.CategoryID
INNER JOIN vInventories as i
ON p.ProductID = i.ProductID
INNER JOIN vEmployees as e
ON i.EmployeeID = e.EmployeeID
ORDER BY
	c.CategoryName ASC
	,p.ProductName ASC
	,i.InventoryID ASC
GO
*/
-- 
CREATE or ALTER VIEW vInventoriesByProductsByCategoriesByEmployees
AS
	SELECT TOP 1000000
		-- From Categories 
		c.CategoryID
		,c.CategoryName
		-- From Products 
		,p.ProductID
		,p.ProductName
		,p.UnitPrice
		-- From Inventories 
		,i.InventoryID
		,i.InventoryDate
		,i.[Count]
		-- From Employees 
		,e.EmployeeID
		,e.EmployeeFirstName + ' ' + e.EmployeeLastName as [Employee]
		-- Manager Name (self-join on employees)
		,m.EmployeeFirstName + ' ' + m.EmployeeLastName as [Manager]
	FROM vCategories as c
	INNER JOIN vProducts as p ON c.CategoryID = p.CategoryID
	INNER JOIN vInventories as i ON p.ProductID = i.ProductID
	INNER JOIN vEmployees as e ON i.EmployeeID = e.EmployeeID
	INNER JOIN vEmployees as m ON e.ManagerID = m.EmployeeID -- first get the manager's ID then match that ID to the correct Employee ID
	ORDER BY
		c.CategoryName ASC
		,p.ProductName ASC
		,i.InventoryID ASC
		,e.EmployeeFirstName + ' ' + e.EmployeeLastName ASC;
GO
-- SELECT * FROM vInventoriesByProductsByCategoriesByEmployees -- checking work 


-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/