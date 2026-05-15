package org.example.presentation;

import org.example.bll.validators.BillBLL;
import org.example.model.Bill;
import javax.swing.JTable;
import java.util.List;

public class BillController {

    public BillController(BillView view, BillBLL bll) {

        List<Bill> bills = bll.findAllBills();
        JTable table = TableFactory.createTable(bills);
        view.setTable(table);
    }
}