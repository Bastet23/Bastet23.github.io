package org.example.presentation;

import javax.swing.*;
import java.awt.*;

public class BillView extends JFrame {
    private JScrollPane tableScrollPane;

    public BillView() {
        this.setTitle("Audit Log -View all Bills");
        this.setSize(700, 400);
        this.setLocationRelativeTo(null);
        this.setLayout(new BorderLayout());

        tableScrollPane= new JScrollPane();
        this.add(tableScrollPane, BorderLayout.CENTER);
    }

    public void setTable(JTable table) {
        tableScrollPane.setViewportView(table);
    }
}