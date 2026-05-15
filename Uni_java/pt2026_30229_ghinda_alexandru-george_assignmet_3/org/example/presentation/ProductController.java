package org.example.presentation;

import org.example.bll.validators.ProductBLL;
import org.example.model.Product;

import javax.swing.*;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.util.List;

public class ProductController {
    private ProductView view;
    private ProductBLL bll;

    public ProductController(ProductView view, ProductBLL bll) {
        this.view = view;
        this.bll = bll;

        this.view.addAddListener(e -> addProduct());
        this.view.addEditListener(e -> editProduct());
        this.view.addDeleteListener(e -> deleteProduct());

        refreshTable();
    }

    private void refreshTable() {
        List<Product> products = bll.findAllProducts();
        JTable table = TableFactory.createTable(products);
        view.setTable(table);

        view.getTable().addMouseListener(new MouseAdapter() {
            @Override
            public void mouseClicked(MouseEvent e) {
                int row = view.getTable().getSelectedRow();
                if (row != -1) {

                    for (int i = 0; i < view.getTable().getColumnCount(); i++) {
                        String col = view.getTable().getColumnName(i).toLowerCase();
                        String val = view.getTable().getValueAt(row, i).toString();
                        if (col.equals("name")) view.setNameInput(val);
                        else if (col.equals("price")) view.setPriceInput(val);
                        else if (col.equals("stock")) view.setStockInput(val);
                    }
                }
            }
        });
    }

    private void addProduct() {
        try {
            Product p = new Product();
            p.setName(view.getNameInput());
            p.setPrice(Double.parseDouble(view.getPriceInput()));
            p.setStock(Integer.parseInt(view.getStockInput()));
            bll.insertProduct(p);
            refreshTable();
        } catch (Exception ex) { view.showError(ex.getMessage()); }
    }

    private void editProduct() {
        try {
            int id = view.getSelectedProductId();
            if (id == -1) throw new Exception("Select a product!");
            Product p = new Product();
            p.setId(id);
            p.setName(view.getNameInput());
            p.setPrice(Double.parseDouble(view.getPriceInput()));
            p.setStock(Integer.parseInt(view.getStockInput()));
            bll.updateProduct(p);
            refreshTable();
        } catch (Exception ex) { view.showError(ex.getMessage()); }
    }

    private void deleteProduct() {
        try {
            int id = view.getSelectedProductId();
            if (id == -1) throw new Exception("Select a product!");
            bll.deleteProduct(id);
            refreshTable();
        } catch (Exception ex) { view.showError(ex.getMessage()); }
    }
}