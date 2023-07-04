USE classicmodels;

/* -------------- BEFORE INSERTION TRIGGER -------------- */

DROP TABLE IF EXISTS workCenters;
DROP TABLE IF EXISTS workCenterStats;

/* -------------- CREATING TABLES -------------- */
CREATE TABLE workCenters(
	id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    capacity INT NOT NULL
);

CREATE TABLE workCenterStats(
    totalCapacity INT NOT NULL
);

/* -------------- THE TRIGGER -------------- */
DELIMITER //
CREATE TRIGGER before_workcenters_insert BEFORE INSERT ON workCenters FOR EACH ROW
BEGIN
	DECLARE rowcount INT;
    
    SELECT count(*) INTO rowcount FROM workcenters;
    
    IF rowcount > 0 THEN
		UPDATE workcenterstats SET totalCapacity = totalCapacity + new.capacity;
	ELSE
		INSERT INTO workcenterstats(totalCapacity) VALUES (new.capacity);
	END IF;
    
END //

DELIMITER ;

/* -------------- Testing the Trigger -------------- */

SHOW TRIGGERS;

INSERT INTO workcenters(name, capacity) VALUES ('Mold Machine',100);

SELECT * FROM workcenters;
SELECT * FROM workcenterstats;

INSERT INTO workcenters(name, capacity) VALUES ('Packing',200);

SELECT * FROM workcenters;
SELECT * FROM workcenterstats;

/* -------------- AFTER INSERTION TRIGGER -------------- */

/* -------------- CREATING THE TABLES -------------- */
CREATE TABLE members(
	id INT AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255),
    birthDate DATE,
    PRIMARY KEY (id)
);

CREATE TABLE reminders(
	id INT AUTO_INCREMENT,
    memberId INT,
    message VARCHAR(255) NOT NULL,
    PRIMARY KEY( id, memberId)
);

DELIMITER //

/* -------------- CREATING THE TRIGGER -------------- */
CREATE TRIGGER after_members_insert AFTER INSERT ON members FOR EACH ROW
BEGIN
	IF NEW.birthDate IS NULL THEN INSERT INTO reminders ( memberId, message )
		VALUES (new.id,CONCAT('hI ', NEW.name, ', please update your date of birth.'));
	END IF;
END //

DELIMITER ;

/* -------------- TESTING THE TRIGGER -------------- */

SHOW TRIGGERS;

INSERT INTO members(name, email, birthDate) VALUES ('Jogn','john@example.com', NULL);

SELECT * FROM members;
SELECT * FROM reminders;

INSERT INTO members(name, email, birthDate) VALUES ('Kim','kim@example.com', '2012-05-03');

SELECT * FROM members;
SELECT * FROM reminders;

/* -------------- BEFORE UPDATE TRIGGER --------------*/

/* -------------- CREATING THE TABLES -------------- */
CREATE TABLE sales(
	id INT AUTO_INCREMENT,
    product VARCHAR(100) NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    fiscalYear SMALLINT NOT NULL,
    fiscalMonth TINYINT NOT NULL,
    CHECK( fiscalMonth>=1 AND fiscalMonth <=12 ),
    CHECK( fiscalYear BETWEEN 2000 AND 2050 ),
    UNIQUE( product, fiscalYear, fiscalMonth),
    PRIMARY KEY (id)
);

/* -------------- INSERTING THE DATA -------------- */
INSERT INTO sales (product, quantity, fiscalYear, fiscalMonth) VALUES
	('2003 Harley-Davidson Eagle Drag Bike', 120, 2020, 1),
    ('1969 Corvair Monza', 150, 2020, 1),
    ('1970 Plymouth Hemi Cuda', 200, 2020, 1);

SELECT * FROM sales;

DELIMITER //

/* -------------- CREATING THE TRIGGER -------------- */
CREATE TRIGGER before_sales_update BEFORE UPDATE ON sales FOR EACH ROW
BEGIN
	DECLARE errorMessage VARCHAR(255);
    SET errorMessage = CONCAT('The new quantity ', NEW.quantity,
							   ' cannot be 3 times greater than the current quantity ',OLD.quantity);
	IF NEW.quantity > OLD.quantity * 3 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT= errorMessage;
	END IF;
END //

DELIMITER ;

/* -------------- TESTING THE TRIGGER -------------- */
SHOW TRIGGERS;

/* successfully updated */
UPDATE sales
SET quantity = 150 
WHERE id =1;

/* Failed to update */
UPDATE sales
SET quantity = 500 
WHERE id =1;

/* -------------- AFTER UPDATE TRIGGER -------------- */

/* -------------- CREATING THE TABLES -------------- */
CREATE TABLE salesChanges(
	id INT AUTO_INCREMENT PRIMARY KEY,
    salesId INT,
    beforeQuantity INT,
    afterQuantity INT,
    changedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

/* -------------- CREATING THE TRIGGER -------------- */
CREATE TRIGGER after_sales_update BEFORE UPDATE ON sales FOR EACH ROW
BEGIN
	IF OLD.quantity <> NEW.quantity THEN
		INSERT INTO salesChanges(salesId, beforeQuantity, afterQuantity)
        VALUES (OLD.id, OLD.quantity, NEW.quantity);
    END IF;
END //

DELIMITER ;

/* -------------- TESTING THE TRIGGER -------------- */
SHOW TRIGGERS;

SELECT * FROM sales;
SELECT * FROM salesChanges;

/* update a single row */
UPDATE sales
SET quantity = 350 
WHERE id =1;

/* Update multiple rows */
UPDATE sales
SET quantity =CAST( quantity * 1.1 AS UNSIGNED ); 


/* -------------- BEFORE DELETE TRIGGER -------------- */

/* -------------- CREATING THE TABLES -------------- */
CREATE TABLE salaries(
	employerNumber INT PRIMARY KEY,
    validForm DATE NOT NULL,
    salary DEC(12,2) NOT NULL DEFAULT 0
); 

INSERT INTO salaries( employerNumber, validForm, salary )
VALUES (1002, '2000-01-01', 50000),
	   (1056, '2000-01-01', 60000),
       (1076, '2000-01-01', 70000);

SELECT * FROM salaries;

CREATE TABLE salaryArchives(
	id INT PRIMARY KEY AUTO_INCREMENT,
    employerNumber INT ,
    validForm DATE NOT NULL,
    salary DEC(12,2) NOT NULL DEFAULT 0,
    deletedAt TIMESTAMP DEFAULT NOW()
); 

SELECT * FROM salaryArchives;

/* -------------- CREATING THE TRIGGER -------------- */
DELIMITER //
CREATE TRIGGER before_salaries_delete BEFORE DELETE ON salaries FOR EACH ROW
BEGIN
	INSERT INTO salaryArchives(employerNumber, validForm, salary)
    VALUES (OLD.employerNumber, OLD.validForm, OLD.salary);
END //
DELIMITER ;

/* --------------- TESTING THE TRIGGER --------------- */
SHOW TRIGGERS;

/* --------------- DELETE ONE RECORD --------------- */
DELETE FROM salaries
WHERE employerNumber = 1056 ;

SELECT * FROM salaries;
SELECT * FROM salaryArchives;

/* --------------- DELETE MULTIPLE RECORDS --------------- */
DELETE FROM salaries;

/* --------------- AFTER DELETE TRIGGER --------------- */

/* --------------- CREATING THE TABLES --------------- */
CREATE TABLE salaryBudgets (
	total DEC(15,2) NOT NULL
);

INSERT INTO salaries( employerNumber, validForm, salary )
VALUES (1002, '2000-01-01', 50000),
	   (1056, '2000-01-01', 60000),
       (1076, '2000-01-01', 70000);
       
INSERT INTO salaryBudgets(total) SELECT SUM(salary) FROM salaries;

SELECT * FROM salaries;
SELECT * FROM salaryBudgets;

/* -------------- CREATING THE TRIGGER -------------- */
DELIMITER //
CREATE TRIGGER after_salaries_delete BEFORE DELETE ON salaries FOR EACH ROW
BEGIN
	UPDATE salaryBudgets SET total = total - old.salary;
END //
DELIMITER ;

/* --------------- TESTING THE TRIGGER --------------- */
SHOW TRIGGERS;

/* --------------- DELETE ONE RECORD --------------- */
DELETE FROM salaries
WHERE employerNumber = 1002 ;

SELECT * FROM salaries;
SELECT * FROM salaryBudgets;

/* --------------- DELETE MULTIPLE RECORDS --------------- */
DELETE FROM salaries;

