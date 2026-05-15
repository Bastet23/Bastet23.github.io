package org.example.presentation;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionListener;

public class MainMenu extends JFrame {

    private JButton clientButton;
    private JButton productButton;
    private JButton orderButton;
    private JButton logButton;

    public MainMenu() {

        this.setTitle("Order Management System");
        this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        this.setSize(400, 350);
        this.setLocationRelativeTo(null);


        this.setLayout(new GridLayout(5, 1, 10, 10));


        JLabel titleLabel = new JLabel("Main Menu", SwingConstants.CENTER);
        titleLabel.setFont(new Font("Arial", Font.BOLD, 24));
        this.add(titleLabel);

        clientButton = new JButton("Manage Clients");
        productButton = new JButton("Manage Products");
        orderButton = new JButton("Place Orders");
        logButton = new JButton("View Audit Log");


        this.add(clientButton);
        this.add(productButton);
        this.add(orderButton);
        this.add(logButton);
    }


    public void addClientButtonListener(ActionListener listener) {
        clientButton.addActionListener(listener);
    }

    public void addProductButtonListener(ActionListener listener) {
        productButton.addActionListener(listener);
    }

    public void addOrderButtonListener(ActionListener listener) {
        orderButton.addActionListener(listener);
    }

    // THE MISSING METHOD!
    public void addLogButtonListener(ActionListener listener) {
        logButton.addActionListener(listener);
    }
}