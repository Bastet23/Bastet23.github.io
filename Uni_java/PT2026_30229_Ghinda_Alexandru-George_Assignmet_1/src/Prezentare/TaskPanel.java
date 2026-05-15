package Prezentare;

import DataModel.Task;
import javax.swing.*;
import javax.swing.tree.*;
import java.awt.*;

public class TaskPanel extends JPanel {

    // input form
    private JTextField idField = new JTextField(15);
    private JComboBox<String> statusCombo = new JComboBox<>(new String[]{"Uncompleted", "Completed"});
    private JComboBox<String> typeCombo = new JComboBox<>(new String[]{"Simple Task", "Complex Task"});
    private JTextField startTimeField = new JTextField(10);
    private JTextField endTimeField = new JTextField(10);
    private JButton createBtn = new JButton("Creaza Task");

    // unassigned tasks
    private DefaultMutableTreeNode rootNode = new DefaultMutableTreeNode("Task-uri Libere");
    private DefaultTreeModel treeModel = new DefaultTreeModel(rootNode);
    private JTree taskTree = new JTree(treeModel);

    //linking the tasks
    private JComboBox<Task> complexCombo = new JComboBox<>();
    private JComboBox<Task> subTaskCombo = new JComboBox<>();
    private JButton linkBtn = new JButton("Leaga Subtask");
    private JButton deleteBtn = new JButton("Sterge Task Selectat");

    public TaskPanel() {
        setLayout(new BorderLayout(10, 10));
        setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

        //form panel creation
        JPanel inputPanel = new JPanel(new GridBagLayout());
        inputPanel.setBorder(BorderFactory.createTitledBorder("Creare Task Nou"));
        GridBagConstraints gbc = new GridBagConstraints();
        gbc.insets = new Insets(5, 5, 5, 5);
        gbc.fill = GridBagConstraints.HORIZONTAL;

        addGridComponent(inputPanel, new JLabel("ID Task:"), gbc, 0, 0, 1);
        addGridComponent(inputPanel, idField, gbc, 1, 0, 1);
        addGridComponent(inputPanel, new JLabel("Status Task:"), gbc, 0, 1, 1);
        addGridComponent(inputPanel, statusCombo, gbc, 1, 1, 1);

        addGridComponent(inputPanel, new JLabel("Tip Task:"), gbc, 0, 2, 1);
        addGridComponent(inputPanel, typeCombo, gbc, 1, 2, 1);

        addGridComponent(inputPanel, new JLabel("Start Time:"), gbc, 0, 3, 1);
        addGridComponent(inputPanel, startTimeField, gbc, 1, 3, 1);

        addGridComponent(inputPanel, new JLabel("End Time:"), gbc, 0, 4, 1);
        addGridComponent(inputPanel, endTimeField, gbc, 1, 4, 1);

        addGridComponent(inputPanel, createBtn, gbc, 0, 5, 2);

        // zona de afisare a sturcturilor de tree
        JPanel listPanel = new JPanel(new BorderLayout());
        listPanel.setBorder(BorderFactory.createTitledBorder("Task-uri Neasignate (Structura Arborescenta)"));
        taskTree.getSelectionModel().setSelectionMode(TreeSelectionModel.SINGLE_TREE_SELECTION);
        taskTree.setShowsRootHandles(true);
        listPanel.add(new JScrollPane(taskTree), BorderLayout.CENTER);

        // 3. linking si stergere
        JPanel actionPanel = new JPanel(new GridBagLayout());
        actionPanel.setBorder(BorderFactory.createTitledBorder("Actiuni Task-uri"));

        addGridComponent(actionPanel, new JLabel("Complex:"), gbc, 0, 0, 1);
        addGridComponent(actionPanel, complexCombo, gbc, 1, 0, 1);
        addGridComponent(actionPanel, new JLabel("Subtask (Simple):"), gbc, 2, 0, 1);
        addGridComponent(actionPanel, subTaskCombo, gbc, 3, 0, 1);
        addGridComponent(actionPanel, linkBtn, gbc, 4, 0, 1);

        deleteBtn.setForeground(Color.RED);
        gbc.insets = new Insets(15, 5, 5, 5); // Spatiu mai mare inainte de butonul de stergere
        addGridComponent(actionPanel, deleteBtn, gbc, 0, 1, 5);

        // asamblarea finala
        add(inputPanel, BorderLayout.NORTH);
        add(listPanel, BorderLayout.CENTER);
        add(actionPanel, BorderLayout.SOUTH);
    }

    // helper pentru minimizarea codului
    private void addGridComponent(JPanel panel, Component comp, GridBagConstraints gbc, int x, int y, int width) {
        gbc.gridx = x;
        gbc.gridy = y;
        gbc.gridwidth = width;
        panel.add(comp, gbc);
    }

    // gettere pentur controler
    public JTextField getIdField() { return idField;}
    public JComboBox<String> getStatusCombo() { return statusCombo;}
    public JComboBox<String> getTypeCombo() { return typeCombo;}
    public JTextField getStartTimeField() { return startTimeField;}
    public JTextField getEndTimeField() { return endTimeField;}
    public JButton getCreateBtn() { return createBtn;}

    public JTree getTaskTree() { return taskTree;}
    public DefaultMutableTreeNode getRootNode() { return rootNode;}
    public DefaultTreeModel getTreeModel() { return treeModel;}

    public JComboBox<Task> getComplexCombo() { return complexCombo;}
    public JComboBox<Task> getSubTaskCombo() { return subTaskCombo;}
    public JButton getLinkBtn() { return linkBtn;}
    public JButton getDeleteBtn() { return deleteBtn;}
}