# ULA 74181 e ULA de 8 bits em SystemVerilog

Este repositório apresenta a implementação e simulação de uma **Unidade Lógica e Aritmética (ULA) de 4 bits, baseada no chip 74181, e sua expansão para uma ULA de 8 bits**. O projeto utiliza a linguagem SystemVerilog para descrição de hardware e as ferramentas Icarus Verilog e GTKWave para simulação e visualização de formas de onda.

## Estrutura do Projeto

O projeto é dividido em duas partes principais, cada uma com seu módulo de ULA e seu respectivo *testbench*.

### Parte 1: ULA 74181 (4 bits)

  * `ula_74181.sv`: Contém a descrição em SystemVerilog da ULA 74181 de 4 bits, implementando as 16 operações lógicas e 16 operações aritméticas conforme especificado no datasheet original do componente.
  * `tb_ula_74181.sv`: O *testbench* para a `ula_74181.sv`. Ele varre todas as 32 funções e aplica um conjunto significativo de vetores de teste para verificar o comportamento da ULA. Gera saída no terminal e um arquivo VCD (`ula_74181.vcd`) para análise de formas de onda.

### Parte 2: ULA de 8 bits

  * `ula_8_bits.sv`: Módulo principal que implementa uma ULA de 8 bits. Ele faz a **composição** de duas instâncias da `ula_74181.sv` utilizando o método **ripple carry** para conectar os bits menos significativos aos mais significativos.
  * `tb_ula_8_bits.sv`: O *testbench* para a `ula_8_bits.sv`. Similar ao *testbench* de 4 bits, ele testa todas as funções com operandos de 8 bits, gerando saída no terminal e um arquivo VCD (`ula_8_bits.vcd`).

-----

## Como Simular

Para simular o projeto, você precisará ter o **Icarus Verilog** e o **GTKWave** instalados em seu sistema.

### Simulação da ULA 74181 (4 bits)

1.  **Compile o módulo e o testbench**:
    ```bash
    iverilog -g2012 -o ula_74181.vvp ula_74181.sv tb_ula_74181.sv
    ```
2.  **Execute a simulação**:
    ```bash
    vvp ula_74181.vvp
    ```
    Isso imprimirá os resultados da simulação no terminal e gerará o arquivo `ula_74181.vcd`.
3.  **Visualize as formas de onda**:
    ```bash
    gtkwave ula_74181.vcd
    ```

### Simulação da ULA de 8 bits

1.  **Compile os módulos e o testbench**:
      * Note que o módulo `ula_8_bits.sv` instancia `ula_74181.sv`, portanto, ambos devem ser incluídos na compilação.
    <!-- end list -->
    ```bash
    iverilog -g2012 -o ula_8_bits.vvp ula_74181.sv ula_8_bits.sv tb_ula_8_bits.sv
    ```
2.  **Execute a simulação**:
    ```bash
    vvp ula_8_bits.vvp
    ```
    Isso imprimirá os resultados da simulação no terminal e gerará o arquivo `ula_8_bits.vcd`.
3.  **Visualize as formas de onda**:
    ```bash
    gtkwave ula_8_bits.vcd
    ```

-----

## Descrição das ULAs

### ULA 74181 (4 bits)

A ULA 74181 é um componente histórico fundamental em processadores. Ela é capaz de realizar 16 operações lógicas e 16 operações aritméticas com dois operandos de 4 bits, além de uma entrada de *carry* (`c_in`).

  * **Entradas**:
      * `a`, `b`: Operandos de dados de 4 bits.
      * `s`: Entrada de seleção de função (4 bits).
      * `m`: Controle de modo (0 para Aritmética, 1 para Lógica).
      * `c_in`: Entrada de *carry* (Carry In).
  * **Saídas**:
      * `f`: Saída principal da função (4 bits).
      * `a_eq_b`: Saída do comparador (ativa em nível alto quando `a == b`).
      * `c_out`: Saída de *carry* (Carry Out).

### ULA de 8 bits

A ULA de 8 bits é construída a partir de duas instâncias da `ula_74181.sv`. O *carry out* da ULA responsável pelos 4 bits menos significativos (`LSB`) é conectado ao *carry in* da ULA responsável pelos 4 bits mais significativos (`MSB`), configurando uma arquitetura **ripple carry**. As entradas de controle (`s` e `m`) são conectadas em paralelo a ambas as ULAs de 4 bits.

  * **Entradas**:
      * `a`, `b`: Operandos de dados de 8 bits.
      * `s`: Entrada de seleção de função (4 bits).
      * `m`: Controle de modo (0 para Aritmética, 1 para Lógica).
      * `c_in`: Entrada de *carry* (Carry In).
  * **Saídas**:
      * `f`: Saída principal da função (8 bits).
      * `a_eq_b`: Saída do comparador (ativa em nível alto quando `a == b`).
      * `c_out`: Saída de *carry* (Carry Out).

-----