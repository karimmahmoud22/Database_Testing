/* Function that take one parameter */
DELIMITER //

CREATE FUNCTION CustomerLevel( credit Decimal(10,2) ) RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN

	DECLARE customerLevel VARCHAR(20);
    IF credit > 50000 THEN
		SET customerLevel = 'PLATINUM';
	ELSEIF (credit >= 10000 AND credit <= 50000) THEN
		SET customerLevel = 'GOLD';
	ELSEIF credit < 10000 THEN
		SET customerLevel = 'SILVER';
	END IF;
    RETURN customerLevel;
END //

DELIMITER ;

SHOW FUNCTION STATUS WHERE db = 'classicmodels';

-- CALL StoredFunction
SELECT customerName, CustomerLevel(creditLimit) FROM customers;

/* Create a StoredProcedure to call the StoredFunction inside it */

DELIMITER //

CREATE PROCEDURE GetCustomerLevel(
	IN customerNo INT,
    OUT customerLevel VARCHAR(20)
)
BEGIN

	DECLARE credit DEC(10,2) DEFAULT 0;
    
    -- Get creditLimit of the customer
    SELECT creditLimit INTO credit
    FROM customers
    WHERE customerNumber = customerNo;
    
    -- call the StoredFunction
    SET customerLevel = CustomerLevel(credit);

END //

DELIMITER ;

CALL GetCustomerLevel( 131 , @customerLevel );
SELECT @customerLevel;
