package Prezentare;

import DataModel.Employee;
import DataModel.Task;

import javax.swing.*;
import javax.swing.tree.*;
import java.awt.*;

public class AssignPanel extends JPanel {

    // selectare angajat si task din unassigned
    private JComboBox<Employee> empCombo = new JComboBox<>();
    private JComboBox<Task> unassignedTaskCombo = new JComboBox<>();
    private JButton assignBtn = new JButton("Asigneaza Task");

    // afisare taskuri anagajat
    private DefaultMutableTreeNode empRootNode = new DefaultMutableTreeNode("Task-urile Angajatului");
    private DefaultTreeModel empTreeModel = new DefaultTreeModel(empRootNode);
    private JTree empTaskTree = new JTree(empTreeModel);

    // modificare status si dezasignare
    private JButton updateStatusBtn = new JButton("Schimba Status");
    private JButton unassignBtn = new JButton("Scoate Task (Unassign)");

    public AssignPanel() {
        setLayout(new BorderLayout(10, 10));
        setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

        // 1. selectare si asignare
        JPanel topPanel = new JPanel(new GridLayout(2, 1, 5, 5));
        topPanel.setBorder(BorderFactory.createTitledBorder("Asignare Task Nou"));

        JPanel selectEmpPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
        selectEmpPanel.add(new JLabel("1. Selecteaza Angajat: "));
        selectEmpPanel.add(empCombo);
        topPanel.add(selectEmpPanel);

        JPanel assignActionPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
        assignActionPanel.add(new JLabel("2. Alege Task Liber: "));
        assignActionPanel.add(unassignedTaskCombo);
        assignActionPanel.add(assignBtn);
        topPanel.add(assignActionPanel);

        // lista taskuri
        JPanel centerPanel = new JPanel(new BorderLayout());
        centerPanel.setBorder(BorderFactory.createTitledBorder("Structura Task-urilor Angajatului"));
        empTaskTree.getSelectionModel().setSelectionMode(TreeSelectionModel.SINGLE_TREE_SELECTION);
        centerPanel.add(new JScrollPane(empTaskTree), BorderLayout.CENTER);

        //modificare stergeri
        JPanel bottomPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
        bottomPanel.setBorder(BorderFactory.createTitledBorder("Actiuni pe Task-ul Selectat din Lista"));


        bottomPanel.add(updateStatusBtn);
        bottomPanel.add(Box.createHorizontalStrut(30));
        unassignBtn.setForeground(Color.RED);
        bottomPanel.add(unassignBtn);

        add(topPanel, BorderLayout.NORTH);
        add(centerPanel, BorderLayout.CENTER);
        add(bottomPanel, BorderLayout.SOUTH);
    }

    public JComboBox<Employee> getEmpCombo() { return empCombo;}
    public JComboBox<Task> getUnassignedTaskCombo() { return unassignedTaskCombo;}
    public JButton getAssignBtn() { return assignBtn;}

    public JTree getEmpTaskTree() { return empTaskTree;}
    public DefaultMutableTreeNode getEmpRootNode() { return empRootNode;}
    public DefaultTreeModel getEmpTreeModel() { return empTreeModel;}

    public JButton getUpdateStatusBtn() { return updateStatusBtn;}
    public JButton getUnassignBtn() { return unassignBtn;}
}