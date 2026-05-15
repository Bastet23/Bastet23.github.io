package Business_Logic;

import java.util.List;
import Model.*;


public class ConcreteStrategyTime implements Strategy {
    @Override
    public void addTask(List<Server> servers, Task t) {

    if(servers==null || servers.isEmpty())
        return;

    Server shortestServer = servers.get(0);

    int minWaitTime=shortestServer.getWaitingPeriod().get();

    for(Server server:servers){

        if(server.getWaitingPeriod().get()<minWaitTime){
            minWaitTime=server.getWaitingPeriod().get();
            shortestServer=server;
        }
    }

    shortestServer.addTask(t);
    }
}
