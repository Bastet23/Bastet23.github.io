package org.example.bll.validators.val;

/**
 * Validator interface
 * @Author: George
 * @Since: May 09, 2026
 */
public interface Validator<T> {

	public void validate(T t);
}
