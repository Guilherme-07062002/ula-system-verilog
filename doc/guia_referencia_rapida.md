# Guia de Referência Rápida para as ULAs

Este documento fornece uma referência rápida das operações disponíveis nas ULAs implementadas neste projeto.

## ULA 74181 - Tabela de Operações

### Modo Lógico (M=1)

| S[3:0] | Operação | Descrição | Equivalente em C |
|--------|----------|-----------|------------------|
| 0000 | ~A | NOT A | ~A |
| 0001 | ~(A \| B) | NOR | ~(A \| B) |
| 0010 | (~A) & B | NOT A AND B | (~A) & B |
| 0011 | 0 | Zero constante | 0 |
| 0100 | ~(A & B) | NAND | ~(A & B) |
| 0101 | ~B | NOT B | ~B |
| 0110 | A ^ B | XOR | A ^ B |
| 0111 | A & (~B) | A AND NOT B | A & (~B) |
| 1000 | A & B | AND | A & B |
| 1001 | ~(A ^ B) | XNOR | ~(A ^ B) |
| 1010 | B | Passa B | B |
| 1011 | (~A) \| B | NOT A OR B | (~A) \| B |
| 1100 | 1 | Um constante | 1 |
| 1101 | A \| (~B) | A OR NOT B | A \| (~B) |
| 1110 | A \| B | OR | A \| B |
| 1111 | A | Passa A | A |

### Modo Aritmético (M=0)

| S[3:0] | Operação | Descrição | Equivalente em C |
|--------|----------|-----------|------------------|
| 0000 | A − 1 | Decremento de A | A - 1 |
| 0001 | A + (A\|B) | Soma com (A OR B) | A + (A \| B) |
| 0010 | (A\|B) − 1 | Decremento de (A OR B) | (A \| B) - 1 |
| 0011 | −1 | Constante −1 (0xF/0xFF) | -1 |
| 0100 | A + (A&B) | Soma com (A AND B) | A + (A & B) |
| 0101 | (A\|B) + (A&B) | Soma de (OR) com (AND) | (A \| B) + (A & B) |
| 0110 | A − B − 1 | Subtração com borrow | A + (~B) + Cin |
| 0111 | (A&~B) − 1 | Decremento de (A AND ~B) | (A & ~B) - 1 |
| 1000 | A + (A&~B) | Soma com (A AND ~B) | A + (A & ~B) |
| 1001 | A + B | Adição | A + B |
| 1010 | (A\|~B) + (A&B) | Soma composta | (A \| ~B) + (A & B) |
| 1011 | (A&B) − 1 | Decremento de (A AND B) | (A & B) - 1 |
| 1100 | A + A | Dobro de A | A + A |
| 1101 | (A\|B) + A | Soma de (A OR B) com A | (A \| B) + A |
| 1110 | (A\|~B) + A | Soma de (A OR ~B) com A | (A \| ~B) + A |
| 1111 | A | Passagem de A | A |

## Exemplos de Uso Prático

### Operações Aritméticas Comuns
| Operação | Modo | S[3:0] | C_in | Exemplo |
|----------|------|--------|------|---------|
| A + 1 | 0 | 0000 | 0 | A = 5 → F = 6 |
| A + B | 0 | 1001 | 0 | A = 3, B = 4 → F = 7 |
| A - B | 0 | 0110 | 0 | A = 9, B = 5 → F = 4 |
| A - 1 | 0 | 1111 | 0 | A = 10 → F = 9 |
| -B | 0 | 0110 | 0 | A = 0, B = 7 → F = -7 |
| 2×A | 0 | 1100 | 0 | A = 6 → F = 12 |

### Operações Lógicas Comuns
| Operação | Modo | S[3:0] | Exemplo |
|----------|------|--------|---------|
| A AND B | 1 | 1011 | A = 0xA, B = 0xC → F = 0x8 |
| A OR B | 1 | 1110 | A = 0x3, B = 0x5 → F = 0x7 |
| A XOR B | 1 | 0110 | A = 0xF, B = 0x5 → F = 0xA |
| NOT A | 1 | 0000 | A = 0xA → F = 0x5 |
| A NAND B | 1 | 0100 | A = 0xF, B = 0x7 → F = 0x8 |
| A NOR B | 1 | 0001 | A = 0x3, B = 0x4 → F = 0x8 |

## Sinais de Controle Especiais

### Significado dos Sinais P e G
- **P (Propagate)**: Indica se um carry pode ser propagado através de todos os bits
- **G (Generate)**: Indica se um carry será gerado independentemente do carry de entrada

| Modo | P | G | Significado |
|------|---|---|-------------|
| 0 (Aritmético) | 0 | 0 | Nem propaga nem gera carry |
| 0 (Aritmético) | 0 | 1 | Gera carry, mas não propaga |
| 0 (Aritmético) | 1 | 0 | Propaga, mas não gera carry |
| 0 (Aritmético) | 1 | 1 | Gera e propaga carry |
| 1 (Lógico) | 0 | 1 | Valores fixos no modo lógico |

### Detecção de Overflow
Para operações em complemento de dois de 8 bits, o overflow é detectado quando:
- Em adição: operandos com mesmo sinal produzem resultado com sinal oposto
- Em subtração: operandos com sinais diferentes produzem resultado com mesmo sinal do subtraendo

### Verificação de Igualdade (A=B)
O sinal A=B é ativado (nível alto) quando todos os bits correspondentes em A e B são iguais.

## Casos Especiais a Observar

1. **Carry Out em Subtração**: Nas operações de subtração (S=0110), o carry out é o complemento do "borrow".

2. **Overflow**: O sinal de overflow é útil apenas para operações aritméticas em complemento de dois.

3. **Operações com -1**: Várias operações usam o valor -1 (todos os bits em '1'). Este é o complemento de 2 do valor 1 em 4 ou 8 bits.
