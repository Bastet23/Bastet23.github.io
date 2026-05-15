package org.example.dao;

import org.example.model.Product;
/**
 * This class handles the CRUD operations for products.
 * @Author: George
 * @Since: May 09, 2026
 */
public class ProductDAO extends AbstractDAO<Product>{
    public ProductDAO() {
        super(Product.class);
    }
}
