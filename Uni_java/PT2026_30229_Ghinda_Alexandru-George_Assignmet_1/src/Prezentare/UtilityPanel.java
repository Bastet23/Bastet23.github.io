package Prezentare;

import javax.swing.*;
import java.awt.*;

public class UtilityPanel extends JPanel {

    private JButton btnOver40 = new JButton("Raport Angajati > 40 Ore");
    private JButton btnStatusReport = new JButton("Raport Status Task-uri");
    private JTextArea textArea = new JTextArea();

    public UtilityPanel() {
        setLayout(new BorderLayout(10, 10));
        setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

        JPanel topPanel = new JPanel(new FlowLayout(FlowLayout.CENTER, 20, 10));
        topPanel.add(btnOver40);
        topPanel.add(btnStatusReport);

        textArea.setEditable(false);
        textArea.setFont(new Font("Monospaced", Font.PLAIN, 14));
        JScrollPane scrollPane = new JScrollPane(textArea);
        scrollPane.setBorder(BorderFactory.createTitledBorder("Rezultate Raport"));

        add(topPanel, BorderLayout.NORTH);
        add(scrollPane, BorderLayout.CENTER);
    }

    public JButton getBtnOver40() { return btnOver40; }
    public JButton getBtnStatusReport() { return btnStatusReport; }
    public JTextArea getTextArea() { return textArea; }
}