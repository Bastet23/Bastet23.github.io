package org.example.model;

/**
 * This models the OrderItem Class.
 * @Author: George
 * @Since: May 09, 2026
 */

public class OrderItem {
    private int id;
    private int product_id;
    private int order_id;
    private int quantity;
    private double price;

    public OrderItem() {}
    public OrderItem(int id, int product_id, int order_id, int quantity, double price) {
        this.id = id;
        this.product_id = product_id;
        this.order_id = order_id;
        this.quantity = quantity;
        this.price = price;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getProduct_id() {
        return product_id;
    }

    public void setProduct_id(int product_id) {
        this.product_id = product_id;
    }

    public int getOrder_id() {
        return order_id;
    }

    public void setOrder_id(int order_id) {
        this.order_id = order_id;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }
}
