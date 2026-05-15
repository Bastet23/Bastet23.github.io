package org.example.model;
/**
 * This models the Bill record.
 * @Author: George
 * @Since: May 09, 2026
 */
public record Bill(int orderId, String clientName, String productName, int quantity, double totalAmount) {
}