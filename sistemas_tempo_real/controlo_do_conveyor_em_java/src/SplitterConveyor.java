public class SplitterConveyor {
    static{
        System.load("C:\\str\\SplitterConveyor\\x64\\Debug\\SplitterConveyor.dll");
    }
    static synchronized native public void initializeHardwarePorts();

    static synchronized native public void cylinder1MoveForward();
    static synchronized native public void cylinder1MoveBackward();
    static synchronized native public void cylinder1Stop();
    static synchronized native public int cylinder1GetPosition();

    static synchronized native public void cylinderStartMoveForward();
    static synchronized native public void cylinderStartStop();
    static synchronized native public int cylinderStartGetPosition();
    static synchronized native public void cylinderStart_setPosition(int position);
    static synchronized native public void cylinderStart_moveBackward();

    static synchronized native public void cylinder2MoveForward();
    static synchronized native public void cylinder2MoveBackward();
    static synchronized native public void cylinder2Stop();
    static synchronized native public int cylinder2GetPosition();

    static synchronized native public void conveyorMove();
    static synchronized native public void conveyorStop();

    static synchronized native public int getIdentificationSensors();

    static synchronized native public boolean isBoxAtDock1();
    static synchronized native public boolean isBoxAtDock2();
    static synchronized native public boolean isBoxAtDockEnd();

    public static synchronized native void LED_ON();
    public static synchronized native void LED_OFF();

    public static synchronized native void Dock1LED_ON();
    public static synchronized native void Dock1LED_OFF();

    public static synchronized native void Dock2LED_ON();
    public static synchronized native void Dock2LED_OFF();

    public static synchronized native void DockEndLED_ON();
    public static synchronized native void DockEndLED_OFF();

    static synchronized native public boolean Dock1_fechou();
    static synchronized native public boolean Dock2_fechou();
    static synchronized native public boolean ambosBotoesPressionados();

}
