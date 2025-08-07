# Projeto: Controlo de Conveyor Industrial com Java & JNI

Este projeto, referente ao segundo trabalho de laboratório de Sistemas de Tempo Real, consistiu no desenvolvimento de uma solução robusta para o controlo em tempo real de uma linha de montagem que separa caixas para diferentes fornecedores.

### Desafio Técnico

O principal desafio foi a gestão da **concorrência** e da **interação com hardware de baixo nível** a partir de uma linguagem de alto nível como o Java. A solução exigiu o desenvolvimento de uma biblioteca de ligação dinâmica (**DLL**) em **C/C++** para interfacear com a placa de aquisição de dados (NI USB 6509) através da **Java Native Interface (JNI)**. A lógica principal em Java teve de gerir múltiplas tarefas em paralelo (`Threads`) para monitorizar sensores e controlar atuadores de forma sincronizada.

### Funcionalidades Implementadas
*   **Controlo Concorrente:** Utilização de `Threads` Java para gerir o ciclo de vida do sistema (Start/Finish), movimentos dos cilindros e do tapete.
*   **Identificação de Caixas:** Lógica para identificar diferentes tipos de caixas ("Box1", "Box2", "Box3") com base nos sensores.
*   **Lógica de Encaminhamento:** Entrega de cada tipo de caixa para a sua doca específica (Dock 1, Dock 2, Dock End).
*   **Gestão de Emergência:** Implementação de um sistema de STOP/RESUME.
*   **Recolha de Estatísticas:** Contabilização de caixas entregues e rejeitadas em tempo real.

### Tecnologias Utilizadas
*   **Linguagem de Alto Nível:** Java
*   **Linguagem de Baixo Nível:** C/C++ (para a DLL)
*   **Interface Hardware:** Java Native Interface (JNI)