package org.example.dao;

import org.example.model.Order;
/**
 * This class handles the CRUD operations for orders.
 * @Author: George
 * @Since: May 09, 2026
 */
public class OrderDAO extends AbstractDAO<Order>{
    public OrderDAO() {
        super(Order.class);
    }
}
