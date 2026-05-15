
package Prezentare;

import BusinessLogic.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import DataModel.*;



public class App {
    public static void main(String[] args) {

        TaskManagement manager = new TaskManagement();
        manager.loadTasks();
        manager.loadEmps();

        MainFrame view = new MainFrame();

        Controller controller = new Controller(view, manager);

        view.setVisible(true);
    }
}