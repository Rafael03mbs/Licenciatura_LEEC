public class CylinderStart implements Cylinder {

    @Override
    public void moveForward() {
        SplitterConveyor.cylinderStartMoveForward();
    }
    @Override
    public void moveBackward() {
        SplitterConveyor.cylinderStart_moveBackward();
    }
    @Override
    public void stop() {
        SplitterConveyor.cylinderStartStop();
    }
    @Override
    public int getPosition() {
        int position = SplitterConveyor.cylinderStartGetPosition();

        return position;
    }
    @Override
    public void gotoPosition(int position) {

        if (position == 0) {
            while (SplitterConveyor.cylinderStartGetPosition() != 1) { // Corrigido: verifica se está em 0
                SplitterConveyor.cylinderStart_moveBackward();

            }
            SplitterConveyor.cylinderStartStop();
        } else if (position == 1) {
            while (SplitterConveyor.cylinderStartGetPosition() != 0) { // Corrigido: verifica se está em 1
                //System.out.println("avancou?");
                SplitterConveyor.cylinderStartMoveForward();


            }
            SplitterConveyor.cylinderStartStop();
        }
    }
    @Override
    public boolean boxDetected() {
        return SplitterConveyor.isBoxAtDock1();
    }
}
