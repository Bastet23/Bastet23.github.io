package org.example.presentation;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionListener;

public class OrderView extends JFrame {

    private JComboBox<Object> clientComboBox;
    private JButton startOrderButton;
    private JButton finishOrderButton;
    private JTextField orderIdField;
    private JLabel currentOrderLabel;

    private JComboBox<Object> productComboBox;
    private JTextField quantityField;
    private JButton addProductButton;
    private JTextArea receiptArea;

    public OrderView() {
        this.setTitle("Place Orders");
        this.setSize(550, 550);
        this.setLocationRelativeTo(null);
        this.setLayout(new BorderLayout(10, 10));


        JPanel topPanel = new JPanel(new GridLayout(4, 2, 5, 5));
        topPanel.setBorder(BorderFactory.createTitledBorder("1. Manage Order Session"));

        clientComboBox = new JComboBox<>();
        orderIdField = new JTextField();
        orderIdField.setEditable(false);

        startOrderButton = new JButton("Start New Order");
        finishOrderButton = new JButton("Finish Order");
        finishOrderButton.setEnabled(false);

        currentOrderLabel = new JLabel("Current Order ID: [None]", SwingConstants.CENTER);
        currentOrderLabel.setForeground(Color.RED);

        topPanel.add(new JLabel("Select Client:"));
        topPanel.add(clientComboBox);
        topPanel.add(new JLabel("Active Order ID:"));
        topPanel.add(orderIdField);
        topPanel.add(startOrderButton);
        topPanel.add(finishOrderButton);
        topPanel.add(currentOrderLabel);
        topPanel.add(new JLabel(""));


        JPanel middlePanel = new JPanel(new GridLayout(3, 2, 5, 5));
        middlePanel.setBorder(BorderFactory.createTitledBorder("2. Add Products to Order"));

        middlePanel.add(new JLabel("Select Product:"));
        productComboBox = new JComboBox<>();
        middlePanel.add(productComboBox);

        middlePanel.add(new JLabel("Quantity:"));
        quantityField = new JTextField();
        middlePanel.add(quantityField);

        addProductButton = new JButton("Add to Order");
        addProductButton.setEnabled(false);
        middlePanel.add(new JLabel(""));
        middlePanel.add(addProductButton);

        JPanel controlPanel = new JPanel(new BorderLayout());
        controlPanel.add(topPanel, BorderLayout.NORTH);
        controlPanel.add(middlePanel, BorderLayout.CENTER);


        receiptArea = new JTextArea();
        receiptArea.setEditable(false);
        receiptArea.setFont(new Font("Monospaced", Font.PLAIN, 12));
        JScrollPane receiptScroll = new JScrollPane(receiptArea);
        receiptScroll.setBorder(BorderFactory.createTitledBorder("Order Receipt"));

        this.add(controlPanel, BorderLayout.NORTH);
        this.add(receiptScroll, BorderLayout.CENTER);
    }

    public JComboBox<Object> getClientComboBox() { return clientComboBox; }
    public JComboBox<Object> getProductComboBox() { return productComboBox; }
    public String getQuantityInput() { return quantityField.getText().trim(); }
    public void setQuantityInput(String text) { quantityField.setText(text); }
    public void setOrderIdInput(String id) { orderIdField.setText(id); }

    public void setCurrentOrderText(String text, boolean isActive) {
        currentOrderLabel.setText(text);
        currentOrderLabel.setForeground(isActive ? Color.GREEN.darker() : Color.RED);
    }

    public void enableProductSection(boolean enable) { addProductButton.setEnabled(enable); }
    public void enableFinishButton(boolean enable) { finishOrderButton.setEnabled(enable); }
    public void enableStartButton(boolean enable) { startOrderButton.setEnabled(enable); }

    public void appendToReceipt(String text) { receiptArea.append(text + "\n"); }
    public void clearReceipt() { receiptArea.setText(""); }
    public void showError(String message) { JOptionPane.showMessageDialog(this, message, "Error", JOptionPane.ERROR_MESSAGE); }

    public void addStartOrderListener(ActionListener listener) { startOrderButton.addActionListener(listener); }
    public void addAddProductListener(ActionListener listener) { addProductButton.addActionListener(listener); }
    public void addFinishOrderListener(ActionListener listener) { finishOrderButton.addActionListener(listener); }
}