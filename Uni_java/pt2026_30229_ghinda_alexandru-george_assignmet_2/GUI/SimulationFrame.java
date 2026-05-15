package GUI;

import Business_Logic.SelectionPolicy;
import Business_Logic.SimulationManager;
import Model.*;


import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.List;


public class SimulationFrame extends JFrame {


    private JTextField timeLimitField = new JTextField("30", 4);
    private JTextField minArrivalField = new JTextField("2", 4);
    private JTextField maxArrivalField = new JTextField("20", 4);
    private JTextField minProcTimeField = new JTextField("2", 4);
    private JTextField maxProcTimeField = new JTextField("10", 4);
    private JTextField numServersField = new JTextField("3", 4);
    private JTextField numClientsField = new JTextField("5", 4);
    private JButton startButton = new JButton("Start Simulation");

    private JComboBox<String> strategyBox = new JComboBox<>(new String[]{"Shortest Time", "Shortest Queue"});

    private SimulationPanel simulationPanel;

    public SimulationFrame() {
        setTitle("Queue management Tycoon - Roblox");
        setSize(900, 700);
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setLayout(new BorderLayout());

        //setup la inputs
        JPanel inputPanel = new JPanel(new GridLayout(3, 6, 5, 5));
        inputPanel.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

        inputPanel.add(new JLabel("Time Limit:"));  inputPanel.add(timeLimitField);
        inputPanel.add(new JLabel("Clients:"));     inputPanel.add(numClientsField);
        inputPanel.add(new JLabel("Servers:"));     inputPanel.add(numServersField);

        inputPanel.add(new JLabel("Min Arrival:")); inputPanel.add(minArrivalField);
        inputPanel.add(new JLabel("Max Arrival:")); inputPanel.add(maxArrivalField);
        inputPanel.add(new JLabel("Strategy:"));    inputPanel.add(strategyBox);

        inputPanel.add(new JLabel("Min Svc:"));     inputPanel.add(minProcTimeField);
        inputPanel.add(new JLabel("Max Svc:"));     inputPanel.add(maxProcTimeField);
        inputPanel.add(new JLabel(""));             inputPanel.add(startButton);

        add(inputPanel, BorderLayout.NORTH);

        // set up la panelul cu vizualizarea
        simulationPanel = new SimulationPanel();
        add(simulationPanel, BorderLayout.CENTER);

        // Butonul de start
        startButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                startSimulation();
            }
        });
    }

    public void updateDisplay(List<Server> servers, List<Task> unassignedTasks, int currentTime) {
        simulationPanel.updateData(servers, unassignedTasks, currentTime);
    }


    public void showFinalStats(double avgServiceTime, double avgWaitingTime, int peakHour) {
        String message = String.format(
                "Simulation Finished successfully!\n\n" +
                        "Average Service Time: %.2f seconds\n" +
                        "Average Waiting Time: %.2f seconds\n" +
                        "Peak Hour: Time %d",
                avgServiceTime, avgWaitingTime, peakHour
        );

        JOptionPane.showMessageDialog(this, message, "Simulation Results", JOptionPane.INFORMATION_MESSAGE);

        startButton.setEnabled(true);
    }

    private void startSimulation() {
        try {
            //luam input ul
            int timeLimit = Integer.parseInt(timeLimitField.getText());
            int minArrival = Integer.parseInt(minArrivalField.getText());
            int maxArrival = Integer.parseInt(maxArrivalField.getText());
            int minProc = Integer.parseInt(minProcTimeField.getText());
            int maxProc = Integer.parseInt(maxProcTimeField.getText());
            int numServers = Integer.parseInt(numServersField.getText());
            int numClients = Integer.parseInt(numClientsField.getText());

            //validam nput ul
            if (numServers <= 0 || numClients <= 0 || timeLimit <= 0) {
                JOptionPane.showMessageDialog(this, "Servers, Clients, and Time Limit must be strictly greater than 0.", "Invalid Input", JOptionPane.ERROR_MESSAGE);
                return;}

            if (minArrival < 0 || minProc <= 0) {
                JOptionPane.showMessageDialog(this, "Arrival times cannot be negative, and processing time must be at least 1.", "Invalid Input", JOptionPane.ERROR_MESSAGE);
                return;}

            if (minArrival > maxArrival) {
                JOptionPane.showMessageDialog(this, "Minimum Arrival Time cannot be greater than Maximum Arrival Time.", "Logic Error", JOptionPane.ERROR_MESSAGE);
                return;}

            if (minProc > maxProc) {
                JOptionPane.showMessageDialog(this, "Minimum Processing Time cannot be greater than Maximum Processing Time.", "Logic Error", JOptionPane.ERROR_MESSAGE);
                return;}

            if (maxArrival >= timeLimit) {
                JOptionPane.showMessageDialog(this, "Clients cannot arrive after the Time Limit! Decrease Max Arrival or increase Time Limit.", "Time Error", JOptionPane.ERROR_MESSAGE);
                return;}

            if (maxArrival + maxProc > timeLimit) {
                JOptionPane.showMessageDialog(this, "Time limit should be larger than Max Arrival time+ Max proccessing time in order for the simulation to be vlaid", "Time Error", JOptionPane.ERROR_MESSAGE);
                return;}


            String selectedStrategy = strategyBox.getSelectedItem().toString();
            SelectionPolicy policy;

            if (selectedStrategy.equals("Shortest Time")) {
                policy = SelectionPolicy.SHORTEST_TIME;
            } else {
                policy = SelectionPolicy.SHORTEST_QUEUE;
            }

            //daca totul e valid incepem simularea
            SimulationManager manager = new SimulationManager(
                    timeLimit, minArrival, maxArrival, minProc, maxProc, numServers, numClients,policy, this
            );

            Thread t = new Thread(manager);
            t.start();

            startButton.setEnabled(false);

        } catch (NumberFormatException ex) {
            JOptionPane.showMessageDialog(this, "Please ensure all input fields contain valid whole numbers.", "Format Error", JOptionPane.ERROR_MESSAGE);
        }


    }

    //clasa de desenat simularea
    private class SimulationPanel extends JPanel {
        private List<Server> servers;
        private List<Task> unassignedTasks;
        private int currentTime;

        public void updateData(List<Server> servers, List<Task> unassigned, int currentTime) {
            this.servers = servers;
            this.unassignedTasks = unassigned;
            this.currentTime = currentTime;
            repaint();
        }

        @Override
        protected void paintComponent(Graphics g) {
            super.paintComponent(g);
            if (servers == null) return;

            //timpul global
            g.setFont(new Font("Arial", Font.BOLD, 16));
            g.drawString("Current Time: " + currentTime, 20, 25);

            //lista de asteptare
            g.setFont(new Font("Arial", Font.PLAIN, 14));
            g.drawString("Waiting Clients (ID, Arrival, Service):", 20, 50);


            StringBuilder waitingTxt = new StringBuilder();
            for (Task t : unassignedTasks) {
                waitingTxt.append("(" + t.getId() +", " + t.getArrivalTime()+ ", " + t.getServiceTime()+ "), ");
            }

            g.setColor(Color.DARK_GRAY);
            g.drawString(waitingTxt.toString(), 20, 75);

            //Desenam serverele
            int xOffset = 50;
            int yOffset = 120;

            for (int i = 0; i < servers.size(); i++) {
                Server server = servers.get(i);

                g.setColor(Color.BLACK);
                g.setFont(new Font("Arial", Font.BOLD, 14));
                g.drawString("Queue " + (i + 1), xOffset, yOffset - 10);

                // server outline
                g.drawRect(xOffset, yOffset, 70, 400);

                // 4.taskurile din inauntru
                int taskY = yOffset + 10;
                for (Task task : server.getTasks()) {
                    g.setColor(new Color(173, 216, 230));
                    g.fillRect(xOffset + 5, taskY, 60, 40);

                    g.setColor(Color.BLACK);
                    g.drawRect(xOffset + 5, taskY, 60, 40);

                    // id-ul si timpul ramas inauntru-l blocului
                    g.setFont(new Font("Arial", Font.PLAIN, 12));
                    g.drawString("ID: " + task.getId(), xOffset + 10, taskY + 15);
                    g.drawString("Time: " + task.getServiceTime(), xOffset + 10, taskY + 30);

                    taskY += 45;
                }
                xOffset += 110; //offset pentru urmatorul server
            }
        }
    }
}