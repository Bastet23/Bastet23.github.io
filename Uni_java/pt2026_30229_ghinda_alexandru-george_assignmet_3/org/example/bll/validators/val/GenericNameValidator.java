package org.example.bll.validators.val;

import java.util.function.Function;

/**
 * This class handles the generic validation of Strings not being Empty.
 * @Author: George
 * @Since: May 09, 2026
 */

public class GenericNameValidator<T> implements Validator<T> {

    // lambda function
    private Function<T, String> valueExtractor;
    private String fieldName;

    public GenericNameValidator(Function<T, String> valueExtractor, String fieldName) {
        this.valueExtractor = valueExtractor;
        this.fieldName = fieldName;
    }

    @Override
    public void validate(T t) {
        String value =valueExtractor.apply(t);

        if(value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException("The "+ fieldName+ " can't be empty!");
        }
    }
}