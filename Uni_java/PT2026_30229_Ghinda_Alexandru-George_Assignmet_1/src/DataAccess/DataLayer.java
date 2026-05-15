package DataAccess;

import java.io.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import DataModel.*;

public class DataLayer {

    private static final String FNAME="Tema_01_TP_data";
    private static  List<Task> tempTasks =null;
    private static  Map<Employee,List<Task>> tempMap =null;
    private static  boolean isLoaded =false;  // flag pentru a incarca o singura data



    //metoda de save
    public static void save (Map<Employee, List<Task>> assignations, List<Task> unassignedTasks)
    {
        FileOutputStream fileOut=null;
        ObjectOutputStream out=null;


      try{
          fileOut=new FileOutputStream(FNAME);
          out=new ObjectOutputStream(fileOut);

          out.writeObject(assignations);
          out.writeObject(unassignedTasks);
          System.out.println("Succes la salvare");
      }catch(IOException e)
      {
          System.out.println("Eroare la salvare" +e.getMessage());
      }

      finally{


        try
        {
            if (out != null)
                out.close();
            if(fileOut != null)
                fileOut.close();
        }
        catch (IOException e)
        {
            System.out.println("Eroare la inchidere" + e.getMessage());
        }
      }
    }


    //metoda de load in temp

    public static void loadTemp() {

        if(isLoaded)
            return;

        File file = new File(FNAME);
        if (!file.exists()) {
            System.out.println("Nu existe date salvate anterior");
            tempTasks=new ArrayList<>();
            tempMap=new HashMap<>();
            isLoaded=true;
            return;
        }

        FileInputStream fileIn = null;
        ObjectInputStream in = null;

        try {
            fileIn = new FileInputStream(FNAME);
            in = new ObjectInputStream(fileIn);

            tempMap = (Map<Employee, List<Task>>) in.readObject();
            tempTasks = (ArrayList<Task>) in.readObject();

            System.out.println("Succes la incarcare employeeMap");


        } catch (IOException | ClassNotFoundException e) {
            System.out.println("Eroare la incarcare employeeMap" + e.getMessage());
                //in caz de eroare evitam nullptrexception
            tempTasks=new ArrayList<>();
            tempMap=new HashMap<>();

        } finally {

            isLoaded=true;
            try {
                if (in != null)
                    in.close();
                if (fileIn != null)
                    fileIn.close();
            } catch (IOException e) {
                System.out.println("Eroare la incarcare employeeMap (Inchiderea fisierelor)" +e.getMessage());
            }

        }
    }


    //load urile in sine
    public static Map<Employee,List<Task>> loadEmp() {
        loadTemp();
        return tempMap;
    }

    public static List<Task> loadTasks()
    {
        loadTemp();
        return tempTasks;
    }


}


