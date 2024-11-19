create schema mysales;
use mysales;

CREATE TABLE InvoiceDetails (
    InvoiceNo VARCHAR(20) NOT NULL,
    StockCode VARCHAR(20) NOT NULL,
    Description VARCHAR(255) NOT NULL,
    Quantity INT NOT NULL,
    InvoiceDate DATETIME NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    CustomerID VARCHAR(100) NOT NULL,
    Country VARCHAR(100) NOT NULL
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Online Retail Data.csv'
INTO TABLE InvoiceDetails
FIELDS TERMINATED BY ',' -- Specify column delimiter
optionally ENCLOSED BY '"'          -- Specify text delimiter (optional)
LINES TERMINATED BY '\r\n' -- Specify row delimiter
IGNORE 1 ROWS            -- Skip the header row (optional)
(InvoiceNo, StockCode, Description, Quantity, @InvoiceDate, UnitPrice, CustomerID, Country)
SET InvoiceDate = str_to_date(@InvoiceDate, '%d/%m/%y %H:%i'); -- Specify target columns








-- cohort analysis by number of orders

WITH CTE1 AS (
    SELECT 
        InvoiceNo, CUSTOMERID, 
		INVOICEDATE, -- MySQL uses STR_TO_DATE for date parsing
        ROUND(QUANTITY * UNITPRICE, 2) AS REVENUE
    FROM invoicedetails
    WHERE CUSTOMERID IS NOT NULL
),


CTE2 AS (
    SELECT InvoiceNo, CUSTOMERID, INVOICEDATE, 
        DATE_FORMAT(INVOICEDATE, '%Y-%m-01') AS PURCHASE_MONTH, -- MySQL equivalent to truncating to month: use DATE_FORMAT
        DATE_FORMAT(MIN(INVOICEDATE) OVER (PARTITION BY CUSTOMERID ORDER BY INVOICEDATE), '%Y-%m-01') AS FIRST_PURCHASE_MONTH,
        REVENUE
    FROM CTE1
),

CTE3 AS (
    SELECT InvoiceNo, FIRST_PURCHASE_MONTH,
        CONCAT('Month_', TIMESTAMPDIFF(MONTH, FIRST_PURCHASE_MONTH, PURCHASE_MONTH)) AS COHORT_MONTH -- Use TIMESTAMPDIFF in MySQL
    FROM CTE2
)

SELECT 
    FIRST_PURCHASE_MONTH,
    SUM(CASE WHEN COHORT_MONTH = 'Month_0' THEN 1 ELSE 0 END) AS Month_0,
    SUM(CASE WHEN COHORT_MONTH = 'Month_1' THEN 1 ELSE 0 END) AS Month_1,
    SUM(CASE WHEN COHORT_MONTH = 'Month_2' THEN 1 ELSE 0 END) AS Month_2,
    SUM(CASE WHEN COHORT_MONTH = 'Month_3' THEN 1 ELSE 0 END) AS Month_3,
    SUM(CASE WHEN COHORT_MONTH = 'Month_4' THEN 1 ELSE 0 END) AS Month_4,
    SUM(CASE WHEN COHORT_MONTH = 'Month_5' THEN 1 ELSE 0 END) AS Month_5,
    SUM(CASE WHEN COHORT_MONTH = 'Month_6' THEN 1 ELSE 0 END) AS Month_6,
    SUM(CASE WHEN COHORT_MONTH = 'Month_7' THEN 1 ELSE 0 END) AS Month_7,
    SUM(CASE WHEN COHORT_MONTH = 'Month_8' THEN 1 ELSE 0 END) AS Month_8,
    SUM(CASE WHEN COHORT_MONTH = 'Month_9' THEN 1 ELSE 0 END) AS Month_9,
    SUM(CASE WHEN COHORT_MONTH = 'Month_10' THEN 1 ELSE 0 END) AS Month_10,
    SUM(CASE WHEN COHORT_MONTH = 'Month_11' THEN 1 ELSE 0 END) AS Month_11,
    SUM(CASE WHEN COHORT_MONTH = 'Month_12' THEN 1 ELSE 0 END) AS Month_12
FROM CTE3
GROUP BY FIRST_PURCHASE_MONTH
ORDER BY FIRST_PURCHASE_MONTH;
                
                
                
                