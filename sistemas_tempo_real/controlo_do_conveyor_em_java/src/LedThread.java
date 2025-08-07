public class LedThread extends Thread {

    int seconds; // Duração da tarefa em segundos
    private boolean running = true; // Flag para controlar a execução

    public LedThread(int seconds) {
        this.seconds = seconds;
    }

    public void initializeLed() throws InterruptedException {
        //System.out.println("Thread iniciada. Executando tarefa por " + seconds + " segundos...");

        long startTime = System.currentTimeMillis();
        long endTime = startTime + (seconds * 1000L);

        while (System.currentTimeMillis() < endTime && running) {
            // Ação repetida
            SplitterConveyor.LED_ON();
            SplitterConveyor.LED_OFF();
        }
    }
            public void run() {

                try {
                    this.initializeLed();
                } catch (InterruptedException e) {
                    throw new RuntimeException(e);
                }
            }

    public void stopTask() {
        running = false; // Interrompe a execução
        this.interrupt(); // Interrompe a thread, se necessário
    }
}
