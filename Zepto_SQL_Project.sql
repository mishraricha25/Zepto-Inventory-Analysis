DROP TABLE Inventory;
CREATE TABLE Inventory(
SKU_id SERIAL PRIMARY KEY,
Category VARCHAR (120),
Name VARCHAR (150),
MRP NUMERIC (8,2),
DiscountPercent NUMERIC (8,2),
AvailableQTY INTEGER,
DiscountedSP NUMERIC (8,2),
WtInGrms INTEGER,
OOS BOOLEAN,
Qty INTEGER
);

--Data Observation

--Count Of Rows
SELECT COUNT (*) FROM Inventory;

--Sample Data View
SELECT * FROM Inventory;

--Null Values
SELECT * FROM Inventory WHERE Category IS NULL OR
Name IS NULL OR
Mrp IS NULL OR
discountpercent IS NULL OR
Availableqty IS NULL OR
DiscountedSP IS NULL OR
WtInGrms IS NULL OR
OOS IS NULL OR
Qty IS NULL;

--Diffrent Product Categories
SELECT DISTINCT category FROM Inventory ORDER BY Category;

--Data Cleaning
--Products with price=0
SELECT*FROM Inventory
WHERE mrp =0 OR discountedSP = 0;

DELETE FROM Inventory
WHERE Mrp=0;

--Convert Paise to Rupees
UPDATE Inventory
SET mrp = mrp/100.0,
DiscountedSP = discountedSP/100.0;

SELECT*FROM Inventory;

--Stock Checking
SELECT oos, COUNT (SKU_id)
FROM Inventory GROUP BY oos;

-- Sales & Revenue Questions
-- 1) Total Revenue Across all Products
SELECT SUM (discountedSP * qty) AS Total_Revenue FROM Inventory;

--2) Top 10 Category Contrubutes Most In Revenue 
SELECT Category, SUM (discountedSP * qty) AS Category_Revenue FROM Inventory
GROUP BY Category 
ORDER BY Category_revenue DESC LIMIT 10;

--3) Top 10 SKUs by Revenue
SELECT Name, SUM (DiscountedSP*qty) AS Product_revenue FROM Inventory 
GROUP BY name
ORDER BY Product_revenue DESC LIMIT 10;

--4) Revenue lost Due to Stock-Outs
SELECT SUM (DiscountedSP*qty) AS lost_revenue FROM Inventory
WHERE OOS=TRUE;

-- Pricing & Discount Questions
--1) Average Discount % per Category
SELECT category, AVG(discountpercent) AS avg_discount
FROM inventory
GROUP BY category
ORDER BY avg_discount DESC;

--2) Products with the Highest Discount Applied
SELECT name, category, discountpercent
FROM inventory
ORDER BY discountpercent DESC
LIMIT 10;

--3) Difference Between MRP and Discounted Selling Price
SELECT name, category, (mrp - discountedsp) AS price_difference
FROM inventory
ORDER BY price_difference DESC
LIMIT 10;

--Inventory & Stock Questions
--1) What % of SKUs are currently out of stock?

SELECT COUNT(*) FILTER (WHERE oos = TRUE) * 100.0 / COUNT(*) AS stockout_percentage
FROM inventory;

--2) Which category has the highest stock-out rate?

SELECT category, 
       COUNT(*) FILTER (WHERE oos = TRUE) * 100.0 / COUNT(*) AS stockout_rate
FROM inventory
GROUP BY category
ORDER BY stockout_rate DESC;

--3) What is the average available quantity per SKU?

SELECT AVG(availableqty) AS avg_available_quantity
FROM inventory;

--Category & Product Mix Questions

--1) Which category contributes the largest share of revenue?
SELECT category, SUM(discountedsp * qty) AS category_revenue,
       SUM(discountedsp * qty) * 100.0 / (SELECT SUM(discountedsp * qty) FROM inventory) AS revenue_share_percentage
FROM inventory
GROUP BY category
ORDER BY category_revenue DESC;

--2) Which category has the highest discount penetration?

SELECT category, AVG(discountpercent) AS avg_discount
FROM inventory
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 1;

--3) Which products are duplicated (same name, different pack sizes)?

SELECT name, COUNT(*) AS duplicate_count
FROM inventory
GROUP BY name
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- Operational & Logistics business questions

--1) Which products are heavy but low revenue (logistics cost issue)?
SELECT name, category, wtingrms, (discountedsp * qty) AS revenue
FROM inventory
WHERE wtingrms > 1000
ORDER BY revenue ASC
LIMIT 10;

--2) Which SKUs are lightweight but high revenue (profitable for delivery)?
SELECT name, category, wtingrms, (discountedsp * qty) AS revenue
FROM inventory
WHERE wtingrms < 200
ORDER BY revenue DESC
LIMIT 10;

--3) What is the average weight per SKU (important for logistics)?
SELECT category, AVG(wtingrms) AS avg_weight_per_sku
FROM inventory
GROUP BY category;


--END OF THE PROJECT









