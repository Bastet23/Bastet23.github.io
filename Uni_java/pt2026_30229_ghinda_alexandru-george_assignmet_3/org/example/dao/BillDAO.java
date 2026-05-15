package org.example.dao;

import org.example.connection.ConnectionFactory;
import org.example.model.Bill;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
/**
 * This class handles the CRUD operations for the Log table.
 * @Author: George
 * @Since: May 09, 2026
 */
public class BillDAO {

    protected static final Logger LOGGER = Logger.getLogger(BillDAO.class.getName());

    private static final String INSERT_STATEMENT = "insert into Log (orderId, clientName, productName, quantity, totalAmount) values (?, ?, ?, ?, ?)";
    private static final String FIND_ALL_STATEMENT = "select * from Log";

    public Bill insert(Bill bill) {
        Connection dbConnection= ConnectionFactory.getConnection();
        PreparedStatement insertStatement= null;
        try {
            insertStatement= dbConnection.prepareStatement(INSERT_STATEMENT);

            insertStatement.setInt(1, bill.orderId());
            insertStatement.setString(2, bill.clientName());
            insertStatement.setString(3, bill.productName());
            insertStatement.setInt(4, bill.quantity());
            insertStatement.setDouble(5, bill.totalAmount());

            insertStatement.executeUpdate();
            return bill;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "BillDAO:insert " + e.getMessage());
        } finally {
            ConnectionFactory.close(insertStatement);
            ConnectionFactory.close(dbConnection);
        }
        return null;
    }

    public List<Bill> findAll() {
        Connection dbConnection= ConnectionFactory.getConnection();
        PreparedStatement findStatement= null;
        ResultSet resultSet= null;
        List<Bill> bills= new ArrayList<>();

        try {
            findStatement= dbConnection.prepareStatement(FIND_ALL_STATEMENT);
            resultSet= findStatement.executeQuery();

            while (resultSet.next()) {
                Bill bill= new Bill(
                        resultSet.getInt("orderId"),
                        resultSet.getString("clientName"),
                        resultSet.getString("productName"),
                        resultSet.getInt("quantity"),
                        resultSet.getDouble("totalAmount")
                );
                bills.add(bill);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "BillDAO:findAll " + e.getMessage());
        } finally {
            ConnectionFactory.close(resultSet);
            ConnectionFactory.close(findStatement);
            ConnectionFactory.close(dbConnection);
        }
        return bills;
    }
}