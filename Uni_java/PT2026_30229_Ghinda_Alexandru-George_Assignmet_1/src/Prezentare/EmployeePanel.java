package Prezentare;

import DataModel.Employee;
import javax.swing.*;
import java.awt.*;

public class EmployeePanel extends JPanel {

    // componentele ui
    private JTextField idField;
    private JTextField nameField;
    private JButton addBtn;
    private JButton deleteBtn;
    private DefaultListModel<Employee> listModel;
    private JList<Employee> employeeList;

    public EmployeePanel() {
        idField = new JTextField(15);
        nameField = new JTextField(15);
        addBtn = new JButton("Adauga Angajat");
        deleteBtn = new JButton("Sterge Angajatul Selectat");

        listModel = new DefaultListModel<>();
        employeeList = new JList<>(listModel);
        employeeList.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);


        setLayout(new BorderLayout(10, 10));
        setBorder(BorderFactory.createEmptyBorder(10,10,10,10));

        //input form
        JPanel inputPanel = new JPanel(new GridBagLayout());
        inputPanel.setBorder(BorderFactory.createTitledBorder("Inregistrare Angajat Nou"));
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.insets = new Insets(10, 10, 10, 10);
        gbc.fill = GridBagConstraints.HORIZONTAL;


        addGridComponent(inputPanel, new JLabel("ID Angajat:"), gbc, 0, 0, 1);
        addGridComponent(inputPanel, idField, gbc, 1, 0, 1);
        addGridComponent(inputPanel, new JLabel("Nume Complet:"), gbc, 0, 1, 1);
        addGridComponent(inputPanel, nameField, gbc, 1, 1, 1);
        addGridComponent(inputPanel, addBtn, gbc, 0, 2, 2);

        //lista
        JPanel listPanel = new JPanel(new BorderLayout());
        listPanel.setBorder(BorderFactory.createTitledBorder("Lista Angajati Inregistrati"));
        listPanel.add(new JScrollPane(employeeList), BorderLayout.CENTER);

        // delete
        JPanel bottomPanel = new JPanel(new FlowLayout(FlowLayout.RIGHT));
        deleteBtn.setForeground(Color.RED);
        bottomPanel.add(deleteBtn);

        // asamblarea celor 3
        add(inputPanel, BorderLayout.NORTH);
        add(listPanel, BorderLayout.CENTER);
        add(bottomPanel, BorderLayout.SOUTH);
    }

    private void addGridComponent(JPanel panel, Component comp, GridBagConstraints gbc, int x, int y, int width) {
        gbc.gridx = x;
        gbc.gridy = y;
        gbc.gridwidth = width;
        panel.add(comp, gbc);
    }

    //gettere pentru controller
    public JTextField getIdField() { return idField;}
    public JTextField getNameField() { return nameField;}
    public JButton getAddBtn() { return addBtn;}
    public JButton getDeleteBtn() { return deleteBtn;}
    public DefaultListModel<Employee> getListModel() { return listModel;}
    public JList<Employee> getEmployeeList() { return employeeList;}
}