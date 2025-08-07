public class CylinderThread extends Thread {
    private Cylinder cylinder;
    private volatile boolean running = true; // Flag para controle da thread

    public CylinderThread(Cylinder cylinder) {
        this.cylinder = cylinder;
    }

    public void stopThread() {
        running = false;
    }

    public void initializeCylinderThread() throws InterruptedException {
        this.cylinder.gotoPosition(0);
        this.cylinder.gotoPosition(1);
        this.cylinder.gotoPosition(0);

    }

    public void run() {

            try {
                this.initializeCylinderThread();
            } catch (InterruptedException e) {
                throw new RuntimeException(e);
            }

    }
}