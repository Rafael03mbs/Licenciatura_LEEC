public class Cylinder1_2Thread extends Thread {
    private Cylinder cylinder;
    private volatile boolean running = true; // Flag para controle da thread

    public Cylinder1_2Thread(Cylinder cylinder) {
        this.cylinder = cylinder;
    }

    public void stopThread() {
        running = false;
    }

    public void initializeCylinder1_2Thread() throws InterruptedException {
        this.cylinder.gotoPosition(0);
        this.cylinder.gotoPosition(1);
        //this.cylinder.gotoPosition(0);

    }

    public void run() {

            try {
                this.initializeCylinder1_2Thread();
            } catch (InterruptedException e) {
                throw new RuntimeException(e);
            }

    }
}