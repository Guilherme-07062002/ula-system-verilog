# ULA 74181 e ULA de 8 bits em SystemVerilog

Este repositório apresenta a implementação e simulação de uma **Unidade Lógica e Aritmética (ULA) de 4 bits, baseada no chip 74181, e sua expansão para uma ULA de 8 bits**. O projeto utiliza a linguagem SystemVerilog para descrição de hardware e as ferramentas Icarus Verilog e GTKWave para simulação e visualização de formas de onda.

## Visão Geral do Projeto

O objetivo deste projeto é implementar e validar uma ULA que possa realizar diversas operações lógicas e aritméticas. A implementação é baseada no chip 74181, que é uma ULA clássica de 4 bits, e foi expandida para criar uma versão de 8 bits através da composição de dois módulos de 4 bits.

## Estrutura do Projeto

O projeto está organizado nas seguintes pastas:

- **rtl/**: Códigos-fonte HDL
- **tb/**: Testbenches
- **sim/**: Arquivos de simulação (VCD, VVP)
- **build/**: Scripts de build automáticos (build.bat, build.sh)

## Implementações das ULAs

### ULA 74181 (4 bits)
**Arquivo: `rtl/ula_74181.sv`**

Esta é a implementação base da ULA de 4 bits que segue as especificações do chip 74181. Suas características incluem:

- **Interface**:
  - Entradas: `a[3:0]`, `b[3:0]` (operandos), `s[3:0]` (seleção da operação), `m` (modo lógico/aritmético), `c_in` (carry de entrada)
  - Saídas: `f[3:0]` (resultado), `a_eq_b` (flag de igualdade), `c_out` (carry de saída), `p` (propagate), `g` (generate)

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
- **Propagação de carry**: Implementa um método de carry look-ahead entre os dois blocos de 4 bits
- **Funcionalidades adicionais**:
  - Detecção de overflow para aritmética em complemento a dois
  - Suporte a operações de 8 bits completas
  - Sinais de carry look-ahead para integração em sistemas maiores

- **Limitações identificadas**: Esta implementação apresenta problemas com algumas operações aritméticas específicas, principalmente aquelas que envolvem carry/borrow entre os nibbles (conjuntos de 4 bits). As simulações detalhadas mostram que algumas operações, especialmente aquelas que envolvem carry/borrow entre os nibbles, podem apresentar resultados inconsistentes.

## Testbenches e Simulação

### Testbenches Implementados

#### ULA 74181 (4 bits)
- **`tb/tb_ula_74181.sv`**: Testbench básico para a ULA 74181 que verifica o funcionamento correto de todas as operações lógicas e aritméticas com diferentes valores de entrada. Este testbench é ideal para uma verificação rápida da implementação base.

- **`tb/tb_ula_74181_datasheet.sv`**: Testbench completo e detalhado que valida todas as 32 funções da ULA 74181 contra as especificações do datasheet original. Verifica todas as combinações possíveis de operandos, carry de entrada e sinais de controle.

#### ULA de 8 bits
- **`tb/tb_ula_8_bits.sv`**: Testbench básico para a ULA de 8 bits que verifica a funcionalidade básica e a integração correta dos dois módulos de 4 bits.

- **`tb/tb_ula_8_bits_datasheet.sv`**: Testbench mais abrangente para a ULA de 8 bits que testa todas as operações seguindo as especificações do datasheet, mas adaptadas para o contexto de 8 bits.

### Arquivos de Simulação (pasta sim/)

A pasta `sim/` contém os arquivos gerados durante a simulação:

- **Arquivos VCD**: Arquivos de Change Dump que registram as alterações nos sinais durante a simulação. Estes podem ser visualizados usando ferramentas como GTKWave para análise detalhada das formas de onda.
  - `ula_74181.vcd`: Resultados da simulação da ULA de 4 bits
  - `ula_74181_datasheet.vcd`: Resultados da simulação da ULA de 4 bits (testbench datasheet)
  - `ula_8_bits.vcd`: Resultados da simulação da ULA de 8 bits básica
  - `ula_8_bits_datasheet.vcd`: Resultados da simulação da ULA de 8 bits (testbench datasheet)

- **Arquivos VVP**: Arquivos executáveis compilados pelo Icarus Verilog, prontos para serem executados para realizar a simulação.

## Resultados das Simulações

### ULA 74181 (4 bits)
- Todas as 32 operações (16 lógicas e 16 aritméticas) funcionam corretamente
- Os sinais de propagate (P) e generate (G) para carry look-ahead são corretamente gerados
- A saída `a_eq_b` detecta corretamente quando os operandos são iguais
- O carry de saída (`c_out`) é manipulado adequadamente para todas as operações

#### Exemplo de Simulação da ULA 74181
Abaixo está um trecho da saída do `tb_ula_74181.sv` mostrando testes no modo aritmético:

```
=== MODO ARITMETICO (M=0) ===
Funcao S=0000:
| ARI | 0000 | 0000 | 0000 |  0  | 1111 |  1  |  1   | 1 | 0 |
| ARI | 0000 | 1111 | 0000 |  0  | 1110 |  0  |  0   | 1 | 1 |

Funcao S=0110 (Subtração A-B-1):
| ARI | 0110 | 0000 | 0000 |  0  | 1111 |  1  |  1   | 1 | 0 |
| ARI | 0110 | 1010 | 0101 |  0  | 0100 |  0  |  0   | 0 | 1 |

Funcao S=1001 (Adição A+B):
| ARI | 1001 | 0000 | 0000 |  0  | 0000 |  1  |  0   | 0 | 0 |
| ARI | 1001 | 1111 | 0000 |  0  | 1111 |  0  |  0   | 1 | 0 |
| ARI | 1001 | 1010 | 0101 |  0  | 1111 |  0  |  0   | 1 | 0 |
```

E também no modo lógico:

```
=== MODO LOGICO (M=1) ===
Funcao S=1000 (Operação AND):
| LOG | 1000 | 0000 | 0000 |  0  | 0000 |  1  |  0   | 0 | 1 |
| LOG | 1000 | 1111 | 0000 |  0  | 0000 |  0  |  0   | 0 | 1 |
| LOG | 1000 | 1111 | 1111 |  1  | 1111 |  1  |  0   | 0 | 1 |

Funcao S=1110 (Operação OR):
| LOG | 1110 | 0000 | 0000 |  0  | 0000 |  1  |  0   | 0 | 1 |
| LOG | 1110 | 1111 | 0000 |  0  | 1111 |  0  |  0   | 0 | 1 |
| LOG | 1110 | 1010 | 0101 |  0  | 1111 |  0  |  0   | 0 | 1 |
```

### ULA de 8 bits
- Funciona corretamente para muitas operações básicas
- Apresenta problemas com certas operações aritméticas, especialmente aquelas que envolvem carry/borrow entre os nibbles
- Os problemas mais comuns ocorrem em operações de subtração e decremento

#### Exemplo de Simulação da ULA de 8 bits
Trecho da saída do `tb_ula_8_bits.sv` mostrando operações:

```
Testando operacao: M=0, S=1001 (Adição A+B)
| 0 | 1001 | 00 | 00 |  0  | 00 | 00 |  0   |    0     |  0  |   0    | OK |
| 0 | 1001 | ff | 00 |  0  | ff | ff |  0   |    0     |  0  |   0    | OK |
| 0 | 1001 | 7f | 01 |  0  | 80 | 80 |  0   |    0     |  1  |   1    | OK | <- Overflow detectado corretamente

Testando operacao: M=0, S=0000 (Decremento A-1)
| 0 | 0000 | 00 | 00 |  0  | ff | 0f |  1   |    0     |  0  |   0    | ERRO |
| 0 | 0000 | 10 | 01 |  0  | 0e | fe |  0   |    1     |  0  |   0    | ERRO | <- Erro no borrow entre nibbles

Testando operacao: M=0, S=0110 (Subtração A-B-1)
| 0 | 0110 | 00 | 00 |  0  | ff | 0f |  1   |    0     |  0  |   0    | ERRO |
| 0 | 0110 | aa | 55 |  0  | 54 | 44 |  0   |    0     |  1  |   1    | ERRO | <- Erro na subtração
```

## Como Executar as Simulações

Para simular o projeto, você precisará ter o **Icarus Verilog** e o **GTKWave** instalados em seu sistema.

### Simulação da ULA 74181 (4 bits)

1. **Compile o módulo e o testbench**:
   ```bash
   # Testbench básico
   iverilog -g2012 -o ula_74181.vvp rtl/ula_74181.sv tb/tb_ula_74181.sv
   
   # Testbench completo baseado no datasheet
   iverilog -g2012 -o ula_74181_datasheet.vvp rtl/ula_74181.sv tb/tb_ula_74181_datasheet.sv
   ```

2. **Execute a simulação**:
   ```bash
   # Testbench básico
   vvp sim/ula_74181.vvp
   
   # Testbench completo
   vvp sim/ula_74181_datasheet.vvp
   ```

3. **Visualize as formas de onda**:
   ```bash
   # Testbench básico
   gtkwave sim/ula_74181.vcd
   
   # Testbench completo
   gtkwave sim/ula_74181_datasheet.vcd
   ```

### Simulação da ULA de 8 bits

1. **Compile os módulos e o testbench**:
   ```bash
   # Testbench básico
   iverilog -g2012 -o sim/ula_8_bits.vvp rtl/ula_74181.sv rtl/ula_8_bits.sv tb/tb_ula_8_bits.sv
   
   # Testbench baseado no datasheet
   iverilog -g2012 -o sim/ula_8_bits_datasheet.vvp rtl/ula_74181.sv rtl/ula_8_bits.sv tb/tb_ula_8_bits_datasheet.sv
   ```

2. **Execute a simulação**:
   ```bash
   # Testbench básico
   vvp sim/ula_8_bits.vvp
   
   # Testbench baseado no datasheet
   vvp sim/ula_8_bits_datasheet.vvp
   ```

3. **Visualize as formas de onda**:
   ```bash
   # Escolha o arquivo .vcd gerado
   gtkwave sim/ula_8_bits.vcd
   gtkwave sim/ula_8_bits_datasheet.vcd
   ```

## Análise e Conclusões

### Limitações da ULA de 8 bits

A ULA de 8 bits foi implementada combinando duas ULAs 74181 de 4 bits, com um mecanismo de propagação de carry. Esta abordagem funciona para muitas operações, mas apresenta limitações em operações que dependem fortemente da propagação correta do carry ou borrow entre os nibbles.

Os testes mostram que a implementação atual tem dificuldades em:
1. Operações de decremento com borrow entre nibbles
2. Operações como `(A OR B) MINUS 1` em certos valores específicos
3. Operações de subtração com carry propagado entre os nibbles

### Operações Problemáticas

As operações mais problemáticas são:
- Operações com código S=0010 (`(A OR B) MINUS 1`)
- Operações com código S=0011 (`MINUS 1` ou operações semelhantes)
- Operações com código S=0101, S=1010, S=1011 e S=1111 em certos valores específicos

## Limitações da ULA de 8 bits

### Problema: Limitações da arquitetura ripple carry

A ULA de 8 bits original é construída cascateando duas ULAs de 4 bits (74181) usando a técnica de **ripple carry**. Isso significa que o carry out da ULA menos significativa (LSB) alimenta o carry in da ULA mais significativa (MSB). Esta arquitetura apresenta limitações em operações específicas, resultando em comportamentos inconsistentes quando comparados às especificações do datasheet.

#### Casos problemáticos identificados:

1. **Operações de adição com carry entre nibbles** (S=1001):
   * Quando a soma dos 4 bits menos significativos gera um carry out
   * Exemplo: 8'h7F + 8'h01 = 8'h80 (correto), mas pode falhar na implementação ripple

2. **Operações de subtração com borrow entre nibbles** (S=0110):
   * Quando a subtração nos bits menos significativos requer um "empréstimo"
   * Exemplo: 8'h10 - 8'h01 = 8'h0F (correto), mas pode falhar na implementação ripple

3. **Operações com carry complementado**:
   * Operações como A-1 (S=0000), (A OR B)-1 (S=0010), etc.
   * O carry complementado pode não ser propagado corretamente entre as ULAs de 4 bits

## Scripts de Build

O projeto inclui scripts automatizados para compilar e executar todos os testbenches de maneira simplificada e visual a partir de um menu interativo:

- **build/build.bat**: Script para Windows
- **build/build.sh**: Script para Linux/macOS

```bash
# No Windows
cd build
.\build.bat

# No Linux/macOS
cd build
chmod +x build.sh  # Se necessário
./build.sh
```

## Documentação Adicional


Documentação detalhada está disponível na pasta `doc/`:

- [**documentacao_adicional.md**](doc/documentacao_adicional.md): Detalhes gerais e funcionalidades das ULAs
- [**arquitetura_tecnica.md**](doc/arquitetura_tecnica.md): Arquitetura técnica e considerações de design
- [**guia_referencia_rapida.md**](doc/guia_referencia_rapida.md): Tabela de referência para todas as operações
- [**guia_simulacao.md**](doc/guia_simulacao.md): Instruções detalhadas para executar simulações
- [**sinais_p_g_explicacao.md**](doc/sinais_p_g_explicacao.md): Explicação técnica dos sinais P e G

-----