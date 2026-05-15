package org.example.model;

/**
 * This models the Order Class.
 * @Author: George
 * @Since: May 09, 2026
 */

public class Order {
    private int id;
    private int client_id;
    double price;

    public Order() {}
    public Order(double price, int client_id, int id) {
        this.price = price;
        this.client_id = client_id;
        this.id = id;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getClient_id() {
        return client_id;
    }

    public void setClient_id(int client_id) {
        this.client_id = client_id;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }
}
