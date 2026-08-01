# Zepto-Inventory-Analysis

## Project Overview

This SQL project analyzes E- Commerce inventory and sales data to uncover key business insights.  
The dataset includes product details such as category, MRP, discounts, stock status, available quantity, and weight.  
By writing structured SQL queries, the project answers business questions around:

- **Revenue**: Total sales, top categories, and top SKUs.  
- **Discounts**: Average discount penetration, margin impacts, and pricing strategies.  
- **Inventory**: Stock-out rates and available quantities.  
- **Product Mix**: Category contributions, duplicated SKUs.  
- **Logistics**: Order weights, heavy vs light product profitability, and delivery cost implications.  

The goal is to demonstrate how SQL can be used not only for querying data but also for deriving **actionable business intelligence** that supports decision-making in retail operations.

## Project Objectives

1. **Data Exploration & Cleaning**  
   - Inspect the dataset for null values, duplicates, and anomalies.  
   - Standardize pricing (convert paise to rupees) and remove invalid records.  

2. **Sales & Revenue Analysis**  
   - Calculate total revenue, top categories, and top SKUs.  
   - Identify revenue lost due to stock-outs.  

3. **Pricing & Discount Insights**  
   - Measure average discount penetration by category.  
   - Compare MRP vs discounted selling price to assess margin impacts.  

4. **Inventory & Stock Health**  
   - Track stock-out percentages and category-level stock-out rates.   

5. **Category & Product Mix**  
   - Evaluate revenue share by category.  
   - Detect duplicated products across pack sizes.  

6. **Operational & Logistics Analysis**  
   - Assess average order weight and SKU weight distribution.  
   - Identify heavy but low-revenue items vs lightweight, high-revenue items.

## Dataset
Downloaded raw dataset from Kaggle.
You can Download it from here: <a href ="https://github.com/mishraricha25/Zepto-Inventory-Analysis/blob/main/zepto_v2.csv">Zepto_v2.csv</a>

## Database Schema
**Table: Inventory**

| Column           | Type        | Description                          |
|------------------|------------|--------------------------------------|
| SKU_id           | SERIAL PK  | Unique product ID                    |
| Category         | VARCHAR    | Product category                     |
| Name             | VARCHAR    | Product name                         |
| MRP              | NUMERIC    | Maximum Retail Price                 |
| DiscountPercent  | NUMERIC    | Discount applied (%)                 |
| AvailableQTY     | INTEGER    | Current stock available              |
| DiscountedSP     | NUMERIC    | Selling price after discount         |
| WtInGrms         | INTEGER    | Weight in grams                      |
| OOS              | BOOLEAN    | Out of stock flag                    |
| Qty              | INTEGER    | Quantity sold                        |

---

## Business Questions & Queries

###  Sales & Revenue
```sql
-- 1) Total Revenue Across all Products
SELECT SUM(discountedSP * qty) AS Total_Revenue FROM Inventory;

-- 2) Top 10 Categories by Revenue
SELECT Category, SUM(discountedSP * qty) AS Category_Revenue
FROM Inventory
GROUP BY Category
ORDER BY Category_Revenue DESC
LIMIT 10;

-- 3) Top 10 SKUs by Revenue
SELECT Name, SUM(DiscountedSP * qty) AS Product_Revenue
FROM Inventory
GROUP BY Name
ORDER BY Product_Revenue DESC
LIMIT 10;

-- 4) Revenue Lost Due to Stock-Outs
SELECT SUM(DiscountedSP * qty) AS Lost_Revenue
FROM Inventory
WHERE OOS = TRUE;
```
### Pricing Discounts
```sql
-- 1) Average Discount % per Category
SELECT Category, AVG(DiscountPercent) AS Avg_Discount
FROM Inventory
GROUP BY Category
ORDER BY Avg_Discount DESC;

-- 2) Products with Highest Discount
SELECT Name, Category, DiscountPercent
FROM Inventory
ORDER BY DiscountPercent DESC
LIMIT 10;

-- 3) Difference Between MRP and Discounted Price
SELECT Name, Category, (MRP - DiscountedSP) AS Price_Difference
FROM Inventory
ORDER BY Price_Difference DESC
LIMIT 10;

--4) Do Higher Discounts Lead to Higher Sales Quantities?
SELECT discountpercent, AVG(qty) AS avg_quantity
FROM inventory
GROUP BY discountpercent
ORDER BY discountpercent DESC;
```
### Category & Product Mix
```sql
-- 1) Category Revenue Share
SELECT Category, SUM(DiscountedSP * qty) AS Category_Revenue,
       SUM(DiscountedSP * qty) * 100.0 / (SELECT SUM(DiscountedSP * qty) FROM Inventory) AS Revenue_Share_Percentage
FROM Inventory
GROUP BY Category
ORDER BY Category_Revenue DESC;

-- 2) Category with Highest Discount Penetration
SELECT Category, AVG(DiscountPercent) AS Avg_Discount
FROM Inventory
GROUP BY Category
ORDER BY Avg_Discount DESC
LIMIT 1;

-- 3) Duplicated Products (same name, different pack sizes)
SELECT Name, COUNT(*) AS Duplicate_Count
FROM Inventory
GROUP BY Name
HAVING COUNT(*) > 1
ORDER BY Duplicate_Count DESC;
```
### Operational & Logistics
```sql
-- 1) Heavy but Low-Revenue Products
SELECT Name, Category, WtInGrms, (DiscountedSP * qty) AS Revenue
FROM Inventory
WHERE WtInGrms > 1000
ORDER BY Revenue ASC
LIMIT 10;

-- 2) Lightweight but High-Revenue SKUs
SELECT Name, Category, WtInGrms, (DiscountedSP * qty) AS Revenue
FROM Inventory
WHERE WtInGrms < 200
ORDER BY Revenue DESC
LIMIT 10;

-- 3) Average Weight per SKU (by Category)
SELECT Category, AVG(WtInGrms) AS Avg_Weight_Per_SKU
FROM Inventory
GROUP BY Category;
```
### Inventory & Stocks
```sql
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

--4) Which items are fast-moving vs slow-moving

SELECT name, category, qty
FROM inventory
ORDER BY qty DESC
LIMIT 10;   -- Fast-moving (highest sales quantity)

SELECT name, category, qty
FROM inventory
ORDER BY qty ASC
LIMIT 10;   -- Slow-moving (lowest sales quantity)
```

## Key Insights

- **Revenue Drivers**: Packages Food & Ice-creams contribute the largest share of revenue (~65%), with Cow Ghee, Animal & Museli Foods as top SKUs.  
- **Discount Strategy**: Fresh produce has the highest discount penetration (~15–16%), showing reliance on promotions. Premium fruits have large gaps between MRP and selling price, reducing margins.  
- **Inventory Health**: About 12% of SKUs are out of stock, causing measurable lost revenue. Fast-moving items need better stocking, while slow movers (Biscuits, Beverages, Dairy Product) risk overstock.  
- **Product Mix**: Multiple pack sizes exist for key SKUs (Pasta Sour Cream Onion, Masala Oats, Quaker Oats), offering customer choice but adding inventory complexity.  
- **Logistics**: Heavy, low-revenue items (Onion, Chakki Atta ) raise delivery costs, while lightweight, high-revenue items (spices, masalas) are most profitable.

  ## Overall Conclusion

This SQL project demonstrates how structured queries can turn raw retail data into actionable insights.  

Key takeaways include:
- **Revenue** Packaged Food & Ice-cream drives most revenue (~65%).  
- **Inventory risks** such as 12% SKUs being out of stock lead to measurable lost revenue especially in fast moving SKUs. 
- **Discount strategies** Discounts are essential for fresh products like Fruits & Vegetables as well as Fish & Meats but these category does not fall under Top 10 Category Revenue generation.  
- **Product mix** with multiple pack sizes adds customer choice but increases inventory complexity.  
- **Logistics analysis** shows heavy, low-revenue items raise delivery costs, while lightweight, high-revenue items (spices, masalas) are most profitable.  

Overall, the analysis highlights how SQL can be applied beyond querying to deliver **business intelligence** that supports decisions in sales, pricing, inventory, and logistics.

