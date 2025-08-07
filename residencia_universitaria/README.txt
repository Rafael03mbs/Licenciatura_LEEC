# Projeto: Sistema de Gestão de Residência Universitária em C

Este projeto, desenvolvido no âmbito da cadeira de [Nome da Cadeira], é uma aplicação de software para a gestão completa de uma residência de estudantes. O principal foco foi a implementação de uma **arquitetura de software robusta e modular** numa linguagem de baixo nível como o C.

### Arquitetura e Funcionalidades

O sistema foi dividido em múltiplos módulos independentes, cada um com a sua responsabilidade, para garantir a manutenibilidade e escalabilidade do código:
*   **`sistema`:** O módulo central que orquestra as operações.
*   **`estudante`:** Gestão completa do ciclo de vida dos residentes (CRUD - Create, Read, Update, Delete).
*   **`gerente`:** Funcionalidades específicas para o administrador da residência.
*   **`quarto`:** Controlo do estado e alocação dos quartos.
*   **`menu`:** Implementação de uma interface de utilizador complexa baseada em texto.

### Tecnologias Utilizadas
*   **Linguagem:** C
*   **Compilação:** Makefile
*   **Princípios:** Programação Modular e Estruturada.