package storedfunctionTesting;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;

import org.apache.commons.lang3.StringUtils;
import org.testng.Assert;
import org.testng.annotations.AfterClass;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

public class SFTesting {
	Connection conn = null;
	Statement stmt = null;
	ResultSet rs;
	CallableStatement cStmt;
	ResultSet rs1;
	ResultSet rs2;

	@BeforeClass
	void setup() throws SQLException {
		conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/classicmodels", "root", "Karim@0107228700");

	}

	@AfterClass
	void tearDown() throws SQLException {
		conn.close();
	}

	@Test(priority = 1)
	void test_storedFunctionExists() throws SQLException {
		stmt = conn.createStatement();
		rs = stmt.executeQuery("SHOW FUNCTION STATUS WHERE Name= 'CustomerLevel'");
		rs.next();

		Assert.assertEquals(rs.getString("Name"), "CustomerLevel");
	}

	@Test(priority = 2)
	void test_CustomerLevel_with_SQLStatement() throws SQLException {
		rs1 = conn.createStatement().executeQuery("SELECT customerName, CustomerLevel( creditLimit) FROM customers");
		rs2 = conn.createStatement().executeQuery(
				"SELECT customerName, CASE WHEN creditLimit > 50000 THEN 'PLATINUM' WHEN  (creditLimit >= 10000 AND creditLimit <= 50000) THEN 'GOLD' WHEN  creditLimit < 10000 THEN 'SILVER' END AS customerLevel FROM customers");

		Assert.assertEquals(compareResultSets(rs1, rs2), true);
	}

	@Test(priority = 3)
	void test_CustomerLevel_with_StoredProcedure() throws SQLException {
		cStmt = conn.prepareCall("{CALL GetCustomerLevel(?,?)}");

		// input parameter
		cStmt.setInt(1, 131);
		// output parameter
		cStmt.registerOutParameter(2, Types.VARCHAR);

		cStmt.executeQuery();

		String customerLevel = cStmt.getString(2);

		rs = conn.createStatement().executeQuery(
				"SELECT customerName, CASE WHEN creditLimit > 50000 THEN 'PLATINUM' WHEN  (creditLimit >= 10000 AND creditLimit <= 50000) THEN 'GOLD' WHEN  creditLimit < 10000 THEN 'SILVER' END AS customerLevel  FROM customers WHERE customerNumber=131");
		rs.next();

		String exp_CustomerLevel = rs.getString("customerLevel");

		Assert.assertEquals(customerLevel, exp_CustomerLevel);

	}

	/* Utilities Functions */
	// compare 2 result sets from MYSQL
	public boolean compareResultSets(ResultSet resultSet1, ResultSet resultSet2) throws SQLException {
		while (resultSet1.next()) {

			resultSet2.next();
			int count = resultSet1.getMetaData().getColumnCount();

			for (int i = 1; i <= count; i++) {
				if (!StringUtils.equals(resultSet1.getString(i), resultSet2.getString(i))) {
					return false;
				}
			}
		}
		return true;
	}
}
