/* Basic Stored Procedure */
DELIMITER //

CREATE PROCEDURE SelectAllCustomers()
BEGIN
	SELECT * FROM customers;
END //

DELIMITER ;

CALL SelectAllCustomers()

/* One Single Parameter Stored Procedure */
DELIMITER //

CREATE PROCEDURE SelectAllCustomersByCity( IN mycity varchar(50) )
BEGIN
	SELECT * 
    FROM customers
    WHERE city= mycity;
END //

DELIMITER ;

CALL SelectAllCustomersByCity('Singapore');

/* Two Parameters Stored Procedure */
DELIMITER //

CREATE PROCEDURE SelectAllCustomersByCityAndPCode( IN mycity varchar(50), IN pcode varchar(15) )
BEGIN
	SELECT * 
    FROM customers
    WHERE city= mycity and postalCode=pcode;
END //

DELIMITER ;

CALL SelectAllCustomersByCityAndPCode('Singapore', '079903');

/* Two Parameters Stored Procedure */
DELIMITER //

CREATE PROCEDURE SelectAllCustomersByCityAndPCode( IN mycity varchar(50), IN pcode varchar(15) )
BEGIN
	SELECT * 
    FROM customers
    WHERE city= mycity and postalCode=pcode;
END //

DELIMITER ;

CALL SelectAllCustomersByCityAndPCode('Singapore', '079903');

/*Another One Single Parameter Stored Procedure ( MLTIPLE OUTPUTS)*/
DELIMITER //

CREATE PROCEDURE get_order_by_customer(
 IN cust_no INT,
 OUT shipped INT,
 OUT canceled INT,
 OUT resolved INT,
 OUT disputed INT
 )
BEGIN
	-- shipped
    SELECT count(*) INTO shipped
	FROM orders
    WHERE customerNumber=cust_no AND status='Shipped';
    
    -- canceled
    SELECT count(*) INTO canceled
	FROM orders
    WHERE customerNumber=cust_no AND status='Canceled';
    
    -- resolved
    SELECT count(*) INTO resolved
	FROM orders
    WHERE customerNumber=cust_no AND status='Resolved';
    
    -- disputed
    SELECT count(*) INTO disputed
	FROM orders
    WHERE customerNumber=cust_no AND status='Disputed';
    
END //

DELIMITER ;

CALL get_order_by_customer(141,@shipped,@canceled,@resolved,@disputed);
SELECT @shipped,@canceled,@resolved,@disputed;

/* Another One Single Parameter Stored Procedure ( CASE STATMENT )*/
DELIMITER //

CREATE PROCEDURE GetCustomerShipping(
	IN pCustomerNumber INT,
    OUT pShipping VARCHAR(50)
)
BEGIN
	DECLARE customerCountry VARCHAR(100);
    
    SELECT country INTO customerCountry 
    FROM customers 
    WHERE customerNumber = pCustomerNumber;
		CASE customerCountry
			WHEN 'USA' THEN
				SET pShipping='2-day Shipping';
			WHEN 'Canada' THEN
				SET pShipping='3-day Shipping';
			ELSE
				SET pShipping='5-day Shipping';
		END CASE;
END //

DELIMITER ;

CALL GetCustomerShipping(112,@Shipping);
SELECT @Shipping;

CALL GetCustomerShipping(260,@Shipping);
SELECT @Shipping;

CALL GetCustomerShipping(353,@Shipping);
SELECT @Shipping;


/* Another One Single Parameter Stored Procedure ( MULTIPLE ERRORS )*/

DELIMITER //

CREATE PROCEDURE InsertSupplierProduct(
	IN inSupplierId INT,
    IN inProductId INT
)
BEGIN
	-- Exit if duplicate key occurs
    DECLARE EXIT HANDLER FOR 1062 SELECT 'Duplicate keys error encountered' Message;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION SELECT 'SQLException encountered' Message;
    DECLARE EXIT HANDLER FOR SQLSTATE '23000' SELECT 'SQLSTATE 23000' ErrorCode;
    
    -- Insert a new row in the SupplierProducts
    INSERT INTO supplierproducts(supplierdId, productId) VALUES ( inSupplierId, inProductId );
    
    -- Return the products supplied by the supplier id
    SELECT count(*) 
    FROM supplierproducts
    WHERE supplierId = inSupplierId;
END //

DELIMITER ;

CALL InsertSupplierProduct(1,1);
CALL InsertSupplierProduct(1,2);
CALL InsertSupplierProduct(1,3);

-- EXCEPTION HERE
CALL InsertSupplierProduct(1,2);
