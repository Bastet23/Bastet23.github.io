package DataModel;

import java.util.ArrayList;


public final class ComplexTask extends Task{

    private static final long serialVersionUID = 1L;

    ArrayList<Task> tasks;

    public ComplexTask(int idTask, String statusTask, ArrayList<Task> tasks) {
        super( idTask, statusTask);
        this.tasks = tasks;
    }
    public ComplexTask(int idTask, String statusTask) {
        super(idTask, statusTask);
        this.tasks = new ArrayList<Task>();
    }


    public ArrayList<Task> getTasks() {
        return tasks;
    }

    public void setTasks(ArrayList<Task> tasks) {
        this.tasks = tasks;
    }

    public void addTask(Task task) {
        this.tasks.add(task);
    }

    public Task getTask(int idTask) {
        return this.tasks.get(idTask);
    }
    public void removeTask(int idTask) {
        this.tasks.remove(idTask);
    }

    public int estimateDuration() {
        int sum = 0;
        for(Task task : this.tasks) {
            if(task instanceof ComplexTask) {
                sum += ((ComplexTask)task).estimateDuration();
            }
            else if (task instanceof SimpleTask) {
                sum += ((SimpleTask)task).estimateDuration();
            }
        }

        return sum;
    }


    @Override
    public String toString() {
        return super.toString() +
                ", nr Taskuri: "+ tasks.size() + " | TOTAL: " +estimateDuration()+"\n\n";
    }
}
