# Simulação da ULA 74181

Este repositório contém a simulação da ULA 74181 utilizando a linguagem SystemVerilog.

## Arquivos

`ula_74181.sv`: Módulo da ULA 74181
`tb_ula_74181.sv`: Testbench para a ULA 74181
`README.md`: Este arquivo de leitura 

## Instruções de Simulação

Compile o módulo da ULA 74181 e o testbench utilizando o comando:

```bash
iverilog -g2012 -o tb_ula_74181 ula_74181.sv tb_ula_74181.sv
```

### Execute o testbench utilizando o comando:

```bash
vvp tb_ula_74181
```

### Visualize os resultados da simulação utilizando o comando:

```bash
gtkwave waveform.vcd
```

## Descrição da ULA 74181

A ULA 74181 é um circuito integrado que realiza operações lógicas e aritméticas. Ela tem 4 entradas de 4 bits cada e 1 saída de 4 bits.

## Controle de Modo

A ULA 74181 tem um controle de modo que permite escolher entre o modo lógico e o modo aritmético. O modo lógico é selecionado quando a entrada mode é 0, e o modo aritmético é selecionado quando a entrada mode é 1.