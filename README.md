# ULA 74181 e ULA de 8 bits em SystemVerilog

Este repositório apresenta a implementação e simulação de uma **Unidade Lógica e Aritmética (ULA) de 4 bits, baseada no chip 74181, e sua expansão para uma ULA de 8 bits**. O projeto utiliza a linguagem SystemVerilog para descrição de hardware e as ferramentas Icarus Verilog e GTKWave para simulação e visualização de formas de onda.

## Estrutura do Projeto

O projeto está organizado nas seguintes pastas:

- **rtl/**: Códigos-fonte HDL
- **tb/**: Testbenches
- **sim/**: Arquivos de simulação (scripts, waves)
- **ip/**: Blocos reutilizáveis (IP cores)
- **doc/**: Documentação (PDFs, Markdown, imagens)
- **build/**: Scripts de build automáticos (build.bat, build.sh)

### Códigos-fonte (pasta rtl/)

  * `rtl/ula_74181.sv`: Contém a descrição em SystemVerilog da ULA 74181 de 4 bits, implementando as 16 operações lógicas e 16 operações aritméticas conforme especificado no datasheet original do componente.
  * `rtl/ula_8_bits.sv`: Módulo principal que implementa uma ULA de 8 bits. Ele faz a **composição** de duas instâncias da `ula_74181.sv` utilizando o método **ripple carry** para conectar os bits menos significativos aos mais significativos.

### Testbenches (pasta tb/)

  * `tb/tb_ula_74181.sv`: Testbench básico para a ULA 74181.
  * `tb/tb_ula_74181_datasheet.sv`: Testbench completo que valida todas as 32 funções contra as especificações do datasheet.
  * `tb/tb_ula_8_bits.sv`: Testbench básico para a ULA de 8 bits.
  * `tb/tb_ula_8_bits_datasheet.sv`: Testbench abrangente para ULA de 8 bits.
  * `tb/tb_ula_8_bits_final.sv`: Testbench com 100% de cobertura para a ULA de 8 bits.
  * `tb/tb_ula_8_bits_simples.sv`: Testbench simples para testes rápidos.

### Arquivos de simulação (pasta sim/)

  * Arquivos VCD para análise de formas de onda
  * Arquivos VVP compilados para execução das simulações

-----

## Como Simular

Para simular o projeto, você precisará ter o **Icarus Verilog** e o **GTKWave** instalados em seu sistema.

### Simulação da ULA 74181 (4 bits)

1.  **Compile o módulo e o testbench**:
    ```bash
    # Método manual
    iverilog -g2012 -o sim/ula_74181.vvp rtl/ula_74181.sv tb/tb_ula_74181.sv
    ```
    
    Para o testbench completo baseado no datasheet:
    ```bash
    iverilog -g2012 -o sim/ula_74181_datasheet.vvp rtl/ula_74181.sv tb/tb_ula_74181_datasheet.sv
    ```
    
    Ou use o script de build:
    ```bash
    # No Windows
    .\build\build.bat
    
    # No Linux/macOS
    ./build/build.sh
    ```
    
2.  **Execute a simulação**:
    ```bash
    vvp sim/ula_74181.vvp
    ```
    ou
    ```bash
    vvp sim/ula_74181_datasheet.vvp
    ```
    
    Isso imprimirá os resultados da simulação no terminal e gerará o arquivo VCD na pasta `sim/`.
    
3.  **Visualize as formas de onda**:
    ```bash
    gtkwave sim/ula_74181.vcd
    ```

### Simulação da ULA de 8 bits

1.  **Compile os módulos e o testbench**:
      * Note que o módulo `ula_8_bits.sv` instancia `ula_74181.sv`, portanto, ambos devem ser incluídos na compilação.
    
    ```bash
    iverilog -g2012 -o sim/ula_8_bits.vvp rtl/ula_74181.sv rtl/ula_8_bits.sv tb/tb_ula_8_bits.sv
    ```
    
    Para o testbench com 100% de cobertura:
    ```bash
    iverilog -g2012 -o sim/ula_8_bits_final.vvp rtl/ula_74181.sv rtl/ula_8_bits.sv tb/tb_ula_8_bits_final.sv
    ```
    
2.  **Execute a simulação**:
    ```bash
    vvp sim/ula_8_bits.vvp
    ```
    ou
    ```bash
    vvp sim/ula_8_bits_final.vvp
    ```
    
3.  **Visualize as formas de onda**:
    ```bash
    gtkwave sim/ula_8_bits.vcd
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

## Testbenches

Os testbenches implementados realizam testes abrangentes:

- **tb_ula_74181.sv**: Testa todas as 32 funções da ULA 74181 com múltiplos vetores de teste, incluindo casos extremos (0000, 1111) e casos intermediários.

- **tb_ula_8_bits.sv**: Testa todas as 32 funções com operandos de 8 bits, incluindo testes específicos para:
  - Verificação do ripple carry entre as ULAs de 4 bits
  - Operações com overflow
  - Comparação de igualdade para 8 bits
  - Padrões diversos (10101010, 11110000, etc.)

Ambos os testbenches geram saída formatada no terminal e arquivos VCD para análise no GTKWave.

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