package Prezentare;
import BusinessLogic.*;
import javax.swing.*;
import javax.swing.tree.DefaultMutableTreeNode;
import DataModel.*;
import java.util.*;

public class Controller {
    private MainFrame view;
    private TaskManagement manager;
    public Controller(MainFrame view, TaskManagement manager){
        this.view = view;
        this.manager = manager;

        initController();
    }
    private void initController() {
        //butonaele din east list
        view.getHomeBtn().addActionListener(e -> view.switchPanel("home"));
        view.getEmpBtn().addActionListener(e -> view.switchPanel("view/add/remove_employees"));
        view.getTaskBtn().addActionListener(e -> view.switchPanel("view/add/remove_tasks"));
        view.getAssignBtn().addActionListener(e -> view.switchPanel("assign"));
        view.getUtilityBtn().addActionListener(e -> view.switchPanel("utility"));
        //instantiere paneluri+logica utility
        EmployeePanel empPanel = view.getEmpPanel();
        TaskPanel taskPanel = view.getTaskPanel();
        AssignPanel assignPanel = view.getAssignPanel();
        UtilityPanel utility=view.getUtilityPanel();
        Utility utilityLogic=new  Utility();

        //utility-> transformarea outputului functiilor in rapoarte te tip JTextArea
        utility.getBtnOver40().addActionListener(e -> {

            List<Employee> results = utilityLogic.filterEmployees(manager);
            JTextArea textArea = utility.getTextArea();
            textArea.setText("*** ANGAJATI PUTERNIC DEZVOLTATI-- PESTE 40 DE ORE DE MUNCA ***\n\n");

            if (results.isEmpty()) {
                textArea.append("Nu exista angajati cu peste 40 de ore\n");
            } else {
                int i=0;
                for (Employee emp : results) {
                    i++;
                    int duration = manager.calculateEmployeeWorkDuration(emp.getIdEmployee());
                    textArea.append(i+". " +emp.getName() + " - " + duration + " ore\n");
                }
            }
        });

        utility.getBtnStatusReport().addActionListener(e -> {
            HashMap<String, HashMap<String, Integer>> report = utilityLogic.computeTasks(manager);
            JTextArea textArea = utility.getTextArea();

            textArea.setText("*** CINE-SI FACE TREABA SI CINE NU ***\n\n");

            if (report.isEmpty()) {
                textArea.append("Nu exista date in sistem.\n");
            } else {
                for (java.util.Map.Entry<String, java.util.HashMap<String, Integer>> entry : report.entrySet()) {
                    String empName = entry.getKey();
                    int completed = entry.getValue().get("Completed");
                    int uncompleted = entry.getValue().get("Uncompleted");

                    textArea.append(String.format("Angajat: %s | Completed: %d | Uncompleted: %d\n",
                            empName, completed, uncompleted));
                }
            }
        });
        //salvarea datelor inainte de a inchide aplicatia
        view.addWindowListener(new java.awt.event.WindowAdapter() {
            public void windowClosing(java.awt.event.WindowEvent e) {
                System.out.println("Aplicatia se inchide. Salvam datele...");

                manager.saveWork();
                System.exit(0);
            }
        });
        //employee panel functionality
        empPanel.getAddBtn().addActionListener(e -> {
            try {
                int id = Integer.parseInt(empPanel.getIdField().getText().trim());
                String name = empPanel.getNameField().getText().trim();

                if (name.isEmpty()) {
                    JOptionPane.showMessageDialog(view, "Numele nu poate fi gol!");
                    return;
                }
                manager.addEmployee(new Employee(id, name));

                //golim label-urile
                empPanel.getIdField().setText("");
                empPanel.getNameField().setText("");
                refreshEmployeeList();
            } catch (NumberFormatException ex) {
                JOptionPane.showMessageDialog(view, "ID-ul trebuie sa fie un numar!");
            }
        });

        empPanel.getDeleteBtn().addActionListener(e -> {
            Employee selected = empPanel.getEmployeeList().getSelectedValue();
            if (selected != null) {
                manager.removeEmployee(selected);
                refreshEmployeeList();
            } else {
                JOptionPane.showMessageDialog(view, "Selectati un *angajat* pentru a-l sterge.");
            }
        });
        //task panel functionality
        taskPanel.getTypeCombo().addActionListener(e -> {
            String selectedType = (String) taskPanel.getTypeCombo().getSelectedItem();
            if ("Complex Task".equals(selectedType)) {
                taskPanel.getStartTimeField().setEnabled(false);
                taskPanel.getEndTimeField().setEnabled(false);
                taskPanel.getStartTimeField().setText("");
                taskPanel.getEndTimeField().setText("");
            } else {
                taskPanel.getStartTimeField().setEnabled(true);
                taskPanel.getEndTimeField().setEnabled(true);
            }
        });
        taskPanel.getCreateBtn().addActionListener(e -> {
            try {
                int id = Integer.parseInt(taskPanel.getIdField().getText().trim());
                String status = (String) taskPanel.getStatusCombo().getSelectedItem();
                String type = (String) taskPanel.getTypeCombo().getSelectedItem();

                if ("Simple Task".equals(type)) {
                    int start = Integer.parseInt(taskPanel.getStartTimeField().getText().trim());
                    int end = Integer.parseInt(taskPanel.getEndTimeField().getText().trim());

                    manager.addTask(new SimpleTask(id, status, start, end));
                } else {
                    manager.addTask(new ComplexTask(id, status));
                }

                // resetting the form after a addition attempt
                taskPanel.getIdField().setText("");
                taskPanel.getStartTimeField().setText("");
                taskPanel.getEndTimeField().setText("");
                taskPanel.getStatusCombo().setSelectedIndex(0);

                refreshTaskLists();

            } catch (NumberFormatException ex) {
                JOptionPane.showMessageDialog(view, "id-ul, startTime si endTime trebuie sa fie numere intregi!");
            }
        });

        taskPanel.getDeleteBtn().addActionListener(e -> {
            DefaultMutableTreeNode selectedNode = (DefaultMutableTreeNode) taskPanel.getTaskTree().getLastSelectedPathComponent();

            if (selectedNode != null && selectedNode.getUserObject() instanceof Task) {
                Task selected = (Task) selectedNode.getUserObject();
                manager.removeTask(selected);
                refreshTaskLists();
            } else {
                JOptionPane.showMessageDialog(view, "Selectati un task din arbore pentru a-l sterge.");
            }
        });
        taskPanel.getLinkBtn().addActionListener(e -> {
            ComplexTask complex = (ComplexTask) taskPanel.getComplexCombo().getSelectedItem();
            Task subtask = (Task) taskPanel.getSubTaskCombo().getSelectedItem(); // Luam orice Task

            if (complex != null && subtask != null) {
                if (complex.getIdTask() == subtask.getIdTask()) {
                    JOptionPane.showMessageDialog(view, "Eroare: Un task nu poate fi subtask-ul lui insusi!");
                    return;
                }

                manager.addTaskToComplex(complex, subtask);
                refreshTaskLists();
                JOptionPane.showMessageDialog(view, "Subtask legat cu succes!");
            } else {
                JOptionPane.showMessageDialog(view, "Asigurati-va ca a-ti facut selectia!");
            }
        });
        //absolut necesare pentru a avea listele afisate la deschiderea panel-urilor respective
        refreshTaskLists();
        refreshEmployeeList();
        refreshTaskLists();
        assignPanel.getEmpCombo().addActionListener(e -> {
            refreshEmployeeTasksList();
        });
        //asignari
        assignPanel.getAssignBtn().addActionListener(e -> {
            Employee emp = (Employee) assignPanel.getEmpCombo().getSelectedItem();
            Task task = (Task) assignPanel.getUnassignedTaskCombo().getSelectedItem();

            if (emp != null && task != null) {
                manager.assignTaskToEmployee(emp.getIdEmployee(), task);
                refreshTaskLists();
            } else {
                JOptionPane.showMessageDialog(view, "Selectati un angajat si un task!");
            }
        });

        // removing un task de la un employee
        assignPanel.getUnassignBtn().addActionListener(e -> {
            Employee emp = (Employee)assignPanel.getEmpCombo().getSelectedItem();
            DefaultMutableTreeNode selectedNode = (DefaultMutableTreeNode) assignPanel.getEmpTaskTree().getLastSelectedPathComponent();

            if (emp != null && selectedNode != null && selectedNode.getUserObject() instanceof Task) {
                Task task = (Task) selectedNode.getUserObject();
                manager.removeTaskFromEmployee(emp.getIdEmployee(), task);
                refreshTaskLists();
            } else {
                JOptionPane.showMessageDialog(view, "Selectati un task din arborele angajatului!");
            }
        });

        assignPanel.getUpdateStatusBtn().addActionListener(e -> {
            DefaultMutableTreeNode selectedNode = (DefaultMutableTreeNode) assignPanel.getEmpTaskTree().getLastSelectedPathComponent();

            if (selectedNode != null && selectedNode.getUserObject() instanceof Task) {
                Task task = (Task) selectedNode.getUserObject();

                if ("Completed".equals(task.getStatusTask())) {
                    task.setStatusTask("Uncompleted");
                } else {
                    task.setStatusTask("Completed");
                }

                refreshEmployeeTasksList();
            } else {
                JOptionPane.showMessageDialog(view, "Selectati un task al angajatului!");
            }
        });
        //incepem pe home
        view.switchPanel("home");
    }

    private void refreshEmployeeList() {
        EmployeePanel empPanel = view.getEmpPanel();
        AssignPanel assignPanel = view.getAssignPanel();
        empPanel.getListModel().clear();
        assignPanel.getEmpCombo().removeAllItems();
        for (Employee emp : manager.getAssignations().keySet()) {
            empPanel.getListModel().addElement(emp);
            assignPanel.getEmpCombo().addItem(emp);
        }
    }

    private void refreshTaskLists() {
        TaskPanel tp = view.getTaskPanel();
        AssignPanel ap = view.getAssignPanel();
        tp.getRootNode().removeAllChildren();
        tp.getComplexCombo().removeAllItems();
        tp.getSubTaskCombo().removeAllItems();
        ap.getUnassignedTaskCombo().removeAllItems();

        for (Task t : manager.getUnassignedTasks()) {
            tp.getRootNode().add(createTreeNode(t));
            ap.getUnassignedTaskCombo().addItem(t);
            tp.getSubTaskCombo().addItem(t);

            if (t instanceof ComplexTask) {
                tp.getComplexCombo().addItem(t);
            }
        }
        tp.getTreeModel().reload();
        expandAllNodes(tp.getTaskTree());
        refreshEmployeeTasksList();
    }

    private void refreshEmployeeTasksList() {
        AssignPanel ap = view.getAssignPanel();
        ap.getEmpRootNode().removeAllChildren();

        Employee selectedEmp = (Employee) ap.getEmpCombo().getSelectedItem();
        if (selectedEmp != null && manager.getAssignations().containsKey(selectedEmp)) {
            for (Task t : manager.getAssignations().get(selectedEmp)) {
                ap.getEmpRootNode().add(createTreeNode(t));
            }
        }
        ap.getEmpTreeModel().reload();
        expandAllNodes(ap.getEmpTaskTree());
    }

    private DefaultMutableTreeNode createTreeNode(Task task) {
        DefaultMutableTreeNode node = new DefaultMutableTreeNode(task);

        if (task instanceof ComplexTask) {
            ComplexTask recursiv = (ComplexTask) task;
            if (recursiv.getTasks() != null) {
                for (Task subtask : recursiv.getTasks()) {
                    node.add(createTreeNode(subtask));
                }
            }
        }
        return node;
    }
    private void expandAllNodes(JTree tree) {
        int row = 0;
        while (row < tree.getRowCount()) {
            tree.expandRow(row);
            row++;
        }
    }
}