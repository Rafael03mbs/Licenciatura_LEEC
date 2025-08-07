public class BoxIdentificationThread extends Thread {

    private int brickType = -1; // Armazena o tipo de tijolo identificado
    private boolean dot1 = false; // Armazena o estado do sensor 1
    private boolean dot2 = false; // Armazena o estado do sensor 2

    public int getBoxIdentification() {
        return brickType;
    }

    public void startBoxIdentification() {
        long startTime = System.currentTimeMillis();
        long timeout = 5000; // 5 segundos em milissegundos

        // Continua até uma caixa ser detectada na doca 1 ou o timeout ser atingido
        while (!SplitterConveyor.isBoxAtDock1()) {
            // Verifica se o timeout foi atingido
            if (System.currentTimeMillis() - startTime > timeout) {
                brickType = -1; // Define um valor indicando timeout ou outro estado padrão
                return;
            }

            int sensorValue = SplitterConveyor.getIdentificationSensors();

            if (sensorValue == 1) {
                dot1 = true; // O sensor 1 está ativo
            } else if (sensorValue == 2) {
                dot2 = true; // O sensor 2 está ativo
            }
        }

        // Avalia o tipo de tijolo com base nos sensores
        if (dot1 && dot2) {
            brickType = 3; // Ambos sensores ativados
        } else if (dot1 || dot2) {
            brickType = 2; // Apenas um sensor ativado
        } else {
            brickType = 1; // Nenhum sensor ativado
        }
    }


    @Override
    public void run() {
        this.startBoxIdentification();
    }
}
