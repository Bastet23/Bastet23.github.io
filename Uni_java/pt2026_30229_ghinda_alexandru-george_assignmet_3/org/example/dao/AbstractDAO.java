package org.example.dao;

import org.example.connection.ConnectionFactory;

import java.beans.PropertyDescriptor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.lang.reflect.ParameterizedType;
import java.sql.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;

/**
 * This class handles the CRUD operations in a reflexive way.
 * @Author: George
 * @Since: May 09, 2026
 */
public class AbstractDAO<T> {

    protected static final Logger LOGGER= Logger.getLogger(AbstractDAO.class.getName());

    private final Class<T> type;

    @SuppressWarnings("unchecked")
    public AbstractDAO(Class<T> type) {
        this.type = (Class<T>) ((ParameterizedType) getClass().getGenericSuperclass()).getActualTypeArguments()[0];
    }

    private String createSelectQuery(String field)
    {
        StringBuilder sb=new StringBuilder();
        sb.append("select * from `").append(type.getSimpleName()).append("` WHERE "+ field+" =?");
        return sb.toString();
    }

    private String createFindAllQuery() {
        return "select* from`" + type.getSimpleName() + "`";
    }

    private String createInsertQuery() {
        StringBuilder sb= new StringBuilder();
        sb.append("insert into `").append(type.getSimpleName()).append("` (");
        StringBuilder values = new StringBuilder(" values(");

        List<String> fieldNames = Arrays.stream(type.getDeclaredFields())
                .map(field -> field.getName()) //get the name of each field
                .filter(name -> !name.equals("id")) //dar il pastrez doar daca nu e id
                .collect(Collectors.toList());

        for(int i = 0; i < fieldNames.size(); i++) {
            sb.append("`").append(fieldNames.get(i)).append("`");
            values.append("?");
            if(i < fieldNames.size() - 1) {
                sb.append(", ");
                values.append(", ");
            }
        }
        sb.append(")");
        values.append(")");
        sb.append(values);
        return sb.toString();
    }

    private String createUpdateQuery() {
        StringBuilder sb= new StringBuilder();
        sb.append("update `").append(type.getSimpleName()).append("` set ");

        List<String> fieldNames = Arrays.stream(type.getDeclaredFields())
                .map(field -> field.getName())
                .filter(name -> !name.equals("id"))
                .collect(Collectors.toList());

        for(int i= 0; i< fieldNames.size(); i++) {
            sb.append("`").append(fieldNames.get(i)).append("` = ?");
            if(i< fieldNames.size() - 1) {
                sb.append(", ");
            }
        }
        sb.append(" where id = ?");
        return sb.toString();
    }

    private String createDeleteQuery() {
        return "delete from `" + type.getSimpleName() + "` where id = ?";
    }

    public T findById(int id){
        Connection connection= null;
        PreparedStatement statement= null;
        ResultSet resultSet= null;
        String query= createSelectQuery("id");
        try {
            connection= ConnectionFactory.getConnection();
            statement= connection.prepareStatement(query);
            statement.setInt(1, id);
            resultSet= statement.executeQuery();

            List<T> list = createObject(resultSet);
            if (!list.isEmpty()) {
                return list.get(0);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, type.getName() + "DAO:findById() " + e.getMessage());
        } finally {
            ConnectionFactory.close(resultSet);
            ConnectionFactory.close(statement);
            ConnectionFactory.close(connection);
        }
        return null;
    }


    private List<T> createObject(ResultSet resultSet)
    {
        List<T> list=new ArrayList<T>();

        try{
            while(resultSet.next()){
                T instance=type.newInstance();

                for(Field field:type.getDeclaredFields()){
                    Object value =resultSet.getObject(field.getName());
                    PropertyDescriptor propertyDescriptor=new PropertyDescriptor(field.getName(), type);
                    Method method=propertyDescriptor.getWriteMethod();
                    method.invoke(instance, value);
                }
                list.add(instance);
            }
        }catch(InstantiationException e){
            LOGGER.log(Level.WARNING, type.getName()+ "DAO:createObject() "+ e.getMessage());
        }
        catch(Exception e){
            LOGGER.log(Level.WARNING, type.getName()+ "DAO:createObject() "+ e.getMessage());
        }


        return list;
    }

    public List<T> findAll() {
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;
        String query = createFindAllQuery();
        try {
            connection = ConnectionFactory.getConnection();
            statement = connection.prepareStatement(query);
            resultSet = statement.executeQuery();
            return createObject(resultSet);
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, type.getName() + "DAO:findAll " + e.getMessage());
        } finally {
            ConnectionFactory.close(resultSet);
            ConnectionFactory.close(statement);
            ConnectionFactory.close(connection);
        }
        return null;
    }

    public T insert(T t) {
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;
        String query = createInsertQuery();
        try{
            connection = ConnectionFactory.getConnection();

            statement = connection.prepareStatement(query, Statement.RETURN_GENERATED_KEYS);

            int parameterIndex= 1;
            for(Field field: type.getDeclaredFields()) {
                if(!field.getName().equals("id")) {
                    PropertyDescriptor propertyDescriptor= new PropertyDescriptor(field.getName(), type);
                    Method method= propertyDescriptor.getReadMethod();
                    Object value= method.invoke(t);
                    statement.setObject(parameterIndex++, value);
                }
            }

            statement.executeUpdate();

            resultSet = statement.getGeneratedKeys();
            if(resultSet.next()) {
                int generatedId = resultSet.getInt(1);
                PropertyDescriptor propertyDescriptor= new PropertyDescriptor("id", type);
                Method method= propertyDescriptor.getWriteMethod();
                method.invoke(t, generatedId);
            }
            return t;

        } catch (Exception e) {
            LOGGER.log(Level.WARNING, type.getName() + "DAO:insert " + e.getMessage());
        } finally {
            ConnectionFactory.close(resultSet);
            ConnectionFactory.close(statement);
            ConnectionFactory.close(connection);
        }
        return null;
    }

    public T update(T t) {
        Connection connection= null;
        PreparedStatement statement= null;
        String query= createUpdateQuery();
        try{
            connection= ConnectionFactory.getConnection();
            statement= connection.prepareStatement(query);

            int parameterIndex= 1;
            Object idValue= null;

            for(Field field: type.getDeclaredFields()) {
                PropertyDescriptor propertyDescriptor= new PropertyDescriptor(field.getName(), type);
                Method method= propertyDescriptor.getReadMethod();
                Object value= method.invoke(t);

                if (!field.getName().equals("id")) {
                    statement.setObject(parameterIndex++, value);
                }else {
                    idValue= value;
                }
            }

            statement.setObject(parameterIndex, idValue);
            statement.executeUpdate();
            return t;

        }catch (Exception e) {
            LOGGER.log(Level.WARNING, type.getName() + "DAO:update " + e.getMessage());
        }finally {
            ConnectionFactory.close(statement);
            ConnectionFactory.close(connection);
        }
        return null;
    }

    public boolean delete(int id) {
        Connection connection= null;
        PreparedStatement statement= null;
        String query= createDeleteQuery();
        try {
            connection = ConnectionFactory.getConnection();
            statement = connection.prepareStatement(query);
            statement.setInt(1, id);
            int rowsAffected = statement.executeUpdate();
            return rowsAffected > 0;
        }catch (SQLException e) {
            LOGGER.log(Level.WARNING, type.getName() + "DAO:delete " + e.getMessage());
        } finally {
            ConnectionFactory.close(statement);
            ConnectionFactory.close(connection);
        }
        return false;
    }

}
