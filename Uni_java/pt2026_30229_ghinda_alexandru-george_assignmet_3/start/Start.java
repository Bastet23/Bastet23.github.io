package org.example.start;

import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.example.bll.validators.BillBLL;
import org.example.bll.validators.ProductBLL;
import org.example.bll.validators.ClientBLL;
import org.example.model.Client;

import org.example.presentation.*;

/**
 * @Author: Technical University of Cluj-Napoca, Romania Distributed Systems
 *          Research Laboratory, http://dsrl.coned.utcluj.ro/
 * @Since: Apr 03, 2017
 */
public class Start {
	protected static final Logger LOGGER = Logger.getLogger(Start.class.getName());

    public static void main(String[] args) {
        javax.swing.SwingUtilities.invokeLater(() -> {


            MainMenu mainMenu = new MainMenu();


            mainMenu.addClientButtonListener(e -> {
                ClientView clientView = new ClientView();
                ClientBLL clientBLL = new ClientBLL();

                new ClientController(clientView, clientBLL);


                clientView.setVisible(true);
            });

            mainMenu.addProductButtonListener(e -> {
                ProductView pView = new ProductView();
                ProductBLL pBll = new ProductBLL();
                new ProductController(pView, pBll);
                pView.setVisible(true);
            });

            mainMenu.addOrderButtonListener(e -> {
                OrderView orderView = new OrderView();

                new OrderController(orderView);
                orderView.setVisible(true);
            });

            mainMenu.addLogButtonListener(e -> {
                BillView billView = new BillView();
                BillBLL billBLL = new BillBLL();
                new BillController(billView, billBLL);
                billView.setVisible(true);
            });

            mainMenu.setVisible(true);
        });
    }
	
	

}
