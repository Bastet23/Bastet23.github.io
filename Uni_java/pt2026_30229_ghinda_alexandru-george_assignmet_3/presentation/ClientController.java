package org.example.presentation;

import org.example.bll.validators.ClientBLL;
import org.example.model.Client;

import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.util.List;

public class ClientController {

    private ClientView view;
    private ClientBLL bll;

    public ClientController(ClientView view, ClientBLL bll) {
        this.view = view;
        this.bll = bll;


        this.view.addAddButtonListener(new AddClientListener());
        this.view.addEditButtonListener(new EditClientListener());
        this.view.addDeleteButtonListener(new DeleteClientListener());

        refreshTable();
    }

    private void refreshTable() {
        List<Client> clients = bll.findAllClients();
        JTable newTable = TableFactory.createTable(clients);
        view.setTable(newTable);


        view.getTable().addMouseListener(new MouseAdapter() {
            @Override
            public void mouseClicked(MouseEvent e) {
                int selectedRow= view.getTable().getSelectedRow();
                if (selectedRow != -1) {

                    String name= view.getTable().getValueAt(selectedRow, 1).toString();
                    String address= view.getTable().getValueAt(selectedRow, 2).toString();

                    view.setNameInput(name);
                    view.setAddressInput(address);
                }
            }
        });
    }

    class AddClientListener implements ActionListener {
        @Override
        public void actionPerformed(ActionEvent e) {
            try {
                Client newClient = new Client();
                newClient.setName(view.getNameInput());
                newClient.setAddress(view.getAddressInput());

                bll.insertClient(newClient);
                refreshTable();

                view.setNameInput("");
                view.setAddressInput("");
            } catch (Exception ex) {
                view.showError(ex.getMessage());
            }
        }
    }

    class EditClientListener implements ActionListener {
        @Override
        public void actionPerformed(ActionEvent e) {
            try {
                int selectedId = view.getSelectedClientId();
                if (selectedId == -1) {
                    view.showError("Please select a client from the table to edit!");
                    return;
                }

                Client updatedClient = new Client();
                updatedClient.setId(selectedId);
                updatedClient.setName(view.getNameInput());
                updatedClient.setAddress(view.getAddressInput());

                bll.updateClient(updatedClient);
                refreshTable();
            } catch (Exception ex) {
                view.showError(ex.getMessage());
            }
        }
    }

    class DeleteClientListener implements ActionListener {
        @Override
        public void actionPerformed(ActionEvent e) {
            try {
                int selectedId = view.getSelectedClientId();
                if (selectedId == -1) {
                    view.showError("Please select a client from the table to delete!");
                    return;
                }

                bll.deleteClient(selectedId);
                refreshTable();

                view.setNameInput("");
                view.setAddressInput("");
            } catch (Exception ex) {
                view.showError(ex.getMessage());
            }
        }
    }
}