package BusinessLogic;

import java.util.*;
import DataModel.*;

public class Utility {


    public List<Employee> filterEmployees(TaskManagement manager) {
        List<Employee> result = new ArrayList<Employee>();


        Map<Employee,Integer> durations=new HashMap<Employee,Integer>();

        for (Employee e : manager.getAssignations().keySet()) {

            int duration= manager.calculateEmployeeWorkDuration(e.getIdEmployee());
            if (duration > 40) {
                result.add(e);

                durations.put(e, duration);
            }
        }

        result.sort(new Comparator<Employee>() {
            @Override
            public int compare(Employee o1, Employee o2) {
                return Integer.compare(durations.get(o1), durations.get(o2));
            }
        });
        return result;
    }



    private void countTasksRec(Task task, HashMap<String, Integer> raport)
    {
        if(task.getStatusTask().equals("Completed")){
            raport.put("Completed", raport.get("Completed")+1);
        }
        else{
            raport.put("Uncompleted", raport.get("Uncompleted")+1);
        }

        if(task instanceof ComplexTask){
            ComplexTask recursiv=(ComplexTask)task;
            if(recursiv.getTasks()!=null){
                for(Task tRec: recursiv.getTasks()){
                    countTasksRec(tRec,raport);
                }
            }
        }

    }


    public HashMap<String, HashMap<String, Integer>> computeTasks(TaskManagement manager) {
        HashMap<String, HashMap<String, Integer>> result = new HashMap<>();

        for(HashMap.Entry<Employee,List<Task>> entry:manager.getAssignations().entrySet())
        {
            Employee e=entry.getKey();
            List<Task> list=entry.getValue();

            HashMap<String, Integer> raport=new HashMap<>();
            raport.put("Completed", 0);
            raport.put("Uncompleted", 0);

            if(list!=null){
                for(Task task:list){
                   countTasksRec(task,raport);
                }
            }


            result.put(e.getName(),raport);

        }

        return result;
    }

}


