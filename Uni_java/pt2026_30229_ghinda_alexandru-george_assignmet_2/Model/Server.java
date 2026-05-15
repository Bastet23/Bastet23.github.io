package Model;

import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.atomic.AtomicInteger;

public class Server implements Runnable {
    private BlockingQueue<Task> tasks;
    private AtomicInteger waitingPeriod;

    public Server() {
        tasks = new LinkedBlockingQueue<>();
        waitingPeriod = new AtomicInteger(0);
    }

    public synchronized void addTask(Task task) {
        // tin minte timpul de asteptare pentru statistica
        task.setWaitTime(this.waitingPeriod.get());

        tasks.add(task);
        waitingPeriod.addAndGet(task.getServiceTime());

        //trezim serverul
        this.notify();
    }

    public BlockingQueue<Task> getTasks() {
        return tasks;
    }

    public void setTasks(BlockingQueue<Task> tasks) {
        this.tasks = tasks;
    }

    public AtomicInteger getWaitingPeriod() {
        return waitingPeriod;
    }

    public void setWaitingPeriod(AtomicInteger waitingPeriod) {
        this.waitingPeriod = waitingPeriod;
    }

    @Override
    public void run() {
        while (true) {
            try{
                Task current=tasks.peek();

                if(current!=null) {
                    Thread.sleep(990);
                    current.setServiceTime(current.getServiceTime() - 1);
                    waitingPeriod.decrementAndGet();

                    if (current.getServiceTime() <= 0) {
                        tasks.poll();
                    }

                }
                else
                {
                    synchronized (this) {
                        this.wait();
                    }
                }

            }
            catch (InterruptedException e){

                Thread.currentThread().interrupt();
                System.out.println("Server interrupted");
                break;
            }
        }
    }

    @Override
    public String toString() {

        if(this.tasks.isEmpty())
        {
            return "closed\n";
        }
        else return this.tasks.toString();
    }

}
