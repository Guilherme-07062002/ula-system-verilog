```
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

Modo Lógico (M=1):
- S=0000: ~A
- S=0001: ~(A | B)
- S=0010: (~A) & B
- S=0011: 0
- S=0100: ~(A & B)
- S=0101: ~B
- S=0110: A ^ B
- S=0111: A & (~B)
- S=1000: (~A) | B
- S=1001: ~(A ^ B)
- S=1010: B
- S=1011: A & B
- S=1100: 1
- S=1101: A | (~B)
- S=1110: A | B
- S=1111: A

Modo Aritmético (M=0):
- S=0000: A - 1
- S=0001: A + (A|B)
- S=0010: (A|B) - 1
- S=0011: -1
- S=0100: A + (A&B)
- S=0101: (A|B) + (A&B)
- S=0110: A - B - 1
- S=0111: (A&~B) - 1
- S=1000: A + (A&~B)
- S=1001: A + B
- S=1010: (A|~B) + (A&B)
- S=1011: (A&B) - 1
- S=1100: A + A
- S=1101: (A|B) + A
- S=1110: (A|~B) + A
- S=1111: A

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

## Verificação de Compatibilidade

Para verificar a compatibilidade com o datasheet original do 74181, foram implementados testbenches abrangentes:

1. **tb_ula_74181_datasheet.sv**: Testa sistematicamente todas as 32 operações, com diferentes valores de entrada e estados de carry-in, verificando se as saídas (f, c_out, p, g) correspondem exatamente às especificações do datasheet.

2. **tb_ula_8_bits_simples.sv**: Testa casos importantes da ULA de 8 bits, com foco em:
   - Operações aritméticas básicas
   - Casos de overflow
   - Propagação de carry
   - Operações lógicas
   - Verificação de igualdade
   - Sinais P e G

Os testbenches confirmam que a implementação está em conformidade com o datasheet original.

## Conclusão

A implementação da ULA 74181 e da ULA de 8 bits construída a partir dela é fiel às especificações originais do componente SN74LS181, incluindo:

1. Todas as 16 funções lógicas e 16 funções aritméticas
2. Correto comportamento dos sinais P e G para carry look-ahead
3. Correto comportamento do carry-out, incluindo a inversão para operações de subtração
4. Ripple carry funcional entre as duas ULAs de 4 bits
5. Detecção precisa de overflow em operações aritméticas de complemento de dois

Estas implementações podem ser utilizadas como base para construção de ALUs mais complexas ou como componentes em sistemas de processamento digital.
```
