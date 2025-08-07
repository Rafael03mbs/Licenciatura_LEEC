# Projeto: Simulação de um Conveyor de Frutas em Python

### Contexto do Projeto

Este projeto é uma implementação alternativa desenvolvida no âmbito da cadeira de Sistemas em Tempo Real. A abordagem aqui foi explorar uma solução puramente baseada em **programação orientada a objetos (OOP) em Python** para simular a lógica de um sistema industrial de separação de frutas.

Enquanto o trabalho principal da unidade curricular se focou na modelação formal com Redes de Petri, este projeto serviu como um exercício prático de prototipagem e desenvolvimento de software, demonstrando como a mesma lógica de negócio pode ser implementada com um paradigma de programação imperativo.

**Nota:** Devido ao desvio da abordagem pedida (Redes de Petri), este trabalho não foi submetido para avaliação formal. No entanto, representa uma solução de software completamente funcional.

### Funcionalidades Implementadas

*   **Modelação Orientada a Objetos:** Criação de classes para representar `Fruta`, `Conveyor`, `Sensor` e `Atuador`, cada uma com os seus próprios atributos e métodos.
*   **Lógica da Simulação:** O script principal (`main.py`) orquestra a simulação, gerando frutas, movendo-as ao longo do tapete e ativando a lógica de sensor/atuador.
*   **Sistema de Separação:** O sensor virtual identifica as propriedades da fruta (ex: tipo) e o atuador virtual decide a ação a tomar (ex: desviar para a caixa A ou B).

### Tecnologias Utilizadas

*   **Linguagem:** Python
*   **Padrão de Desenho:** Programação Orientada a Objetos (OOP)

### Como Executar

Para correr a simulação, execute o script principal a partir do terminal:
```bash
python main.py
