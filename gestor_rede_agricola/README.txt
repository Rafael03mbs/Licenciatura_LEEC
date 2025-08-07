# Projeto: Gestor de Rede Agrícola Sustentável com Prolog

Este projeto, desenvolvido para a cadeira de Modelação de Dados em Engenharia, consiste num sistema inteligente para modelar e gerir uma rede agrícola complexa, composta por produtores, quintas, sensores e distribuidores.

### Desafio Técnico

O principal desafio foi afastar-se da programação imperativa tradicional para adotar um paradigma de **programação lógica**. A solução foi desenvolvida através da criação de uma **base de conhecimento** e um **motor de inferência** em **Prolog**, capaz de responder a questões complexas sobre o estado da rede e otimizar rotas de distribuição com base em múltiplos critérios (distância, impacto ambiental, procura).


### Funcionalidades Implementadas
*   Modelação da rede (quintas, sensores, ligações) através de factos em Prolog.
*   Definição de regras de inferência para responder a queries complexas (ex: "Listar transportadoras ideais para uma rota com base em 5 critérios").
*   Determinação de rotas ótimas (mais curta, menor impacto ambiental, etc.).
*   Criação de um servidor Prolog que expõe as suas funcionalidades a outras aplicações.

### Tecnologias Utilizadas
*   **Linguagem de Programação Lógica:** SWI-Prolog

