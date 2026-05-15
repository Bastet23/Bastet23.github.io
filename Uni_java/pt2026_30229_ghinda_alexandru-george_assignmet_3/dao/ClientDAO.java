package org.example.dao;

import org.example.model.Client;
/**
 * This class handles the CRUD operations for clients.
 * @Author: George
 * @Since: May 09, 2026
 */
public class ClientDAO extends AbstractDAO<Client>{

    public ClientDAO() {
        super(Client.class);
    };

}
