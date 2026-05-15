package org.example.bll.validators;

import org.example.dao.BillDAO;
import org.example.model.Bill;
import java.util.List;

/**
 * This class handles the business logic for creating the BILL logs.
 * @Author: George
 * @Since: May 09, 2026
 */

public class BillBLL {
    private BillDAO billDAO;

    public BillBLL() {
        this.billDAO = new BillDAO();
    }

    public List<Bill> findAllBills() {
        return billDAO.findAll();
    }
}