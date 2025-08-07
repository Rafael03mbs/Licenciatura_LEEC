# Projeto: Modelação de Sistemas com Redes de Petri

Este trabalho, o terceiro da cadeira de Sistemas de Tempo Real, focou-se na **modelação formal de sistemas** utilizando Redes de Petri (PN), uma linguagem gráfica matemática.

### Desafio Técnico
O projeto envolveu uma fase de **análise teórica**, modelando PNs com diferentes propriedades (segurança, deadlocks), e uma fase de **aplicação prática**, controlando um sistema real (um separador de frutas) a partir do modelo formal.

### Funcionalidades Implementadas
*   **Modelação do Sistema:** Desenho de uma Rede de Petri completa no HPSim para controlar a separação de maçãs, peras e limões.
*   **Controlo de Emergência:** Implementação da lógica de Stop/Resume no modelo da PN.
*   **Interface de Utilizador (UI):** Criação de um terminal em **Python** que interage com o simulador HPSim (via DLL) para mostrar estatísticas do sistema.

### Tecnologias Utilizadas
*   **Linguagem de Modelação:** Redes de Petri (PN)
*   **Ferramenta de Simulação:** HPSim
*   **Linguagem de Scripting/UI:** Python
*   **Interface:** DLL para comunicação entre HPSim e Python.