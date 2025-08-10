# Documentação Adicional: Análise da ULA 74181 e ULA de 8 bits

O objetivo deste documento é analisar e entender o comportamento da implementação da ULA 74181 e sua versão de 8 bits, com foco na verificação da compatibilidade com o datasheet original.

## Comportamento da ULA 74181 (4 bits)

A ULA 74181 possui dois modos de operação controlados pelo sinal M:
- M=0: Modo Aritmético (16 operações aritméticas)
- M=1: Modo Lógico (16 operações lógicas)

### Sinais importantes
- P (Propagate): Indica a condição de propagação de carry
  - No modo lógico (M=1), P é sempre 0
  - No modo aritmético (M=0), P é calculado como: (A0|Y0) & (A1|Y1) & (A2|Y2) & (A3|Y3)
    onde Y são os sinais intermediários da operação
  
- G (Generate): Indica a condição de geração de carry
  - No modo lógico (M=1), G é sempre 1
  - No modo aritmético (M=0), G é calculado pela fórmula: G3 + P3·G2 + P3·P2·G1 + P3·P2·P1·G0
    onde Gn = (An & Yn) e Pn = (An | Yn)

- Carry-out: Comportamento varia conforme o modo e a operação selecionada
  - No modo lógico (M=1), C_out é sempre 0
  - No modo aritmético (M=0), depende da operação específica:
    - Em operações com subtração (S=0000, 0010, 0011, 0110, 0111, 1011), C_out é o complemento do carry real
    - Nas demais operações, C_out é o carry real

### Conjunto de operações
A ULA implementa as 16 funções lógicas e 16 funções aritméticas exatamente como definido no datasheet, incluindo:

Modo Lógico (M = 1)

* S=0000: F = ~A (NOT A)
* S=0001: F = ~(A & B) (NAND)
* S=0010: F = ~A + B
* S=0011: F = 1
* S=0100: F = ~(A + B) (NOR)
* S=0101: F = ~B (NOT B)
* S=0110: F = ~(A ^ B) (XNOR)
* S=0111: F = A + ~B
* S=1000: F = ~A & B
* S=1001: F = A ^ B (XOR)
* S=1010: F = B
* S=1011: F = A + B (OR)
* S=1100: F = 0
* S=1101: F = A + ~B
* S=1110: F = A & B (AND)
* S=1111: F = A

Modo Aritmético (M = 0) Com Carry de Entrada Baixo (Cn = 0)

* S=0000: F = A - 1
* S=0001: F = (A & B) - 1
* S=0010: F = (A & ~B) - 1
* S=0011: F = -1
* S=0100: F = A + (A + ~B)
* S=0101: F = (A & B) + (A + ~B)
* S=0110: F = A - B - 1
* S=0111: F = A + ~B
* S=1000: F = A + (A + B)
* S=1001: F = A + B
* S=1010: F = (A & ~B) + (A + B)
* S=1011: F = A + B
* S=1100: F = A + A
* S=1101: F = (A & B) + A
* S=1110: F = (A & ~B) + A
* S=1111: F = A

Com Carry de Entrada Alto (Cn = 1)

* S=0000: F = A
* S=0001: F = A & B
* S=0010: F = A & ~B
* S=0011: F = 0
* S=0100: F = A + (A + ~B) + 1
* S=0101: F = (A & B) + (A + ~B) + 1
* S=0110: F = A - B
* S=0111: F = (A + ~B) + 1
* S=1000: F = A + (A + B) + 1
* S=1001: F = A + B + 1
* S=1010: F = (A & ~B) + (A + B) + 1
* S=1011: F = (A + B) + 1
* S=1100: F = A + A + 1
* S=1101: F = (A & B) + A + 1
* S=1110: F = (A & ~B) + A + 1
* S=1111: F = A + 1

## Comportamento da ULA de 8 bits

A ULA de 8 bits é implementada conectando duas ULAs 74181 com ripple carry. Essa implementação apresenta algumas particularidades:

1. **Ripple Carry**: O carry-out da ULA menos significativa é conectado ao carry-in da ULA mais significativa, permitindo operações corretas em 8 bits.

2. **Sinais P e G expandidos**: Os sinais P e G são combinados entre as duas ULAs para fornecer informações de propagação e geração para os 8 bits completos:
   - P_8bits = P_lsb & P_msb
   - G_8bits = G_msb | (P_msb & G_lsb)

3. **Detecção de Overflow**: Implementada para operações aritméticas em complemento de dois:
   - Adição (S=1001): Overflow quando os sinais dos operandos são iguais mas o sinal do resultado é diferente
   - Subtração (S=0110): Overflow quando os sinais dos operandos são diferentes e o sinal do resultado é igual ao subtraendo

4. **Comparação de igualdade**: O sinal a_eq_b é ativo quando todos os 8 bits de A são iguais aos 8 bits de B:
   - a_eq_b = a_eq_b_lsb & a_eq_b_msb

## Arquivos de Teste (Testbenches)

Há um único testbench consolidado por ULA, que cobre todas as operações, ambas as polaridades de `c_in` e casos dirigidos:

- **tb_ula_74181.sv**: Testbench completo para a ULA de 4 bits (74181), incluindo verificação de P/G e regras de carry do datasheet.
- **tb_ula_8_bits.sv**: Testbench completo para a ULA de 8 bits, incluindo verificação de ripple carry, `a_eq_b` e overflow.

## Verificação de Compatibilidade

Os testbenches confirmam que ambas as implementações estão em perfeita conformidade com o comportamento esperado:

1. **Para a ULA de 4 bits**: O testbench `tb_ula_74181.sv` (consolidado) confirma 100% de compatibilidade com o datasheet do SN74LS181 nos testes executados em simulação.

2. **Para a ULA de 8 bits**: O testbench `tb_ula_8_bits.sv` valida a implementação cascateada, verificando todas as 32 funções em 8 bits (com `c_in` nas duas polaridades) e casos dirigidos; nas simulações atuais, os testes passam após recompilação.

## Como Executar os Testes

Para executar qualquer um dos testbenches, use os seguintes comandos:

```bash
# Para compilar o testbench da ULA de 4 bits
iverilog -g2012 -o sim/NOME_TESTBENCH.vvp rtl/ula_74181.sv tb/NOME_TESTBENCH.sv

# Para compilar o testbench da ULA de 8 bits
iverilog -g2012 -o sim/NOME_TESTBENCH.vvp rtl/ula_74181.sv rtl/ula_8_bits.sv tb/NOME_TESTBENCH.sv

# Para executar o testbench compilado
vvp sim/NOME_TESTBENCH.vvp

# Para visualizar as formas de onda geradas
gtkwave sim/NOME_TESTBENCH.vcd
```

Por exemplo, para executar o testbench da ULA de 4 bits:

```bash
iverilog -g2012 -o sim/ula_74181.vvp rtl/ula_74181.sv tb/tb_ula_74181.sv
vvp sim/ula_74181.vvp
```

Os resultados dos testes serão exibidos no terminal e os arquivos .vcd serão gerados para análise com GTKWave, se necessário.

## Conclusão

A implementação da ULA 74181 e da ULA de 8 bits construída a partir dela é fiel às especificações originais do componente SN74LS181, incluindo:

1. Todas as 16 funções lógicas e 16 funções aritméticas
2. Correto comportamento dos sinais P e G para carry look-ahead
3. Correto comportamento do carry-out, incluindo a inversão para operações de subtração
4. Ripple carry funcional entre as duas ULAs de 4 bits
5. Detecção precisa de overflow em operações aritméticas de complemento de dois

A abordagem em camadas para testes (básicos, compatibilidade com datasheet e práticos) demonstra uma metodologia de engenharia robusta, garantindo que a implementação seja validada de diferentes perspectivas e com diferentes níveis de rigor.

Estas implementações podem ser utilizadas como base para construção de ALUs mais complexas ou como componentes em sistemas de processamento digital.
