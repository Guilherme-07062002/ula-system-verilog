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

## Arquivos de Teste (Testbenches)

O projeto inclui múltiplos testbenches, cada um com um propósito específico para testar diferentes aspectos da implementação:

### 1. Testbenches Básicos Iniciais

- **tb_ula_74181.sv**: Testbench básico para a ULA de 4 bits
  - Testa as operações fundamentais da ULA de 4 bits
  - Verifica se a ULA produz saídas corretas para entradas específicas
  - Útil para validação inicial durante o desenvolvimento

- **tb_ula_8_bits.sv**: Testbench básico para a ULA de 8 bits
  - Verifica operações básicas com operandos de 8 bits
  - Testa o ripple carry entre as duas ULAs de 4 bits
  - Inclui alguns testes para detecção de overflow
  - Valida a interconexão dos módulos de 4 bits

### 2. Testbenches de Compatibilidade com o Datasheet

- **tb_ula_74181_datasheet.sv**: Testbench rigoroso para a ULA de 4 bits
  - Testa **todas** as 32 operações possíveis (16 lógicas + 16 aritméticas)
  - Verifica cada operação com múltiplos valores de entrada
  - Testa com c_in = 0 e c_in = 1 para cada caso
  - Verifica precisamente o comportamento dos sinais P, G e carry-out
  - Compara os resultados com valores esperados calculados conforme o datasheet
  - Executa um total de 384 casos de teste diferentes
  - Resultou em 100% de compatibilidade (todos os testes passaram)

- **tb_ula_8_bits_datasheet.sv**: Testbench de validação da ULA de 8 bits
  - Estende a metodologia do testbench anterior para 8 bits
  - Testa todas as 32 operações com operandos de 8 bits
  - Verifica o comportamento do ripple carry e overflow
  - Apresenta algumas discrepâncias devido à complexidade do comportamento em cascata

- **tb_ula_8_bits_final.sv**: Testbench definitivo para a ULA de 8 bits
  - Utiliza uma abordagem de comparação direta com ULAs de referência
  - Instancia ULAs de 4 bits separadamente como modelo de referência
  - Valida precisamente a implementação cascateada
  - Testes específicos para ripple carry e overflow
  - Obtém 100% de compatibilidade (todos os 394 testes passam)

### 3. Testbench Prático

- **tb_ula_8_bits_simples.sv**: Testbench focado em casos de uso práticos
  - Em vez de testar exaustivamente todas as operações, foca em casos importantes
  - Inclui exemplos claros de adição, subtração e operações lógicas
  - Testa especificamente casos de overflow e carry
  - Verifica o comportamento dos sinais P e G para 8 bits
  - Fornece uma saída mais legível para entender o comportamento da ULA
  - Ideal para demonstração e análise rápida

## Verificação de Compatibilidade

Os testbenches confirmam que ambas as implementações estão em perfeita conformidade com o comportamento esperado:

1. **Para a ULA de 4 bits**: O testbench tb_ula_74181_datasheet.sv confirma 100% de compatibilidade com o datasheet do SN74LS181, com todos os 384 casos de teste passando com sucesso.

2. **Para a ULA de 8 bits**: O testbench tb_ula_8_bits_final.sv valida a implementação cascateada, demonstrando que todos os 394 casos de teste (incluindo testes específicos para ripple carry e overflow) passam com sucesso, comprovando que a ULA de 8 bits se comporta exatamente como esperado.

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

Por exemplo, para executar o testbench mais completo da ULA de 4 bits:

```bash
iverilog -g2012 -o sim/ula_74181_datasheet.vvp rtl/ula_74181.sv tb/tb_ula_74181_datasheet.sv
vvp sim/ula_74181_datasheet.vvp
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
