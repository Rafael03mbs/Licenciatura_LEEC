# Projeto: Medidor de Consumo de Energia IoT com ESP32

### Contexto Académico
*   **Unidade Curricular:** Instrumentação e Medidas Elétricas
*   **Ano Letivo:** 2023/2024

Este projeto consistiu no desenvolvimento de um sistema ciber-físico completo para a medição, processamento e visualização remota do consumo de energia elétrica de uma carga monofásica.

### Desafio Técnico

O principal desafio foi a integração de três domínios da engenharia:
1.  **Hardware e Eletrónica Analógica:** Dimensionamento de circuitos de condicionamento de sinal com amplificadores operacionais (LM741) para adaptar os sinais dos transdutores de tensão (LEM LV 25-P) e corrente (YHDC SCT-013) para os níveis aceites pelo microcontrolador.
2.  **Firmware e Processamento de Sinal Digital:** Programação do microcontrolador ESP32 em C/C++ (framework Arduino) para ler os sinais analógicos, convertê-los para digital (ADC de 12 bits) e calcular em tempo real os principais parâmetros elétricos (Valor Eficaz, Potência Ativa, Fator de Potência).
3.  **IoT e Cloud:** Implementação da conectividade Wi-Fi no ESP32 para enviar os dados processados para a plataforma cloud **ThingSpeak**, permitindo a monitorização remota e em tempo real.

### Arquitetura do Sistema

*   **Sensores:** Transdutores de tensão e corrente para medir os sinais da rede elétrica.
*   **Condicionamento:** Circuitos somadores com AmpOps para atenuar e aplicar um offset DC aos sinais.
*   **Processamento:** O **ESP32** lê os sinais através de duas portas ADC, realiza os cálculos e gere a comunicação.
*   **Visualização:** Os dados são enviados para um canal **ThingSpeak** e apresentados em gráficos, permitindo a análise do consumo energético.

### Tecnologias Utilizadas
*   **Microcontrolador:** ESP32
*   **Linguagem de Firmware:** C/C++ (Arduino IDE)
*   **Plataforma IoT:** ThingSpeak
*   **Componentes Chave:** LM741, LEM LV 25-P, YHDC SCT-013

### Conteúdo do Repositório
*   `/src`: Contém o código fonte (`.ino`) para o ESP32.
*   `/relatorio.pdf`: O relatório detalhado do projeto.
*   `secrets.h.template`: Ficheiro de exemplo para a configuração das credenciais de Wi-Fi e ThingSpeak.

[Adiciona aqui uma imagem do teu circuito montado e um screenshot do dashboard do ThingSpeak. Podes simplesmente arrastar as imagens para a pasta e usar a sintaxe `![Descrição da Imagem](./nome_da_imagem.png)`]
