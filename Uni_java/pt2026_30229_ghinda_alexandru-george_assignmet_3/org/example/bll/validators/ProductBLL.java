package org.example.bll.validators;

import org.example.bll.validators.val.Validator;
import org.example.bll.validators.val.GenericNameValidator;
import org.example.bll.validators.val.PositiveNumberValidator;
import org.example.dao.ProductDAO;
import org.example.model.Product;

import java.util.ArrayList;
import java.util.List;
import java.util.NoSuchElementException;
/**
 * This class handles the business logic and validation for products operations.
 * @Author: George
 * @Since: May 09, 2026
 */
public class ProductBLL {

    private List<Validator<Product>> validators;
    private ProductDAO productDAO;

    public ProductBLL() {
        validators = new ArrayList<>();
        validators.add(new PositiveNumberValidator<>(Product::getPrice, "Product Price"));
        validators.add(new PositiveNumberValidator<>(p->(double) p.getStock(), "Product Stock"));
        validators.add(new GenericNameValidator<>(Product::getName, "Product Name"));

        this.productDAO = new ProductDAO();
    }

    public Product insertProduct(Product product) {
        for(Validator<Product> v : validators) {
            v.validate(product);
        }
        return productDAO.insert(product);
    }

    public Product updateProduct(Product product) {
        for(Validator<Product> v : validators) {
            v.validate(product);
        }
        return productDAO.update(product);
    }

    public boolean deleteProduct(int id) {
        findProductById(id);
        return productDAO.delete(id);
    }

    public List<Product> findAllProducts() {
        return productDAO.findAll();
    }

    public Product findProductById(int id) {
        Product product = productDAO.findById(id);
        if(product == null) {
            throw new NoSuchElementException("The product with id = " +id + " was not found!");
        }
        return product;
    }
}