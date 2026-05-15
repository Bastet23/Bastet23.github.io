package DataModel;

public final class SimpleTask extends Task{

    private static final long serialVersionUID = 1L;

    private int startHour;
    private int endHour;


    public SimpleTask(int idTask, String statusTask, int startHour, int endHour) {
        super(idTask, statusTask);
        this.startHour = startHour;
        this.endHour = endHour;
    }

    public int getStartHour() {
        return startHour;
    }

    public void setStartHour(int startHour) {
        this.startHour = startHour;
    }

    public int getEndHour() {
        return endHour;
    }

    public void setEndHour(int endHour) {
        this.endHour = endHour;
    }

    public int estimateDuration()
    {
        if (startHour<endHour)
            return endHour - startHour;
        else
            return 24 -startHour + endHour;
    }

    @Override
    public String toString() {
        return super.toString() + "- ||" +estimateDuration()+ " ore ||";
    }
}
