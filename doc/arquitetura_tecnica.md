# Arquitetura Técnica da ULA 74181 e ULA 8 bits

Link para o datasheet: [ULA 74181 Datasheet](https://www.ti.com/lit/ds/symlink/sn54ls181.pdf)

Este documento apresenta detalhes técnicos sobre a implementação da ULA 74181 e da ULA de 8 bits, incluindo diagramas de blocos, fluxo de sinais e considerações de design.

## Arquitetura da ULA 74181 (4 bits)

### Diagrama de Blocos

```
         +-----------------------------------+
         |            ULA 74181              |
         |                                   |
A[3:0] ->|                                   |-> F[3:0]
B[3:0] ->|                                   |
         |                                   |
S[3:0] ->|                                   |-> A=B
M ------>|                                   |
         |                                   |-> C_out
C_in --->|                                   |
         |                                   |-> P (Propagate)
         |                                   |
         |                                   |-> G (Generate)
         +-----------------------------------+
```

### Fluxo de Sinais Internos

1. **Geração dos sinais intermediários Y**:
   - No modo lógico (M=1): Y é calculado diretamente das operações lógicas entre A e B
   - No modo aritmético (M=0): Y depende dos sinais S e contribui para o cálculo do carry

2. **Cálculo de P e G**:
   - P (Propagate) = P3 & P2 & P1 & P0
   - G (Generate) = G3 + (P3 & G2) + (P3 & P2 & G1) + (P3 & P2 & P1 & G0)

3. **Cálculo do Carry out (visão da implementação)**:
    - O módulo 4 bits expõe dois sinais relacionados a carry:
       - `c_out` (compatível com a convenção do 74181, incluindo complementação em funções específicas do modo aritmético)
       - `c_ripple` (carry “verdadeiro” da soma aritmética, usado para cascateamento)
    - No modo lógico (M=1), `c_out` é mantido em 0 (carry irrelevante no modo lógico) e `c_ripple` é 0.
    - No modo aritmético (M=0), `c_out` segue a convenção do datasheet e `c_ripple` reflete o bit de carry da soma.

## Arquitetura da ULA 8 bits

### Diagrama de Blocos - ULA 8 bits (Cascata de duas ULA 74181)

```
                 +----------------+
                 |                |
A[3:0] --------->|                |
B[3:0] --------->|   ULA 74181    |-----> F[3:0]
S[3:0] --------->|     (LSB)      |
M -------------->|                |-----> A=B_LSB
C_in ----------->|                |
                 |                |-----> P_LSB
                 |                |-----> G_LSB
                 +----------------+
                        |
                        | c_ripple (LSB)
                        v
                 +----------------+
                 |                |
A[7:4] --------->|                |
B[7:4] --------->|   ULA 74181    |-----> F[7:4]
S[3:0] --------->|     (MSB)      |
M -------------->|                |-----> A=B_MSB
                 |                |
                 |                |-----> P_MSB
                 |                |-----> G_MSB
                 +----------------+
                        |
                        | C_out (MSB) = C_out final
                        v
```

### Considerações Importantes de Design

1. **Ripple Carry**: O atraso de propagação do carry é um fator crucial para o desempenho da ULA de 8 bits. Com o método de ripple carry, o carry-out da ULA LSB deve se estabilizar antes que a ULA MSB possa produzir resultados finais corretos. Isso impõe uma limitação de velocidade.

2. **Detecção de Overflow**: Para operações aritméticas em complemento de dois na ULA de 8 bits, a implementação detecta overflow para adição (S=1001) e subtração (S=0110) usando as regras clássicas de sinal (operandos e resultado), e zera no modo lógico. Outras funções não acusam overflow.

3. **Expandindo os Sinais P e G**:
   - P para 8 bits = P_LSB & P_MSB
   - G para 8 bits = G_MSB | (P_MSB & G_LSB)

4. **Comparação de Igualdade**:
   - A=B para 8 bits = (A=B)_LSB & (A=B)_MSB

## Comportamento de Carry em Operações de Subtração

Um aspecto importante a considerar é o tratamento de carry em operações de subtração. No 74181, algumas operações de subtração têm o carry invertido para manter a compatibilidade com o datasheet original:

1. Em um subconjunto específico de funções do modo aritmético (S ∈ {0000, 0010, 0011, 0110, 0111, 1011}), o carry-out reportado (`c_out`) é o complemento do carry real, conforme a convenção da 74181.
2. Nas demais funções aritméticas (por exemplo, S=1001 A+B), `c_out` reporta o carry real.

## Otimizações Possíveis

Para uma implementação mais eficiente, poderiam ser consideradas as seguintes melhorias:

1. **Carry Look-Ahead**: Substituir o ripple carry por uma lógica de carry look-ahead completa, utilizando os sinais P e G gerados por cada ULA 74181 para calcular os carries de forma paralela.

2. **Pipelining**: Adicionar registradores entre os estágios para permitir maior frequência de operação.

3. **Parametrização**: Tornar a largura de bits parametrizável, permitindo a criação de ULAs com diferentes tamanhos.

## Verificação e Validação

As duas implementações foram verificadas usando os seguintes métodos:

1. **Teste unitário**: Validação de cada operação individualmente
2. **Verificação contra datasheet**: Comparação com tabelas de verdade do datasheet
3. **Testes de borda**: Verificação com valores extremos (todos 0s, todos 1s)
4. **Cobertura funcional**: Garantir que todos os modos e operações sejam testados
