/* 1st Test case */
SHOW FUNCTION STATUS WHERE db = 'classicmodels';

SHOW FUNCTION STATUS WHERE Name = 'CustomerLevel';

/* 2nd Test case */
SELECT customerName, CustomerLevel( creditLimit)
FROM customers;

SELECT customerName, 
CASE WHEN creditLimit > 50000 THEN
  'PLATINUM'
 WHEN  (creditLimit >= 10000 AND creditLimit <= 50000) THEN
   'GOLD'
 WHEN  creditLimit < 10000 THEN
   'SILVER'
 END AS customerLevel 
FROM customers;

/* 3rd Test case */
CALL GetCustomerLevel(131,@customerLevel);
SELECT @customerLevel;

SELECT customerName, 
CASE WHEN creditLimit > 50000 THEN
  'PLATINUM'
 WHEN  (creditLimit >= 10000 AND creditLimit <= 50000) THEN
   'GOLD'
 WHEN  creditLimit < 10000 THEN
   'SILVER'
 END AS customerLevel 
FROM customers
WHERE customerNumber=131;

