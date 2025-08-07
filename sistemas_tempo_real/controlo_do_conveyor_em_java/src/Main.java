import java.util.Scanner;

public class Main {
    public static void main(String[] args) throws InterruptedException {
        SplitterConveyor.initializeHardwarePorts();

        Mechanism mech = new Mechanism();
        Cylinder1 cy1 = new Cylinder1();
        Cylinder2 cy2 = new Cylinder2();
        CylinderStart clStart = new CylinderStart();

        int dock1BoxCount = 0; // Total boxes successfully delivered to Dock 1
        int dock2BoxCount = 0; // Total boxes successfully delivered to Dock 2
        int dock1RejectCount = 0; // Boxes rejected at Dock 1
        int dock2RejectCount = 0; // Boxes rejected at Dock 2
        int dock3BoxCount=0;
        boolean interrupt_emergency = false;
        boolean finish;
        char letra;
        Scanner scan = new Scanner(System.in);

        CylinderThread clStartT = null; // Thread para o cilindro
        Cylinder1_2Thread cy1T = null;
        Cylinder1_2Thread cy2T = null;
        DockFechoThread dockFecho = null;

        while (true) { // Loop infinito para permitir reinicializações
            System.out.print("Press 's' to begin working cycle: ");
            while (scan.next().charAt(0) != 's') {
                // Aguarda o comando 's'
            }

            // Inicializa e inicia a thread DockFechoThread após pressionar 's'
            if (dockFecho == null || !dockFecho.isAlive()) {
                dockFecho = new DockFechoThread();
                dockFecho.start();

            }
            SplitterConveyor.conveyorMove();

            finish = false;

            while (!finish) {
                System.out.println("Select an Option:");
                System.out.println("P - Get Package from Queue");
                System.out.println("S - Show System Statistics");
                System.out.println("E - Emergency Stop");
                System.out.println("R - Resume");
                System.out.println("F - Finish");
                letra = scan.next().charAt(0);
                letra = Character.toUpperCase(letra);

                switch (letra) {
                    case 'P':
                        if (clStartT == null || !clStartT.isAlive()) {
                            clStartT = new CylinderThread(clStart);
                            clStartT.start();
                            System.out.println("Starting operation...");
                            BoxIdentificationThread boxIDT = new BoxIdentificationThread();
                            boxIDT.start();
                            boxIDT.join();
                            System.out.println("Box ID: " + boxIDT.getBoxIdentification()+"\n\n");

                            if (boxIDT.getBoxIdentification() == 1) {
                                while (!SplitterConveyor.isBoxAtDock1()) {
                                    // Espera
                                }
                                SplitterConveyor.conveyorStop();
                                if (!dockFecho.dock1) {
                                    if (cy1T == null || !cy1T.isAlive()) {
                                        cy1T = new Cylinder1_2Thread(cy1);
                                        cy1T.start();
                                        cy1T.join();

                                        dock1BoxCount++; // Incrementa contagem de caixas na Dock 1
                                        LedThread task = new LedThread(1); // Tarefa que dura 3 segundos
                                        task.start();
                                        task.join();
                                    }
                                } else {
                                    dock1RejectCount++; // Incrementa contagem de rejeições na Dock 1
                                    System.out.println("Box rejected at Dock 1.");
                                }
                                SplitterConveyor.conveyorMove();

                            } else if (boxIDT.getBoxIdentification() == 2) {
                                while (!SplitterConveyor.isBoxAtDock2()) {
                                    // Espera
                                }
                                SplitterConveyor.conveyorStop();
                                if (!dockFecho.dock2) {
                                    if (cy2T == null || !cy2T.isAlive()) {
                                        cy2T = new Cylinder1_2Thread(cy2);
                                        cy2T.start();
                                        cy2T.join();

                                        dock2BoxCount++; // Incrementa contagem de caixas na Dock 2
                                        LedThread task = new LedThread(2); // Tarefa que dura 3 segundos
                                        task.start();
                                        task.join();
                                    }
                                } else {
                                    dock2RejectCount++; // Incrementa contagem de rejeições na Dock 2
                                    System.out.println("Box rejected at Dock 2.");
                                }
                                SplitterConveyor.conveyorMove();
                            }
                            else if (boxIDT.getBoxIdentification() == 3){
                                dock3BoxCount++;
                                LedThread task = new LedThread(3); // Tarefa que dura 3 segundos
                                task.start();
                                task.join();
                            }

                        } else {
                            System.out.println("A cylinder operation is already in progress.");
                        }
                        break;

                    case 'S':
                        System.out.println("System Statistics:");
                        System.out.println("--------------------------------");

                        if(!interrupt_emergency){
                            System.out.println("System is running.");
                        }
                        else{
                            System.out.println("System is stopped.");
                        }
                        System.out.println("Total boxes delivered:");
                        System.out.println("Dock 1: " + dock1BoxCount + " boxes, " + dock1RejectCount + " rejected.");
                        System.out.println("Dock 2: " + dock2BoxCount + " boxes, " + dock2RejectCount + " rejected.");
                        System.out.println("Dock 3: " + (dock3BoxCount + dock1RejectCount + dock2RejectCount) + " boxes.");
                        System.out.println("--------------------------------");
                        break;

                    case 'F':
                        System.out.println("Finishing the system...");
                        if (clStartT != null && clStartT.isAlive()) {
                            clStartT.stopThread();
                            clStartT.join();
                        }
                        if (dockFecho != null && dockFecho.isAlive()) {
                            dockFecho.stopDockfecho();
                            dockFecho.join();
                        }
                        SplitterConveyor.conveyorStop();
                        finish = true;
                        System.out.println("System has been stopped.");
                        break;
                    case 'E':
                        if(!interrupt_emergency){
                            mech.conveyorStop();
                            System.out.println("EMERGENCY STOP");
                            interrupt_emergency = true;
                        }
                        break;
                    case 'R':
                        if(interrupt_emergency){
                            System.out.println("RESUME");
                            mech.conveyorMove();

                            interrupt_emergency = false;
                        }
                        break;
                    // Outras opções...
                }
            }
        }
    }
}
