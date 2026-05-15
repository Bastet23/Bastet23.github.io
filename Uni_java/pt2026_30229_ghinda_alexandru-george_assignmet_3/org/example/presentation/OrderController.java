package org.example.presentation;

import org.example.bll.validators.ClientBLL;
import org.example.bll.validators.OrderBLL;
import org.example.bll.validators.ProductBLL;
import org.example.model.Client;
import org.example.model.Order;
import org.example.model.Product;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.List;

public class OrderController {

    private OrderView view;
    private OrderBLL orderBLL;
    private ClientBLL clientBLL;
    private ProductBLL productBLL;
    private int currentOrderId = -1;

    public OrderController(OrderView view) {
        this.view = view;
        this.orderBLL = new OrderBLL();
        this.clientBLL = new ClientBLL();
        this.productBLL = new ProductBLL();

        this.view.addStartOrderListener(new StartOrderListener());
        this.view.addAddProductListener(new AddProductListener());
        this.view.addFinishOrderListener(new FinishOrderListener());

        loadDropdownData();
    }

    private void loadDropdownData() {
        view.getClientComboBox().removeAllItems();
        view.getProductComboBox().removeAllItems();

        // stream pentru clienti
        clientBLL.findAllClients().stream()
                .map(c -> new ComboItem(c.getId(), "ID: "+ c.getId()+ " " + c.getName()+ " (" + c.getAddress() + ")"))
                .forEach(item -> view.getClientComboBox().addItem(item));

        // stream pentru produse
        productBLL.findAllProducts().stream()
                .map(p -> new ComboItem(p.getId(), "ID: "+ p.getId()+ " "+ p.getName() + " - $" + p.getPrice() + " (Stock: " + p.getStock() + ")"))
                .forEach(item -> view.getProductComboBox().addItem(item));
    }

    class StartOrderListener implements ActionListener {
        @Override
        public void actionPerformed(ActionEvent e) {
            try {
                ComboItem selectedClient = (ComboItem) view.getClientComboBox().getSelectedItem();
                if (selectedClient == null) return;

                Order newOrder = orderBLL.createEmptyOrder(selectedClient.getId());
                currentOrderId = newOrder.getId();

                view.setOrderIdInput(String.valueOf(currentOrderId));
                view.setCurrentOrderText("Active Order ID: " + currentOrderId, true);

                // Toggle Buttons
                view.enableProductSection(true);
                view.enableFinishButton(true);
                view.enableStartButton(false);

                view.clearReceipt();
                view.appendToReceipt("--- NEW ORDER STARTED ----");
                view.appendToReceipt("Client: " + selectedClient.getLabel());
                view.appendToReceipt("-----------------------------------------");
            } catch (Exception ex) { view.showError(ex.getMessage()); }
        }
    }

    class AddProductListener implements ActionListener {
        @Override
        public void actionPerformed(ActionEvent e) {
            try {
                if (currentOrderId == -1) return;
                ComboItem selectedProduct = (ComboItem) view.getProductComboBox().getSelectedItem();
                if (selectedProduct == null) return;

                int quantity = Integer.parseInt(view.getQuantityInput());
                orderBLL.addProductToOrder(currentOrderId, selectedProduct.getId(), quantity);

                view.appendToReceipt("> Added " + quantity + "x " + selectedProduct.getLabel());
                view.setQuantityInput("");
                loadDropdownData();
            } catch (Exception ex) { view.showError(ex.getMessage()); }
        }
    }


    class FinishOrderListener implements ActionListener {
        @Override
        public void actionPerformed(ActionEvent e) {
            currentOrderId = -1;
            view.setOrderIdInput("");
            view.setCurrentOrderText("Current Order ID: [None]", false);

            view.enableProductSection(false);
            view.enableFinishButton(false);
            view.enableStartButton(true);

            view.appendToReceipt("-----------------------------------------");
            view.appendToReceipt("--- ORDER FINISHED SUCCESSFULLY ---");
        }
    }

    static class ComboItem {
        private int id;
        private String label;
        public ComboItem(int id, String label) { this.id = id; this.label = label; }
        public int getId() { return id; }
        public String getLabel() { return label; }
        @Override
        public String toString() { return label; }
    }
}