# ULA 74181 e ULA de 8 bits em SystemVerilog

Este repositório apresenta a implementação e simulação de uma **Unidade Lógica e Aritmética (ULA) de 4 bits, baseada no chip 74181, e sua expansão para uma ULA de 8 bits**. O projeto utiliza a linguagem SystemVerilog para descrição de hardware e as ferramentas Icarus Verilog e GTKWave para simulação e visualização de formas de onda.

## Visão Geral do Projeto

O objetivo deste projeto é implementar e validar uma ULA que possa realizar diversas operações lógicas e aritméticas. A implementação é baseada no chip 74181, que é uma ULA clássica de 4 bits, e foi expandida para criar uma versão de 8 bits através da composição de dois módulos de 4 bits.

## Estrutura do Projeto

O projeto está organizado nas seguintes pastas:

- **build/**: Scripts de build automáticos (build.bat, build.sh)
- **doc/**: Documentação adicional
- **ip/**: Blocos reutilizáveis
- **rtl/**: Códigos-fonte HDL
- **sim/**: Arquivos de simulação (VCD, VVP)
- **tb/**: Testbenches

## Implementações das ULAs

### ULA 74181 (4 bits)
**Arquivo: `rtl/ula_74181.sv`**

Esta é a implementação base da ULA de 4 bits que segue as especificações do chip 74181. Suas características incluem:

- **Interface**:
  - Entradas: `a[3:0]`, `b[3:0]` (operandos), `s[3:0]` (seleção da operação), `m` (modo lógico/aritmético), `c_in` (carry de entrada)
  - Saídas: `f[3:0]` (resultado), `a_eq_b` (flag de igualdade), `c_out` (carry de saída), `p` (propagate), `g` (generate), `c_ripple` (carry "verdadeiro" para cascateamento)

- **Funcionalidades**:
  - **Modo Lógico (m=1)**: Implementa 16 operações lógicas diferentes (NOR, NAND, XOR, etc.)
  - **Modo Aritmético (m=0)**: Implementa 16 operações aritméticas (soma, subtração, incremento, etc.)
  - **Suporte a carry look-ahead** através dos sinais `p` e `g`
  - **Detecção de igualdade** entre operandos (`a_eq_b`)

- **Comportamento**: A ULA 74181 funciona corretamente para todas as operações conforme o datasheet original, manipulando adequadamente o carry para cada operação específica.

### ULA de 8 bits
**Arquivo: `rtl/ula_8_bits.sv`**

Esta implementação combina duas instâncias da ULA 74181 para criar uma ULA de 8 bits:

- **Arquitetura**: Utiliza duas ULAs de 4 bits, uma para os bits menos significativos (LSB) e outra para os mais significativos (MSB)
- **Propagação de carry**: Implementa ripple carry entre os blocos de 4 bits (c_ripple da ULA LSB alimenta o c_in da ULA MSB). Os sinais P/G são calculados e expostos para depuração/integração, mas não são usados para carry look-ahead nesta versão
- **Funcionalidades adicionais**:
  - Detecção de overflow para aritmética em complemento a dois
  - Suporte a operações de 8 bits completas
  - Sinais P/G agregados de 8 bits (úteis para integração futura com carry look-ahead)

## Estado atual da implementação

- A ULA 74181 (4 bits) implementa corretamente as 16 operações lógicas e 16 aritméticas do datasheet; c_out segue a convenção da 74181 (carry complementado para um subconjunto de funções no modo aritmético). P/G e a_eq_b operam conforme esperado.
- A ULA de 8 bits (ripple carry) foi validada com varredura completa (m, s, c_in) e vetores representativos; os testbenches atuais reportam 100% de aprovação após recompilação.

## Testbenches e Simulação

Há um testbench consolidado por ULA cobrindo operações, ambas as polaridades de `c_in` e casos dirigidos:

- `tb/tb_ula_74181.sv` (4 bits)
- `tb/tb_ula_8_bits.sv` (8 bits)

Para executar as simulações, use os scripts em `build/` (Windows e Linux/macOS) ou siga o guia detalhado em `doc/guia_simulacao.md`.

## Resultados das Simulações

### ULA 74181 (4 bits)
- Todas as 32 operações (16 lógicas e 16 aritméticas) funcionam corretamente
- Os sinais de propagate (P) e generate (G) para carry look-ahead são corretamente gerados
- A saída `a_eq_b` detecta corretamente quando os operandos são iguais
- O carry de saída (`c_out`) é manipulado adequadamente para todas as operações

### ULA de 8 bits
- Validada com varredura de modos (m), funções (s) e c_in, além de casos dirigidos (carry entre nibbles e overflow); os testbenches atuais reportam todos os casos aprovados após recompilação


## Como Executar

Use:

- Windows: `build/build.bat`
- Linux/macOS: `build/build.sh`

Detalhes e execução manual (comandos iverilog/vvp/gtkwave) estão em `doc/guia_simulacao.md`.

## Análise e Conclusões

A arquitetura de 8 bits usa ripple carry entre nibbles. Apesar de os sinais P/G de 8 bits serem expostos para depuração/integração futura, o caminho de carry atual é por ripple. As simulações (Icarus Verilog) confirmam compatibilidade funcional com o datasheet para 4 bits e a composição correta para 8 bits nas baterias de testes incluídas.

## Documentação Adicional

Documentação detalhada está disponível na pasta `doc/`:

- [**documentacao_adicional.md**](doc/documentacao_adicional.md): Detalhes gerais e funcionalidades das ULAs
- [**arquitetura_tecnica.md**](doc/arquitetura_tecnica.md): Arquitetura técnica e considerações de design
- [**guia_simulacao.md**](doc/guia_simulacao.md): Instruções detalhadas para executar simulações

-----