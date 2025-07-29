# Simulação da ULA 74181

Este repositório contém a simulação da ULA 74181 utilizando a linguagem SystemVerilog.

## Arquivos

ula_74181.sv: Módulo da ULA 74181
tb_ula_74181.sv: Testbench para a ULA 74181
README.md: Este arquivo

## Instruções de Simulação

Compile o módulo da ULA 74181 e o testbench utilizando o comando:
iverilog -g2012 -o tb_ula_74181 ula_74181.sv tb_ula_74181.sv

### Execute o testbench utilizando o comando:

```bash
vvp tb_ula_74181
```

### Visualize os resultados da simulação utilizando o comando:

```bash
gtkwave waveform.vcd
```

## Observações

O testbench atualmente testa apenas alguns casos de teste para a ULA 74181. É recomendável adicionar mais casos de teste para garantir a correta funcionalidade da ULA.

O módulo da ULA 74181 ainda não está completo e precisa ser implementado.