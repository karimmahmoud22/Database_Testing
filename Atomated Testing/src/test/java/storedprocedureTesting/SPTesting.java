package storedprocedureTesting;

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

public class SPTesting {

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
	void test_storedProcedureExists() throws SQLException {
		stmt = conn.createStatement();
		rs = stmt.executeQuery("SHOW PROCEDURE STATUS WHERE Name= 'SelectAllCustomers';");
		rs.next();

		Assert.assertEquals(rs.getString("Name"), "SelectAllCustomers");
	}

	@Test(priority = 2)
	void test_SelectAllCustomers() throws SQLException {
		cStmt = conn.prepareCall("{CALL SelectAllCustomers()}");
		rs1 = cStmt.executeQuery(); // result set 1

		Statement stmt = conn.createStatement();
		rs2 = stmt.executeQuery("SELECT * FROM customers");

		Assert.assertEquals(compareResultSets(rs1, rs2), true);

	}

	@Test(priority = 3)
	void test_SelectAllCustomersByCity() throws SQLException {
		cStmt = conn.prepareCall("{CALL SelectAllCustomersByCity(?)}");
		// input parameter
		cStmt.setString(1, "Singapore");

		rs1 = cStmt.executeQuery(); // result set 1

		Statement stmt = conn.createStatement();
		rs2 = stmt.executeQuery("SELECT * FROM customers WHERE city = 'Singapore'");

		Assert.assertEquals(compareResultSets(rs1, rs2), true);
	}

	@Test(priority = 4)
	void test_SelectAllCustomersByCityAndpCode() throws SQLException {
		cStmt = conn.prepareCall("{CALL SelectAllCustomersByCityAndPCode(?,?)}");
		// input parameter
		cStmt.setString(1, "Singapore");
		cStmt.setString(2, "079903");
		rs1 = cStmt.executeQuery(); // result set 1

		Statement stmt = conn.createStatement();
		rs2 = stmt.executeQuery("SELECT * FROM customers WHERE city = 'Singapore'");

		Assert.assertEquals(compareResultSets(rs1, rs2), true);
	}

	@Test(priority = 5)
	void test_get_order_by_customer() throws SQLException {
		cStmt = conn.prepareCall("{CALL get_order_by_customer(?,?,?,?,?)}");
		// input parameter
		cStmt.setInt(1, 141);

		// output parameters
		cStmt.registerOutParameter(2, Types.INTEGER);
		cStmt.registerOutParameter(3, Types.INTEGER);
		cStmt.registerOutParameter(4, Types.INTEGER);
		cStmt.registerOutParameter(5, Types.INTEGER);

		cStmt.executeQuery();

		int shipped = cStmt.getInt(2);
		int canceled = cStmt.getInt(3);
		int resolved = cStmt.getInt(4);
		int disputed = cStmt.getInt(5);

		// System.out.println(shipped + ' ' + canceled + ' ' + resolved + ' ' +
		// disputed);

		Statement stmt = conn.createStatement();
		rs = stmt.executeQuery(
				"SELECT (SELECT count(*) AS 'shipped' FROM orders WHERE customerNumber=141 AND status='Shipped') as Shipped, ( SELECT count(*) AS 'canceled' FROM orders WHERE customerNumber=141 AND status='Canceled') as Canceled, ( SELECT count(*) AS 'resolved' FROM orders WHERE customerNumber=141 AND status='Resolved') as Resolved, (SELECT count(*) AS 'disputed' FROM orders WHERE customerNumber=141 AND status='Disputed') as Disputed");
		rs.next();

		int exp_shipped = rs.getInt("shipped");
		int exp_canceled = rs.getInt("canceled");
		int exp_resolved = rs.getInt("resolved");
		int exp_disputed = rs.getInt("disputed");

		if (shipped == exp_shipped && canceled == exp_canceled && resolved == exp_resolved && disputed == exp_disputed)
			Assert.assertTrue(true);
		else
			Assert.assertTrue(false);
	}

	@Test(priority = 6)
	void test_GetCustomerShipping() throws SQLException {
		cStmt = conn.prepareCall("{CALL GetCustomerShipping(?,?)}");

		// input parameter
		cStmt.setInt(1, 112);
		// output parameters
		cStmt.registerOutParameter(2, Types.VARCHAR);

		cStmt.executeQuery(); // result set 1

		String shippingTime = cStmt.getString(2);

		Statement stmt = conn.createStatement();
		rs = stmt.executeQuery(
				"SELECT country,  CASE  WHEN country='USA' THEN '2-day Shipping' WHEN country='Canada' THEN '3-day Shipping' ELSE '5-day Shipping' END AS ShippingTime FROM customers WHERE customerNumber=112");
		rs.next();

		String exp_shippingTime = rs.getString("ShippingTime");

		Assert.assertEquals(shippingTime, exp_shippingTime);
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
