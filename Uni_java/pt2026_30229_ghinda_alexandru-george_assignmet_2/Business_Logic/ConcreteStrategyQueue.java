package Business_Logic;

import java.util.List;
import Model.*;


public class ConcreteStrategyQueue implements Strategy {
    @Override
    public void addTask(List<Server> servers, Task t) {

        if(servers==null || servers.isEmpty())
            return;

        Server shortestServer = servers.get(0);

        int minQueue=shortestServer.getTasks().size();

        for(Server server:servers){

            if(server.getTasks().size()<minQueue){
                minQueue=server.getTasks().size();
                shortestServer=server;
            }
        }

        shortestServer.addTask(t);
    }
}
