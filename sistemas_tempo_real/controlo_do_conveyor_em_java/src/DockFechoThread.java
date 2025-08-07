public class DockFechoThread extends Thread {

    public boolean dock1 = false;
    public boolean dock2 = false;
    private volatile boolean running = true; // Para parar a thread de forma segura
    public boolean led = false;

    public void stopDockfecho() {
        running = false;
    }

    private void verificarSensores() {
        int sensorValue = SplitterConveyor.getIdentificationSensors();
        if(SplitterConveyor.ambosBotoesPressionados()){
            System.out.println("Both docks are closed for 10s");
            led = false;
            long startTime = System.currentTimeMillis();
            long endTime = startTime + (3 * 1000L);
            while(SplitterConveyor.ambosBotoesPressionados()){
                dock1 = true;
                dock2 = true;
                if (!led)
                {
                    while (System.currentTimeMillis() < endTime)
                    {
                        SplitterConveyor.LED_ON();
                    }
                }
                led = true;
                SplitterConveyor.LED_OFF();
            }
            dock1=false;
            dock2=false;

            System.out.println("Both docks are opened");
        }
        else if (SplitterConveyor.Dock1_fechou()) {
            dock1 = true; // O sensor 1 está ativo
            //System.out.println("Fechou1");
        } else if (!SplitterConveyor.isBoxAtDock1()) {
            dock1 = false;
        }

        if (SplitterConveyor.Dock2_fechou()) {
            dock2 = true; // O sensor 2 está ativo
            //System.out.println("Fechou2");
        } else {
            dock2 = false;
        }
    }

    public void startDockfecho() {
        while (running) {
            verificarSensores(); // Centraliza a lógica da verificação

        }
    }

    @Override
    public void run() {
        this.startDockfecho();
    }
}

