package org.example.presentation;

import javax.swing.JTable;
import javax.swing.table.DefaultTableModel;
import java.lang.reflect.Field;
import java.util.List;

public class TableFactory {

    public static <T> JTable createTable(List<T> objects) {

        if (objects == null || objects.isEmpty()) {
            return new JTable();
        }

        Class<?> type = objects.get(0).getClass();
        Field[] fields = type.getDeclaredFields();


        String[] columnNames = new String[fields.length];
        for (int i = 0; i < fields.length; i++) {
            fields[i].setAccessible(true);
            columnNames[i] = fields[i].getName();
        }


        // extragerea datelor
        Object[][] rowData = new Object[objects.size()][fields.length];
        for (int i = 0; i < objects.size(); i++) {
            T object = objects.get(i);
            for (int j = 0; j < fields.length; j++) {
                try {
                    fields[j].setAccessible(true);

                    rowData[i][j] = fields[j].get(object);
                } catch (IllegalAccessException e) {
                    e.printStackTrace();
                }
            }
        }

        DefaultTableModel tableModel = new DefaultTableModel(rowData, columnNames);
        return new JTable(tableModel);
    }
}