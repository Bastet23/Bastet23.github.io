package Prezentare;

import DataModel.Employee;

import javax.swing.*;
import java.awt.*;

public class MainFrame extends JFrame {

    private JPanel cardPanel;
    private CardLayout cardLayout;

    //butoanele ce schimba panel ul
    private JButton homeBtn;
    private JButton empBtn;
    private JButton taskBtn;
    private JButton assignBtn;
    private JButton utilityBtn;

    //panourile
    private EmployeePanel empPanel;
    private TaskPanel taskPanel;
    private AssignPanel assignPanel;
    private UtilityPanel utilityPanel;

    public MainFrame() {
        this.cardLayout = new CardLayout();
        this.cardPanel = new JPanel(cardLayout);

        //setup
        setTitle("Task_Management_System");
        setSize(960, 540);
        setDefaultCloseOperation(JFrame.DO_NOTHING_ON_CLOSE);
        setLocationRelativeTo(null);

        JPanel sidebar = createSidebar();
        JPanel homePage = createHomePage();
        empPanel= new EmployeePanel();
        taskPanel= new TaskPanel();
        assignPanel= new AssignPanel();
        utilityPanel= new UtilityPanel();

        // asamblarea panourilor
        cardPanel.add(homePage, "home");
        cardPanel.add(empPanel, "view/add/remove_employees");
        cardPanel.add(taskPanel, "view/add/remove_tasks");
        cardPanel.add(assignPanel, "assign");
        cardPanel.add(utilityPanel, "utility");

        //asamblarea main window
        setLayout(new BorderLayout());
        add(sidebar, BorderLayout.EAST);
        add(cardPanel, BorderLayout.CENTER);
    }

    private JPanel createSidebar() {
        JPanel panel = new JPanel();
        panel.setLayout(new GridLayout(10, 1, 5, 5));
        panel.setBackground(Color.orange);

        //instantiarea butoanelor
        homeBtn = new JButton("Home");
        empBtn = new JButton("Gestiune Angajati");
        taskBtn = new JButton("Gestiune Task-uri");
        assignBtn = new JButton("Gestiune asignari");
        utilityBtn = new JButton("Utilitati");

        panel.add(homeBtn);
        panel.add(empBtn);
        panel.add(taskBtn);
        panel.add(assignBtn);
        panel.add(utilityBtn);

        return panel;
    }

    private JPanel createHomePage() {
        JPanel panel = new JPanel(new GridBagLayout());
        JLabel titleLabel = new JLabel("Bine ai venit la Corporație!");
        titleLabel.setFont(new Font("Times New Roman", Font.BOLD, 36));
        panel.add(titleLabel);
        return panel;
    }


    //helpere pentru controller
    public JButton getHomeBtn(){
        return homeBtn;
    }
    public JButton getEmpBtn(){return empBtn;}
    public JButton getTaskBtn(){
        return taskBtn;
    }
    public JButton getAssignBtn(){return assignBtn;}
    public JButton getUtilityBtn(){return utilityBtn;}

    public EmployeePanel getEmpPanel(){
        return empPanel;
    }
    public TaskPanel getTaskPanel(){return taskPanel;}
    public AssignPanel getAssignPanel(){return assignPanel;}
    public UtilityPanel getUtilityPanel(){return utilityPanel;}

    // meotda de switch a panourilor
    public void switchPanel(String panelName){
        cardLayout.show(cardPanel, panelName);
    }


}