# Sinais P e G: Geração e Propagação de Carry

Este documento técnico explica em detalhes os sinais P (Propagate) e G (Generate) da ULA 74181, que são fundamentais para operações de carry look-ahead em circuitos aritméticos de alta performance.

## 1. Introdução aos Sinais P e G

Os sinais P (Propagate) e G (Generate) são sinais de controle que permitem prever a geração e propagação de carries antes que eles se propaguem sequencialmente através de todos os bits. Estes sinais são essenciais para implementações de circuitos aritméticos de alta velocidade.

## 2. Definições Formais

### Sinal P (Propagate)
- **Significado**: Indica que um carry de entrada pode ser "propagado" através de todos os bits da ULA.
- **Condição**: P=1 significa que, se um carry entrar no bit menos significativo, ele se propagará até o bit mais significativo.
- **Cálculo (nível de bit)**: Pi = Ai ⊕ Bi (XOR) ou Pi = Ai + Bi (OR) dependendo da implementação

### Sinal G (Generate)
- **Significado**: Indica que um carry será "gerado" independentemente do valor do carry de entrada.
- **Condição**: G=1 significa que a operação produzirá um carry out mesmo se o carry in for 0.
- **Cálculo (nível de bit)**: Gi = Ai · Bi (AND)

## 3. Implementação na ULA 74181

Na ULA 74181, os sinais P e G são calculados de formas diferentes dependendo do modo de operação:

### Modo Aritmético (M=0)
- **P**: Calculado como P = P3 · P2 · P1 · P0, onde Pi = (Ai | Yi) para cada bit i
- **G**: Calculado como G = G3 + (P3 · G2) + (P3 · P2 · G1) + (P3 · P2 · P1 · G0), onde Gi = (Ai & Yi) para cada bit i
- Os valores Yi dependem da operação selecionada por S[3:0]

### Modo Lógico (M=1)
- **P**: Fixado em P = 0 (não há propagação de carry em operações lógicas)
- **G**: Fixado em G = 1 (carry sempre gerado para manter compatibilidade com o datasheet)

## 4. Cálculo do Carry Out Usando P e G

O carry-out (C_out) pode ser calculado diretamente a partir dos sinais P e G, sem esperar pela propagação sequencial através dos bits:

```
C_out = G + (P · C_in)
```

Onde:
- G: Sinal Generate da ULA
- P: Sinal Propagate da ULA
- C_in: Carry de entrada

Esta fórmula permite prever o carry-out imediatamente, sem esperar pela propagação sequencial.

## 5. Expansão para 8 bits

Na ULA de 8 bits, os sinais P e G são expandidos para abranger todos os 8 bits:

```
P_8bits = P_lsb · P_msb
G_8bits = G_msb + (P_msb · G_lsb)
```

Onde:
- P_lsb, G_lsb: Sinais da ULA dos 4 bits menos significativos
- P_msb, G_msb: Sinais da ULA dos 4 bits mais significativos

## 6. Exemplos Práticos

### Exemplo 1: Adição com P=1, G=0
```
A = 0101, B = 1010
Operação: Adição (S=1001, M=0)

Para cada bit i:
Pi = (Ai | Yi) = 1 (para todos os bits)
Gi = (Ai & Yi) = 0 (para todos os bits)

Portanto:
P = 1 · 1 · 1 · 1 = 1
G = 0 + (1 · 0) + (1 · 1 · 0) + (1 · 1 · 1 · 0) = 0

Se C_in = 0: C_out = G + (P · C_in) = 0 + (1 · 0) = 0
Se C_in = 1: C_out = G + (P · C_in) = 0 + (1 · 1) = 1
```

### Exemplo 2: Adição com P=0, G=1
```
A = 1111, B = 0001
Operação: Adição (S=1001, M=0)

Para o bit 3:
P3 = (A3 | Y3) = 1
G3 = (A3 & Y3) = 1

Portanto:
P = 1 · 1 · 1 · 0 = 0 (assumindo que P0 = 0)
G = 1 + ... = 1

C_out = G + (P · C_in) = 1 + (0 · C_in) = 1 (independente de C_in)
```

## 7. Aplicações em Circuitos de Carry Look-Ahead

Os sinais P e G são essenciais para construir circuitos de carry look-ahead, que podem calcular todos os carries em paralelo em vez de sequencialmente, resultando em:

1. **Maior velocidade**: Eliminação do atraso de ripple carry
2. **Previsibilidade**: Tempo de propagação constante independente do número de bits
3. **Escalabilidade**: Facilidade para construir unidades aritméticas de grande largura

## 8. Verificação nos Testbenches

Os testbenches incluem casos específicos para validar o comportamento dos sinais P e G:

```systemverilog
// Caso 1: P=1, G=0 (A=0101, B=1010)
a = 4'b0101;
b = 4'b1010;
#10;
$display("Caso P=1, G=0: A=%04b, B=%04b => P=%b, G=%b (esperado: P=1, G=0)", a, b, p, g);

// Caso 2: P=0, G=1 (A=1111, B=1111)
a = 4'b1111;
b = 4'b1111;
#10;
$display("Caso P=0, G=1: A=%04b, B=%04b => P=%b, G=%b (esperado: P=0, G=1)", a, b, p, g);
```

## 9. Conclusão

Os sinais P e G são uma parte fundamental da ULA 74181 e essenciais para o design de circuitos aritméticos de alta performance. Eles permitem a implementação de lógica de carry look-ahead que supera as limitações de velocidade dos circuitos de ripple carry tradicionais. Na ULA de 8 bits, esses sinais são combinados para fornecer informações de propagação e geração para os 8 bits completos, embora a implementação atual ainda use ripple carry entre as duas ULAs de 4 bits.
