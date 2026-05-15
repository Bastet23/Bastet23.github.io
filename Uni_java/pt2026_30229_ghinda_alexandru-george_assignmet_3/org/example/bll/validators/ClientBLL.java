package org.example.bll.validators;

import org.example.bll.validators.val.GenericNameValidator;
import org.example.bll.validators.val.Validator;
import org.example.dao.ClientDAO;
import org.example.model.Client;

import java.util.ArrayList;
import java.util.List;
import java.util.NoSuchElementException;

/**
 * This class handles the business logic and validation for client operations.
 * @Author: George
 * @Since: May 09, 2026
 */

public class ClientBLL {

    private List<Validator<Client>> validators;
    private ClientDAO clientDAO;

    public ClientBLL() {
        validators = new ArrayList<>();
        validators.add(new GenericNameValidator<>(Client::getName,"Client Name"));
        validators.add(new GenericNameValidator<>(Client::getAddress, "Client Address"));

        this.clientDAO = new ClientDAO();
    }

    public Client insertClient(Client client) {
        for(Validator<Client> v : validators) {
            v.validate(client);
        }
        return clientDAO.insert(client);
    }

    public Client updateClient(Client client) {
        for(Validator<Client> v : validators) {
            v.validate(client);
        }
        return clientDAO.update(client);
    }

    public boolean deleteClient(int id) {
        //verific sa existe inainte sa sterg
        findClientById(id);
        return clientDAO.delete(id);
    }

    public List<Client> findAllClients() {
        return clientDAO.findAll();
    }

    public Client findClientById(int id) {
        Client client = clientDAO.findById(id);
        if(client == null) {
            throw new NoSuchElementException("The client with id = "+ id+ " was not found!");
        }
        return client;
    }
}