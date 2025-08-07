# Projeto: Estufa Inteligente com Modelação baseada em Frames

Este projeto, também desenvolvido para Modelação de Dados em Engenharia, consistiu em modelar e implementar uma Estufa Inteligente para o cultivo de frutas, utilizando paradigmas avançados de representação de conhecimento.

### Desafio Técnico

O desafio foi modelar um sistema complexo usando uma **estrutura de Frames**, implementada em **Prolog** com a biblioteca **GOLOG**. Este paradigma permite representar o conhecimento através de objetos (frames), seus atributos (slots), herança e comportamentos reativos (demónios) que disparam automaticamente quando certas condições são cumpridas.

O projeto também incluiu a modelação visual do sistema utilizando **UML** (Diagrama de Classes e Diagrama de Sequência).

### Funcionalidades Principais
*   Modelação da estufa, sensores e atuadores usando Frames com slots e relações de herança.
*   Implementação de **demónios** para controlo automático de atuadores (ex: `rega` ativa se `soil.humidity < 40`).
*   Lógica adaptativa que ajusta os níveis de climatização com base no número de ocupantes na estufa.
*   Geração automática de alarmes para eventos críticos.
*   Simulação do sistema e interação via menu de utilizador.

### Tecnologias Utilizadas
*   **Linguagem de Programação Lógica:** Prolog
*   **Biblioteca de Conhecimento:** GOLOG (Frames)
*   **Linguagem de Modelação Visual:** UML