USE Classicmodels;

/* 1st test case */
SHOW PROCEDURE STATUS 
WHERE db= 'classicmodels';


/* 2nd test case */

-- Output of the procedure
call SelectAllCustomers();

-- Test Query
SELECT * FROM customers;


/* 3rd test case */

-- Output of the procedure
call SelectAllCustomersByCity('Singapore');

-- Test Query
SELECT * FROM customers
WHERE city = 'Singapore';


/* 4th test case */
-- Output of the procedure
call SelectAllCustomersByCityAndPCode('Singapore','079903');

-- Test Query
SELECT * FROM customers
WHERE city = 'Singapore' AND postalCode='079903';


/* 5th test case */
-- Output of the procedure
call get_order_by_customer(141,@shipped,@canceled,@resolved,@disputed);
SELECT @shipped,@canceled,@resolved,@disputed;

-- Test Query
SELECT
(SELECT count(*) AS 'shipped'
FROM orders
WHERE customerNumber=141 AND status='Shipped') as Shipped,

(SELECT count(*) AS 'canceled'
FROM orders
WHERE customerNumber=141 AND status='Canceled') as Canceled,

(SELECT count(*) AS 'resolved'
FROM orders
WHERE customerNumber=141 AND status='Resolved') as Resolved,

(SELECT count(*) AS 'disputed'
FROM orders
WHERE customerNumber=141 AND status='Disputed') as Disputed;

/* 6th test case */
-- Output of the procedure
CALL GetCustomerShipping(112, @shipping);
SELECT @shipping AS ShippingTime;

CALL GetCustomerShipping(260, @shipping);
SELECT @shipping AS ShippingTime;

CALL GetCustomerShipping(353, @shipping);
SELECT @shipping AS ShippingTime;

-- Test Query
SELECT country, 
  CASE 
   WHEN country='USA' THEN 
                  '2-day Shipping'
   WHEN country='Canada' THEN
                  '3-day Shipping'
   ELSE      '5-day Shipping'
  END AS ShippingTime
  FROM customers
  WHERE customerNumber=112;

SELECT country, 
  CASE 
   WHEN country='USA' THEN 
                  '2-day Shipping'
   WHEN country='Canada' THEN
                  '3-day Shipping'
   ELSE      '5-day Shipping'
  END AS ShippingTime
  FROM customers
  WHERE customerNumber=260;
  
  SELECT country, 
  CASE 
   WHEN country='USA' THEN 
                  '2-day Shipping'
   WHEN country='Canada' THEN
                  '3-day Shipping'
   ELSE      '5-day Shipping'
  END AS ShippingTime
  FROM customers
  WHERE customerNumber=353;