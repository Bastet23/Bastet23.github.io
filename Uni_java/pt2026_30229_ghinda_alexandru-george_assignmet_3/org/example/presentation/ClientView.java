package org.example.presentation;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionListener;

public class ClientView extends JFrame {

    private JTextField idField;
    private JTextField nameField;
    private JTextField addressField;
    private JButton addButton;
    private JButton editButton;
    private JButton deleteButton;
    private JButton searchButton;
    private JScrollPane tableScrollPane;
    private JTable clientTable;

    public ClientView() {
        this.setTitle("Manage Clients");
        this.setSize(600, 450);
        this.setLocationRelativeTo(null);
        this.setLayout(new BorderLayout());


        JPanel inputPanel = new JPanel(new GridLayout(4, 2, 5, 5));
        inputPanel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

        inputPanel.add(new JLabel("ID (Search Only):"));
        idField = new JTextField();
        inputPanel.add(idField);

        inputPanel.add(new JLabel("Name:"));
        nameField = new JTextField();
        inputPanel.add(nameField);

        inputPanel.add(new JLabel("Address:"));
        addressField = new JTextField();
        inputPanel.add(addressField);


        addButton = new JButton("Add");
        editButton = new JButton("Edit");
        deleteButton = new JButton("Delete");
        searchButton = new JButton("Search");

        JPanel buttonPanel = new JPanel();
        buttonPanel.add(addButton);
        buttonPanel.add(editButton);
        buttonPanel.add(deleteButton);
        buttonPanel.add(searchButton);

        tableScrollPane = new JScrollPane();

        this.add(inputPanel, BorderLayout.NORTH);
        this.add(tableScrollPane, BorderLayout.CENTER);
        this.add(buttonPanel, BorderLayout.SOUTH);
    }


    public String getIdInput() { return idField.getText().trim(); }
    public String getNameInput() { return nameField.getText().trim(); }
    public String getAddressInput() { return addressField.getText().trim(); }

    public void setIdInput(String id) { idField.setText(id); }
    public void setNameInput(String name) { nameField.setText(name); }
    public void setAddressInput(String address) { addressField.setText(address); }

    public void showError(String message) {
        JOptionPane.showMessageDialog(this, message, "Error", JOptionPane.ERROR_MESSAGE);
    }

    public int getSelectedClientId() {
        if (clientTable == null) return -1;
        int selectedRow = clientTable.getSelectedRow();
        if (selectedRow == -1) return -1;

        int idColumnIndex = -1;
        for (int i = 0; i < clientTable.getColumnCount(); i++) {
            if (clientTable.getColumnName(i).equalsIgnoreCase("id")) {
                idColumnIndex = i;
                break;
            }
        }
        if (idColumnIndex != -1) {
            Object idValue = clientTable.getValueAt(selectedRow, idColumnIndex);
            return Integer.parseInt(idValue.toString());
        } else {
            showError("Could not find an 'id' column in the table!");
            return -1;
        }
    }

    public void setTable(JTable table) {
        this.clientTable = table;
        tableScrollPane.setViewportView(table);
    }

    public JTable getTable() { return clientTable; }


    public void addAddButtonListener(ActionListener listener) { addButton.addActionListener(listener); }
    public void addEditButtonListener(ActionListener listener) { editButton.addActionListener(listener); }
    public void addDeleteButtonListener(ActionListener listener) { deleteButton.addActionListener(listener); }
    public void addSearchButtonListener(ActionListener listener) { searchButton.addActionListener(listener); }
}