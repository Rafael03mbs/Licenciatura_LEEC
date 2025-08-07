public class Cylinder1 implements Cylinder{

    @Override
    public void moveForward() {
        SplitterConveyor.cylinder1MoveForward();
    }
    @Override
    public void moveBackward() {
        SplitterConveyor.cylinder1MoveBackward();
    }
    @Override
    public void stop() {
        SplitterConveyor.cylinder1Stop();
    }
    @Override
    public int getPosition() {
        return SplitterConveyor.cylinder1GetPosition();
    }
    @Override
    public void gotoPosition(int position) {
        SplitterConveyor.cylinder1MoveForward();
        if (position == 1) {
            while (SplitterConveyor.cylinder1GetPosition() != 0) { // Corrigido: verifica se está em 0
                SplitterConveyor.cylinder1MoveBackward();
                //System.out.println("positoin: "+SplitterConveyor.cylinder1GetPosition());
            }
            SplitterConveyor.cylinder1Stop();
        } else if (position == 0) {
            while (SplitterConveyor.cylinder1GetPosition() != 1) { // Corrigido: verifica se está em 1
                //System.out.println("avancou?");
                SplitterConveyor.cylinder1MoveForward();
                //System.out.println("positoin: "+SplitterConveyor.cylinder1GetPosition());

            }
            SplitterConveyor.cylinder1Stop();
        }
    }
    @Override
    public boolean boxDetected(){
        return SplitterConveyor.isBoxAtDock1();
    }
}
