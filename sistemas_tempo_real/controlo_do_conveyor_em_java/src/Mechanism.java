public class Mechanism {

    public void conveyorMove(){
        SplitterConveyor.conveyorMove();
    }
    public void conveyorStop(){
        SplitterConveyor.conveyorStop();
    }
    public boolean switchDock1Pressed(){
         //TODO... for now return False
        return false;
    }
    public boolean switchDock2Pressed(){
        //TODO... for now return False
        return false;
    }
    public void ledSwitch(int on){
        //TODO...
    }
    public int getIdentificationSensors(){
        return SplitterConveyor.getIdentificationSensors();
    }
}
