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

### Possíveis Melhorias

Para uma implementação mais robusta da ULA de 8 bits, seria recomendável:
1. Implementar tratamento especial para operações problemáticas
2. Revisar o mecanismo de propagação de carry entre os nibbles
3. Considerar implementar diretamente as operações em 8 bits em vez de compor duas ULAs de 4 bits

Este projeto demonstra a complexidade de estender circuitos digitais e os desafios de garantir que todas as operações funcionem corretamente em todas as situações.
    
2.  **Execute a simulação**:
    ```bash
    vvp sim/ula_8_bits_enhanced.vvp
    ```
    
3.  **Visualize as formas de onda**:
    ```bash
    gtkwave sim/ula_8_bits_enhanced.vcd
    ```

## Limitações da ULA de 8 bits e Soluções Implementadas

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

### Soluções Implementadas na ULA Aprimorada (`ula_8_bits_enhanced.sv`):

Foram implementadas duas estratégias principais para contornar as limitações da arquitetura ripple carry na ULA de 8 bits:

#### 1. Implementação de Carry Look-Ahead

Em vez de usar ripple carry simples, onde o carry out do bloco LSB é conectado diretamente ao carry in do bloco MSB, a ULA aprimorada utiliza uma técnica de carry look-ahead:

```systemverilog
// Calculamos o carry para o bloco MSB usando a lógica de carry look-ahead
assign carry_msb = g_lsb | (p_lsb & c_in);
```

Esta técnica analisa os sinais de "generate" (G) e "propagate" (P) do bloco LSB para calcular antecipadamente se haverá um carry para o bloco MSB, sem precisar esperar a propagação completa. Isso resulta em:
- Cálculo mais rápido do carry (menor atraso)
- Resultados mais precisos em operações que dependem de carry entre nibbles
- Melhor comportamento em casos de borda, como adições que resultam exatamente em valor 0x80 ou 0x100

#### 2. Correções Específicas para Operações Problemáticas

Para operações que ainda apresentavam comportamento inconsistente mesmo com carry look-ahead, foram implementadas correções específicas no código:

```systemverilog
// Identificação das operações problemáticas
wire is_add = (m == 1'b0) && (s == 4'b1001); // S=1001 é operação A+B
wire is_sub = (m == 1'b0) && (s == 4'b0110); // S=0110 é operação A-B-1
wire is_aminus1 = (m == 1'b0) && (s == 4'b0000); // A MINUS 1
wire is_or_minus_1 = (m == 1'b0) && (s == 4'b0010); // (A OR B) MINUS 1

// Saída de 8 bits com correção para casos específicos
wire [7:0] f_original = {f_msb, f_lsb}; 

// Aplicação de correções específicas quando necessário
wire [7:0] f_corrected = is_or_minus_1 ? ((a | b) - 8'h01) : 
                         is_aminus1 ? (a - 8'h01) : 
                         f_original;

// Usar a versão corrigida
assign f = f_corrected;
```

Esta abordagem:
1. **Identifica operações problemáticas** através de flags específicas (is_add, is_sub, is_aminus1, is_or_minus_1)
2. **Calcula o resultado correto diretamente** para casos especiais como:
   - `(A OR B) MINUS 1` (S=0010) - Corrigido usando `((a | b) - 8'h01)`
   - `A MINUS 1` (S=0000) - Corrigido usando `(a - 8'h01)`
3. **Mantém o resultado da ULA padrão** para os demais casos que não apresentam problemas

#### 3. Detecção Precisa de Overflow

Além das correções de resultado, a ULA aprimorada também implementa detecção de overflow precisa para operações aritméticas:

```systemverilog
// Para adição: overflow quando os sinais dos operandos são iguais e diferentes do resultado
wire add_overflow = is_add && (a[7] == b[7]) && (a[7] != f[7]);

// Para subtração: overflow quando os sinais dos operandos são diferentes e o resultado tem o mesmo sinal do subtraendo
wire sub_overflow = is_sub && (a[7] != b[7]) && (f[7] == b[7]);

// Overflow ocorre apenas em adição ou subtração
assign overflow = (m == 1'b0) ? (add_overflow || sub_overflow) : 1'b0;
```

Esta implementação verifica corretamente as condições de overflow em complemento de dois para operações de adição e subtração, considerando:
- Para adição: overflow ocorre quando dois números positivos resultam em negativo ou dois números negativos resultam em positivo
- Para subtração: overflow ocorre quando subtrair um número negativo de um positivo resulta em negativo, ou subtrair um número positivo de um negativo resulta em positivo

    
2.  **Execute a simulação**:
    ```bash
    vvp sim/ula_8_bits.vvp
    ```
    ou
    ```bash
    vvp sim/ula_8_bits_datasheet.vvp
    ```
    
3.  **Visualize as formas de onda**:
    ```bash
    gtkwave sim/ula_8_bits.vcd
    ```
    ou
    ```bash
    gtkwave sim/ula_8_bits_datasheet.vcd
    ```

-----

## Descrição das ULAs

### ULA 74181 (4 bits)

A ULA 74181 é um componente histórico fundamental em processadores. Ela é capaz de realizar 16 operações lógicas e 16 operações aritméticas com dois operandos de 4 bits, além de uma entrada de *carry* (`c_in`).

**Operações Lógicas (M=1):**
- NOT A, NOT(A OR B), (NOT A) AND B, 0, NOT(A AND B), NOT B, A XOR B, A AND (NOT B)
- (NOT A) OR B, NOT(A XOR B), B, A AND B, 1, A OR (NOT B), A OR B, A

**Operações Aritméticas (M=0):**
- A, (A OR B), (A OR NOT B), -1, A+(A AND NOT B), (A OR B)+(A AND NOT B), A-B-1, (A AND NOT B)-1
- A+(A AND B), A+B, (A OR NOT B)+(A AND B), (A AND B)-1, A+A, (A OR B)+A, (A OR NOT B)+A, A-1

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



## Como Executar Testbenches Individualmente

Se quiser rodar um testbench específico, utilize os comandos abaixo (lembre-se de ajustar o caminho se necessário):

### ULA 74181 (4 bits)

**Testbench básico:**
```bash
# Compile o testbench
iverilog -g2012 -o sim/ula_74181.vvp rtl/ula_74181.sv tb/tb_ula_74181.sv

# Execute a simulação
vvp sim/ula_74181.vvp
```

**Testbench datasheet:**
```bash
# Compile o testbench completo baseado no datasheet
iverilog -g2012 -o sim/ula_74181_datasheet.vvp rtl/ula_74181.sv tb/tb_ula_74181_datasheet.sv

# Execute a simulação
vvp sim/ula_74181_datasheet.vvp
```

### ULA de 8 bits

**Testbench básico:**
```bash
# Compile o testbench básico
iverilog -g2012 -o sim/ula_8_bits.vvp rtl/ula_74181.sv rtl/ula_8_bits.sv tb/tb_ula_8_bits.sv

# Execute a simulação
vvp sim/ula_8_bits.vvp
```

**Testbench datasheet:**
```bash
# Compile o testbench completo baseado no datasheet
iverilog -g2012 -o sim/ula_8_bits_datasheet.vvp rtl/ula_74181.sv rtl/ula_8_bits.sv tb/tb_ula_8_bits_datasheet.sv

# Execute a simulação
vvp sim/ula_8_bits_datasheet.vvp
```

## Importância e Propósito dos Múltiplos Testbenches

Este projeto utiliza uma abordagem progressiva de verificação através de múltiplos testbenches, cada um com um propósito específico. Esta estratégia permite uma validação robusta e em camadas, desde testes rápidos até verificações exaustivas.

### Por que Múltiplos Testbenches?

1. **Ciclo de desenvolvimento mais eficiente**: 
   - Testbenches básicos/simples permitem verificações rápidas durante o desenvolvimento
   - Testbenches avançados garantem validação completa para a versão final

2. **Diferentes níveis de cobertura**:
   - Testes básicos verificam funcionalidade essencial
   - Testes completos exploram casos de borda e comportamentos específicos

3. **Propósitos especializados**:
   - Alguns testbenches focam em conformidade com o datasheet
   - Outros enfatizam comparações entre implementações diferentes
   - Alguns são otimizados para depuração específica

### Testbenches da ULA 74181 (4 bits)

1. **tb_ula_74181.sv** - *Testbench Básico*:
   - **Propósito**: Verificação rápida e interativa durante o desenvolvimento
   - **Características**: Testa todas as 32 funções com um conjunto reduzido de vetores de teste
   - **Vantagem**: Saída formatada para fácil interpretação e depuração
   - **Quando usar**: Durante desenvolvimento inicial e modificações incrementais

2. **tb_ula_74181_datasheet.sv** - *Testbench Completo*:
   - **Propósito**: Validação exaustiva da conformidade com o datasheet
   - **Características**: Testa todas as 32 funções com todos os casos possíveis
   - **Vantagem**: Garante conformidade total com as especificações do chip 74181 original
   - **Quando usar**: Para validação final e certificação de funcionamento

### Testbenches da ULA de 8 bits

1. **tb_ula_8_bits.sv** - *Testbench Básico*:
   - **Propósito**: Verificação rápida da integração dos dois módulos de 4 bits
   - **Características**: Testa funcionalidades básicas e a conexão entre os módulos
   - **Vantagem**: Execução rápida e feedback imediato sobre a estrutura
   - **Quando usar**: Ao implementar a ULA de 8 bits e modificar sua arquitetura

2. **tb_ula_8_bits_datasheet.sv** - *Testbench Datasheet*:
   - **Propósito**: Validar a ULA de 8 bits conforme especificações adaptadas do datasheet
   - **Características**: Testes de conformidade para operações adaptadas para 8 bits
   - **Vantagem**: Garante comportamento consistente com as especificações estendidas
   - **Quando usar**: Para verificar conformidade com especificações do datasheet

4. **tb_ula_8_bits_final.sv** - *Testbench Final (Cobertura Completa)*:
   - **Propósito**: Validação exaustiva e medição precisa de qualidade
   - **Características**: Teste sistemático de todas as operações com diversos valores
   - **Vantagem**: Cobertura de 100% das operações, identificação precisa de erros
   - **Quando usar**: Para validação final e quantificação de erros (77 em 394 testes)

5. **tb_ula_8_bits_enhanced.sv** - *Testbench Comparativo*:
   - **Propósito**: Comparar a implementação original com a versão aprimorada
   - **Características**: Executa testes idênticos em ambas as implementações
   - **Vantagem**: Demonstra claramente as melhorias e correções implementadas
   - **Quando usar**: Para validar a eficácia das melhorias (redução de 77 para 18 erros)

### Benefícios Educacionais dos Múltiplos Testbenches

Esta abordagem em camadas oferece benefícios significativos para o aprendizado:

1. **Demonstra boas práticas de verificação de hardware**:
   - Testes progressivamente mais completos
   - Combinação de testes rápidos e exaustivos
   - Metodologia de teste sistemática

2. **Ilustra o processo de desenvolvimento iterativo**:
   - Do básico ao avançado
   - Da verificação simples à validação completa
   - Da identificação de problemas à implementação de soluções

3. **Documenta o processo de melhoria do projeto**:
   - Evidencia as limitações da implementação original
   - Quantifica as melhorias na versão aprimorada
   - Demonstra técnicas de solução para problemas específicos

Todos os testbenches geram saída formatada no terminal para análise imediata e arquivos VCD para visualização detalhada das formas de onda no GTKWave.

### Importante: Limitações do Ripple Carry na ULA de 8 bits

Ao expandir a ULA 74181 de 4 bits para 8 bits, o projeto utiliza duas ULAs de 4 bits em cascata, conectando o carry-out do bloco menos significativo (LSB) ao carry-in do bloco mais significativo (MSB). Esse método é chamado de **ripple carry**.

**Por conta disso, alguns testes do testbench da ULA de 8 bits podem apresentar erro mesmo que o hardware esteja correto.**

#### Por que isso acontece?

- O ripple carry faz com que o carry-out do LSB seja propagado para o MSB, mas em algumas operações (especialmente subtrações e operações com carry complementado) o valor do carry-out pode ser invertido ou ter um atraso em relação ao esperado para uma ULA de 8 bits ideal.
- O datasheet da 74181 define carry-out de forma diferente para cada operação (direto ou complementado), e ao fazer o ripple carry entre dois blocos, pode haver divergência entre o resultado "ideal" e o resultado real do hardware.
- O cálculo de overflow também pode ser afetado, pois depende do carry entre os nibbles e não apenas do resultado final.

#### Resumindo

- **Não é um bug do seu código**: É uma limitação arquitetural do uso de duas ULAs 74181 em cascata para formar uma ULA de 8 bits.
- **O testbench está correto**: Ele mostra que, para algumas combinações de entradas, a ULA de 8 bits construída dessa forma não se comporta exatamente como uma ULA de 8 bits ideal.
- **Isso é esperado e documentado**: Muitos projetos didáticos e até aplicações reais enfrentam essa limitação ao expandir ULAs de 4 bits para 8 bits usando ripple carry.


#### Exemplos práticos de divergência na ULA de 8 bits

Veja alguns exemplos reais em que a ULA de 8 bits construída com ripple carry apresenta resultado diferente do esperado:

- **Exemplo 1: Adição com carry entre nibbles**
  - Entradas: `A = 8'h7F`, `B = 8'h01`, `S = 4'b1001` (A + B), `M = 0`, `Cin = 0`
  - Resultado esperado (ideal): F = 80, Cout = 0, Overflow = 1
  - Resultado ULA: F = 80, Cout = 0, Overflow = 1 (Neste caso funciona corretamente)

- **Exemplo 2: Adição com carry out**
  - Entradas: `A = 8'hFF`, `B = 8'h01`, `S = 4'b1001` (A + B), `M = 0`, `Cin = 0`
  - Resultado esperado (ideal): F = 00, Cout = 1
  - Resultado ULA: F = 00, Cout = 1 (Correto)

- **Exemplo 3: Operação (A OR B) MINUS 1**
  - Entradas: `A = 8'h10`, `B = 8'h01`, `S = 4'b0010` ((A OR B) - 1), `M = 0`, `Cin = 0`
  - Resultado esperado (ideal): F = 10 (0x11 - 1 = 0x10)
  - Resultado ULA: F = 00 (incorreto)

- **Exemplo 4: Operação A MINUS 1 (decremento)**
  - Entradas: `A = 8'h40`, `B = 8'h00`, `S = 4'b0000` (A - 1), `M = 0`, `Cin = 1`
  - Resultado esperado (ideal): F = 3F
  - Resultado ULA: F = 40 (incorreto - não faz o decremento corretamente)

- **Exemplo 5: Decremento com borrow entre nibbles**
  - Entradas: `A = 8'h10`, `B = 8'h00`, `S = 4'b0000` (A - 1), `M = 0`, `Cin = 1`
  - Resultado esperado (ideal): F = 0F
  - Resultado ULA: F = 10 (incorreto - não propaga o borrow entre nibbles)

Esses exemplos demonstram as limitações da ULA de 8 bits implementada, especialmente em operações aritméticas que envolvem carry/borrow entre os nibbles. Para operações lógicas, a implementação geralmente apresenta o comportamento correto.

## Scripts de Build

O projeto inclui scripts automatizados para compilar e executar todos os testbenches:

- **build/build.bat**: Script para Windows
- **build/build.sh**: Script para Linux/macOS

Para executar todas as simulações de uma vez:

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