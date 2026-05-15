package org.example.bll.validators;

import org.example.bll.validators.val.PositiveNumberValidator;
import org.example.bll.validators.val.Validator;
import org.example.dao.*;
import org.example.model.*;

import java.util.NoSuchElementException;
/**
 * This class handles the business logic and validation for order operations.
 * @Author: George
 * @Since: May 09, 2026
 */
public class OrderBLL {

    private OrderDAO orderDAO;
    private OrderItemDAO orderItemDAO;
    private ProductDAO productDAO;
    private ClientDAO clientDAO;
    private BillDAO billDAO;

    public OrderBLL() {
        this.orderDAO = new OrderDAO();
        this.orderItemDAO = new OrderItemDAO();
        this.productDAO = new ProductDAO();
        this.clientDAO = new ClientDAO();
        this.billDAO = new BillDAO();
    }


    //order nou pentur un client specific, verific ca clientul sa existe
    public Order createEmptyOrder(int clientId) {
        Client client = clientDAO.findById(clientId);
        if(client== null) {
            throw new NoSuchElementException("Client not found!");
        }

        Order newOrder = new Order();
        newOrder.setClient_id(clientId);
        newOrder.setPrice(0.0);

        return orderDAO.insert(newOrder);
    }

    //creez un order item pentru clientul selectat
    public OrderItem addProductToOrder(int orderId, int productId, int requestedQuantity) {
        if(requestedQuantity<= 0) {
            throw new IllegalArgumentException("Quantity must be greater than zero!");
        }

        Order order = orderDAO.findById(orderId);
        Product product = productDAO.findById(productId);
        Client client = clientDAO.findById(order.getClient_id());

        if(order== null || product== null) {
            throw new NoSuchElementException("Invalid Order or Product ID!");
        }

        if(product.getStock() < requestedQuantity) {
            throw new IllegalArgumentException("Under-stock! Only " + product.getStock() + " left.");
        }

        product.setStock(product.getStock() - requestedQuantity);
        productDAO.update(product);

        // creem orderItem pentru produs dupa ce am verificat validarile
        double itemTotalCost = product.getPrice() * requestedQuantity;
        OrderItem item = new OrderItem();
        item.setOrder_id(orderId);
        item.setProduct_id(productId);
        item.setQuantity(requestedQuantity);
        item.setPrice(itemTotalCost);

        OrderItem insertedItem = orderItemDAO.insert(item);

        // dam update la totatlul comenzii
        order.setPrice(order.getPrice() + itemTotalCost);
        orderDAO.update(order);

        // generam billul pentru log
        Bill bill = new Bill(
                orderId,
                client.getName(),
                product.getName(),
                requestedQuantity,
                itemTotalCost
        );
        billDAO.insert(bill);

        return insertedItem;
    }
}