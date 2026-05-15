package org.example.dao;

import org.example.model.OrderItem;
/**
 * This class handles the CRUD operations for orderItems.
 * @Author: George
 * @Since: May 09, 2026
 */
public class OrderItemDAO extends AbstractDAO<OrderItem>{
    public OrderItemDAO() {
        super(OrderItem.class);
    }
}
