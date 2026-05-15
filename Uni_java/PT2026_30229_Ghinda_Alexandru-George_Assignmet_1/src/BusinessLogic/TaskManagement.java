package BusinessLogic;


import java.io.Serializable;
import java.util.*;
import DataModel.*;
import DataAccess.*;

//import javax.xml.crypto.Data;


public class TaskManagement implements Serializable {

    private static final long serialVersionUID = 1L;

    Map<Employee, List<Task>> assignations;

    //unasigned tasks to be saved in the database
    private List<Task> unassignedTasks;



    public TaskManagement() {
        this.unassignedTasks = new ArrayList<>();
        assignations = new HashMap<> ();
        unassignedTasks = new ArrayList<>();
    }

    public TaskManagement(Map<Employee, List<Task>> assignations, List<Task> unassignedTasks) {
        this.assignations = assignations;
        this.unassignedTasks = unassignedTasks;
    }

    public void addTaskToComplex(ComplexTask complex, Task task) {
        unassignedTasks.remove(task);
        unassignedTasks.remove(complex);
        complex.addTask(task);
        unassignedTasks.add(complex);
    }



    public Map<Employee, List<Task>> getAssignations() {
        return assignations;
    }

    public List<Task> getUnassignedTasks() {
        return this.unassignedTasks;
    }

    public void setAssignations(Map<Employee, List<Task>> assignations) {
        this.assignations = assignations;
    }

    public void addTask(Task task) {
        unassignedTasks.add(task);
    }

    public void removeTask(Task task) {
        removeTaskFromTree(unassignedTasks, task);
    }

    public void addEmployee(Employee employee) {
        List<Task> employeesTasks = new ArrayList<Task>();
        assignations.put(employee, employeesTasks);
    }

    public void removeEmployee(Employee employee) {
        if (assignations.containsKey(employee)) {

            List<Task> employeeTasks = assignations.get(employee);

            if (employeeTasks != null && !employeeTasks.isEmpty()) {
                unassignedTasks.addAll(employeeTasks);
            }

            assignations.remove(employee);
        }
    }

    public void assignTaskToEmployee(int idEmployee, Task task) {
        for(Employee employee : assignations.keySet()) {
            if(employee.getIdEmployee()==idEmployee) {
                assignations.get(employee).add(task);
                unassignedTasks.remove(task);
            }
        }
    }

    public boolean removeTaskFromTree(List<Task> tasks, Task tr) {

        if(tasks.remove(tr)) {
            return true;
        }

        for(Task t: tasks) {
            if(t instanceof ComplexTask) {
                ComplexTask recurisv=(ComplexTask)t;
                if(recurisv.getTasks()!=null) {
                    boolean removed=removeTaskFromTree(recurisv.getTasks(), tr);
                    if(removed) {
                        return true;
                    }
                }
            }
        }

        return false;
    }

    public void removeTaskFromEmployee(int idEmployee, Task task) {
        for(Employee employee : assignations.keySet()) {
            if(employee.getIdEmployee()==idEmployee) {

                boolean removed=removeTaskFromTree(assignations.get(employee), task);

                if(removed) {
                    unassignedTasks.add(task);
                }

                //oricum ar fii, am terminat
                break;
            }
        }
    }

    public int calculateEmployeeWorkDuration(int idEmployee) {
        int sum=0;
        for(Employee employee : assignations.keySet()) {
            if(employee.getIdEmployee()==idEmployee) {
                for(Task task : assignations.get(employee)) {
                    if(task.getStatusTask().equals("Uncompleted")) {
                        if(task instanceof SimpleTask) {
                            sum+= ((SimpleTask) task).estimateDuration();
                        }
                        else if(task instanceof ComplexTask) {
                            sum+= ((ComplexTask) task).estimateDuration();
                        }
                    }

                }
            }
        }
        return sum;
    }

    public void modifyTaskStatus(int idEmployee, int idTask){
        for(Employee employee : assignations.keySet()) {
            if(employee.getIdEmployee()==idEmployee) {
                for(Task task : assignations.get(employee)) {
                    if(task.getIdTask()==idTask) {
                        task.setStatusTask( task.getStatusTask().equals("Completed") ? "Uncompleted" : "Completed");
                    }
                }
            }
        }
    }

    public void saveWork()
    {
        DataLayer.save(assignations, unassignedTasks);
    }

    public void loadEmps()
    {
        this.assignations=DataLayer.loadEmp();
    }

    public void loadTasks()
    {
        this.unassignedTasks=DataLayer.loadTasks();
    }
}
