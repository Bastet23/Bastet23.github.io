package org.example.bll.validators.val;

import java.util.function.Function;
/**
 * This class handles the generic validation of numbers being positive.
  * @Author: George
  * @Since: May 09, 2026
 *  */
public class PositiveNumberValidator<T> implements Validator<T> {

    // lambda function
    private Function<T, Double> valueExtractor;
    private String fieldName;

    public PositiveNumberValidator(Function<T, Double> valueExtractor, String fieldName) {
        this.valueExtractor= valueExtractor;
        this.fieldName= fieldName;
    }

    @Override
    public void validate(T t) {
        Double value= valueExtractor.apply(t);
        if(value==null || value<0) {
            throw new IllegalArgumentException("The " + fieldName+ " cannot be negative!");
        }
    }
}