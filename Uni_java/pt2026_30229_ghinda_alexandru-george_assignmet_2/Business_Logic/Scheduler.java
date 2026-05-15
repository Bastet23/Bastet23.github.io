package Business_Logic;

import java.util.*;
import Model.*;


public class Scheduler {
    private List<Server> servers;
    private int maxNoServers;
    private int maxTasksPerServer;
    private Strategy strategy;


    public Scheduler(int maxNoServers, int maxTasksPerServer) {

        servers = new ArrayList<Server>();

        for(int i=0; i<maxNoServers; i++) {
            servers.add(new Server());
            Thread thread = new Thread(servers.get(i));
            thread.start();
        }
    }

    public void changeStrategy( SelectionPolicy policy) {


        if(policy== SelectionPolicy.SHORTEST_QUEUE) {
            strategy = new ConcreteStrategyQueue();
        }
        if(policy== SelectionPolicy.SHORTEST_TIME){
            strategy=new ConcreteStrategyTime();
        }
    }

    public void dispatchTask(Task t){

        strategy.addTask(servers,t);
    }

    public List<Server> getServers() {
        return servers;
    }
}
