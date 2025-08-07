import javax.swing.*;
import java.util.Scanner;
public class Test_Demo {

    public static void main(String[] args) throws InterruptedException {
        SplitterConveyor.initializeHardwarePorts();
        Mechanism mechanism = new Mechanism();
        mechanism.conveyorMove();

        CylinderStart clStart = new CylinderStart();
        CylinderThread clStartT = new CylinderThread(clStart);
        BoxIdentificationThread boxIDT = new BoxIdentificationThread();

        System.out.println("Starting identification process...");
        boxIDT.start();
        clStartT.start();
        clStartT.join();
        boxIDT.join();

        int boxID = boxIDT.getBoxIdentification();
        System.out.println("Result of box ID:" + boxID);
        switch (boxID){
            case 1: System.out.println("Box 1");break;
            case 2: System.out.println("Box 2");break;
            case 3: System.out.println("Box 3");break;
        }
    }


}
