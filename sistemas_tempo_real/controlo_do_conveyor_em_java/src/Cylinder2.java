public class Cylinder2 implements Cylinder {

    @Override
    public void moveForward() {
        SplitterConveyor.cylinder2MoveForward();
    }
    @Override
    public void moveBackward() {
        SplitterConveyor.cylinder2MoveBackward();
    }
    @Override
    public void stop() {
        SplitterConveyor.cylinder2Stop();
    }
    @Override
    public int getPosition() {
        return SplitterConveyor.cylinder2GetPosition();
    }
    @Override
    public void gotoPosition(int position) {
        SplitterConveyor.cylinder2MoveForward();
        if (position == 1) {
            while (SplitterConveyor.cylinder2GetPosition() != 0) { // Corrigido: verifica se está em 0
                SplitterConveyor.cylinder2MoveBackward();
                //System.out.println("positoin: "+SplitterConveyor.cylinder2GetPosition());
            }
            SplitterConveyor.cylinder2Stop();
        } else if (position == 0) {
            while (SplitterConveyor.cylinder2GetPosition() != 1) { // Corrigido: verifica se está em 1
                //System.out.println("avancou?");
                SplitterConveyor.cylinder2MoveForward();
                //System.out.println("positoin: "+SplitterConveyor.cylinder2GetPosition());

            }
            SplitterConveyor.cylinder2Stop();
        }
    }
    @Override
    public boolean boxDetected() {
        return SplitterConveyor.isBoxAtDock2();
    }
}
