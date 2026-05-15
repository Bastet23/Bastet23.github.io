package org.example.presentation;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionListener;

public class ProductView extends JFrame {

    private JTextField nameField;
    private JTextField priceField;
    private JTextField stockField;
    private JButton addButton;
    private JButton editButton;
    private JButton deleteButton;
    private JScrollPane tableScrollPane;
    private JTable productTable;

    public ProductView() {
        this.setTitle("Manage Products");
        this.setSize(600, 400);
        this.setLocationRelativeTo(null);
        this.setLayout(new BorderLayout());

        JPanel inputPanel = new JPanel(new GridLayout(3, 2, 5, 5));
        inputPanel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

        inputPanel.add(new JLabel("Product Name:"));
        nameField = new JTextField();
        inputPanel.add(nameField);

        inputPanel.add(new JLabel("Price:"));
        priceField = new JTextField();
        inputPanel.add(priceField);

        inputPanel.add(new JLabel("Stock:"));
        stockField = new JTextField();
        inputPanel.add(stockField);

        addButton = new JButton("Add Product");
        editButton = new JButton("Edit Product");
        deleteButton = new JButton("Delete Product");

        JPanel buttonPanel = new JPanel();
        buttonPanel.add(addButton);
        buttonPanel.add(editButton);
        buttonPanel.add(deleteButton);

        tableScrollPane = new JScrollPane();

        this.add(inputPanel, BorderLayout.NORTH);
        this.add(tableScrollPane, BorderLayout.CENTER);
        this.add(buttonPanel, BorderLayout.SOUTH);
    }

    public String getNameInput() { return nameField.getText(); }
    public String getPriceInput() { return priceField.getText(); }
    public String getStockInput() { return stockField.getText(); }

    public void setNameInput(String name) { nameField.setText(name); }
    public void setPriceInput(String price) { priceField.setText(price); }
    public void setStockInput(String stock) { stockField.setText(stock); }

    public void setTable(JTable table) {
        this.productTable = table;
        tableScrollPane.setViewportView(table);
    }

    public JTable getTable() { return productTable; }

    public int getSelectedProductId() {
        int selectedRow = productTable.getSelectedRow();
        if (selectedRow == -1) return -1;

        for (int i = 0; i < productTable.getColumnCount(); i++) {
            if (productTable.getColumnName(i).equalsIgnoreCase("id")) {
                return Integer.parseInt(productTable.getValueAt(selectedRow, i).toString());
            }
        }
        return -1;
    }

    public void showError(String message) {
        JOptionPane.showMessageDialog(this, message, "Error", JOptionPane.ERROR_MESSAGE);
    }

    public void addAddListener(ActionListener l) { addButton.addActionListener(l); }
    public void addEditListener(ActionListener l) { editButton.addActionListener(l); }
    public void addDeleteListener(ActionListener l) { deleteButton.addActionListener(l); }
}