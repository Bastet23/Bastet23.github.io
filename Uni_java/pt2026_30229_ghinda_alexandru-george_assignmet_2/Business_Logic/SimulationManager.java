package Business_Logic;

import javax.swing.*;
import java.util.*;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;

import Model.*;
import GUI.*;

public class SimulationManager implements Runnable {

    //input
    public int timeLimit=30;
    public int minArrivalTime=2;
    public int maxArrivalTime=20;
    public int maxProcessingTime=10;
    public int minProcessingTime=2;
    public int numberOfServers=3;
    public int numberOfClients=6;
    public SelectionPolicy selectionPolicy= SelectionPolicy.SHORTEST_TIME;


    //logic
    private Scheduler scheduler;

    private SimulationFrame frame;

    private List<Task> generatedTasks;

    //stats
    private double totalServiceTime=0;
    private double totalWaitingTime=0;
    private int maxTasksinSystem=0;
    private int peakHour=0;


    public SimulationManager(int timeLimit, int minArrivalTime, int maxArrivalTime,
                             int maxProcessingTime, int minProcessingTime,
                             int numberOfServers, int numberOfClients,
                             SelectionPolicy policy, SimulationFrame frame) {

        this.timeLimit = timeLimit;
        this.minArrivalTime = minArrivalTime;
        this.maxArrivalTime = maxArrivalTime;
        this.maxProcessingTime = maxProcessingTime;
        this.minProcessingTime = minProcessingTime;
        this.numberOfServers = numberOfServers;
        this.numberOfClients = numberOfClients;
        this.selectionPolicy = policy;
        this.frame = frame;

        scheduler=new Scheduler(numberOfServers,numberOfClients);

        scheduler.changeStrategy(this.selectionPolicy);

        generateNRandomTasks();
    }

    private void generateNRandomTasks() {
        generatedTasks=new ArrayList<Task>();
        for(int i=0;i<numberOfClients;i++){

            int processingTime=(int)(Math.random()*(maxProcessingTime-minProcessingTime)+minProcessingTime);

            int arrivalTime = (int)(Math.random()*(maxArrivalTime - minArrivalTime + 1) + minArrivalTime);

            Task task=new Task(arrivalTime,processingTime, i+1);
            totalServiceTime+=processingTime;
            generatedTasks.add(task);
        }

        Collections.sort(generatedTasks);
    }

    public void run() {
        try(PrintWriter writer = new PrintWriter(new FileWriter("simulation_log.txt"))) {
            int currentTime = 0;

            while(currentTime < timeLimit) {
                dispatchTasks(currentTime);
                updatePeakHour(currentTime);
                logCurrentTime(currentTime, writer);

                frame.updateDisplay(scheduler.getServers(),generatedTasks, currentTime);

                if (isSimulationComplete()) {
                    System.out.println("All tasks finished early at time " + currentTime +"\n");
                    break;
                }

                currentTime++;
                Thread.sleep(1000); // FIXED: Thread.sleep instead of wait()
            }
            logFinalStatistics(writer);
            System.out.println("Simulation finished! Logs saved.");

        } catch(IOException | InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }

    private void dispatchTasks(int currentTime) {
        Iterator<Task> iterator=generatedTasks.iterator();
        while(iterator.hasNext()) {
            Task task=iterator.next();
            if(task.getArrivalTime()==currentTime) {
                scheduler.dispatchTask(task);

               totalWaitingTime+= task.getWaitTime();

                iterator.remove();
            }
        }
    }

    private void updatePeakHour(int currentTime) {
        int nrTasksInSystem=0;
        for(Server server:scheduler.getServers()) {
            nrTasksInSystem+=server.getTasks().size();
        }

        if(nrTasksInSystem>maxTasksinSystem) {
            peakHour=currentTime;
            maxTasksinSystem=nrTasksInSystem;
        }

    }

    private void logCurrentTime(int currentTime, PrintWriter writer){
        StringBuilder sb=new StringBuilder();
        sb.append("Time "+currentTime+"\n" + "Waiting Clients:\n");


        for(Task task:generatedTasks) {
            sb.append(task.toString()+", ");
        }
        sb.append("\n");

        int serverId=1;

        for(Server server:scheduler.getServers()) {
            sb.append("Queue "+ serverId+": " +server.toString()+"\n");
            serverId++;
        }

        writer.println(sb.toString());
        System.out.println(sb.toString());
    }

    private void logFinalStatistics(PrintWriter writer) {
        double avgServiceTime=totalServiceTime/numberOfClients;
        double avgWaitingTime=totalWaitingTime/numberOfClients;

        String stats= "Avg Service Time: "+avgServiceTime+"\n" + "Avg Waiting Time: "+avgWaitingTime+"\n"+ "Peak Hour: "+peakHour+ "\n";

        writer.println(stats);
        System.out.println(stats);

        SwingUtilities.invokeLater(new Runnable() {
            @Override
            public void run() {
                frame.showFinalStats(avgServiceTime, avgWaitingTime, peakHour);
            }
        });
    }

    private boolean isSimulationComplete() {
        if (!generatedTasks.isEmpty()) {
            return false;
        }

        for (Server server : scheduler.getServers()) {
            if (!server.getTasks().isEmpty()) {
                return false;
            }
        }

        return true;
    }


    public static void main(String[] args) {
        SwingUtilities.invokeLater(new Runnable() {
            @Override
            public void run() {
                SimulationFrame gui = new SimulationFrame();
                gui.setVisible(true);
            }
        });
    }
}


