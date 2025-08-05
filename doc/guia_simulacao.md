# Guia de Simulação e Visualização de Formas de Onda

Este guia fornece instruções detalhadas para executar as simulações do projeto e visualizar os resultados usando GTKWave.

## Requisitos de Software

Para executar as simulações deste projeto, você precisará ter instalado:

1. **Icarus Verilog** - Simulador de Verilog/SystemVerilog
   - [Download para Windows](https://bleyer.org/icarus/)
   - Para Linux: `sudo apt-get install iverilog`
   - Para macOS: `brew install icarus-verilog`

2. **GTKWave** - Visualizador de formas de onda
   - [Download para Windows](https://gtkwave.sourceforge.net/)
   - Para Linux: `sudo apt-get install gtkwave`
   - Para macOS: `brew install gtkwave`

## Usando os Scripts de Build Automatizados

A maneira mais rápida de executar todas as simulações é usando os scripts de build fornecidos:

### No Windows
```batch
cd build
.\build.bat
```

### No Linux/macOS
```bash
cd build
chmod +x build.sh  # Se necessário
./build.sh
```

Estes scripts compilarão e executarão todos os testbenches, gerando arquivos de forma de onda (VCD) na pasta `sim/`.

## Compilação e Execução Manual

Se preferir executar os testbenches individualmente:

### ULA 74181 (4 bits)

1. **Compilar o testbench básico**:
```bash
iverilog -g2012 -o sim/ula_74181.vvp rtl/ula_74181.sv tb/tb_ula_74181.sv
```

2. **Executar a simulação**:
```bash
vvp sim/ula_74181.vvp
```

3. **Visualizar formas de onda**:
```bash
gtkwave sim/ula_74181.vcd
```

### ULA de 8 bits

1. **Compilar o testbench básico**:
```bash
iverilog -g2012 -o sim/ula_8_bits.vvp rtl/ula_74181.sv rtl/ula_8_bits.sv tb/tb_ula_8_bits.sv
```

2. **Executar a simulação**:
```bash
vvp sim/ula_8_bits.vvp
```

3. **Visualizar formas de onda**:
```bash
gtkwave sim/ula_8_bits.vcd
```

## Guia para Visualização de Formas de Onda com GTKWave

### Configuração Inicial do GTKWave

1. Abra o arquivo VCD gerado:
```bash
gtkwave sim/ula_8_bits.vcd
```

2. No painel esquerdo, clique em `tb_ula_8_bits` (ou o módulo de teste correspondente)

3. Selecione os sinais que deseja visualizar:
   - Para a ULA 74181: `a`, `b`, `s`, `m`, `c_in`, `f`, `a_eq_b`, `c_out`, `p`, `g`
   - Para a ULA de 8 bits: os mesmos sinais acima, mais `overflow`

4. Clique com o botão direito nos sinais e selecione:
   - Para sinais de vetor (como `a`, `b`, `f`): "Data Format" > "Decimal" ou "Hexadecimal"
   - Para sinais de bit único: "Data Format" > "Binary"

5. Ajuste a escala de tempo conforme necessário usando os botões de zoom do GTKWave

### Pontos Importantes para Observar nas Formas de Onda

1. **ULA 74181 (4 bits)**:
   - Observe como os sinais `p` e `g` mudam dependendo dos valores de `a` e `b`
   - Verifique o comportamento do `c_out` nas operações de adição vs. subtração
   - Confirme que `a_eq_b` está em nível alto apenas quando `a` e `b` são iguais

2. **ULA de 8 bits**:
   - Observe o ripple carry entre as ULAs de 4 bits
   - Verifique quando o sinal de `overflow` é ativado em operações aritméticas
   - Compare os resultados com os valores esperados impressos no terminal

### Salvando e Carregando Configurações do GTKWave

Para salvar sua configuração de visualização para uso futuro:

1. No GTKWave, vá para "File" > "Write Save File" e salve como `ula_74181_view.gtkw` ou `ula_8_bits_view.gtkw`

2. Na próxima vez, você pode carregar esta configuração com:
```bash
gtkwave -a ula_74181_view.gtkw sim/ula_74181.vcd
```

## Interpretando os Resultados da Simulação

### Saída no Terminal

Os testbenches imprimem informações detalhadas no terminal, incluindo:

- Valores de entrada (`a`, `b`, `s`, `m`, `c_in`)
- Valores de saída (`f`, `a_eq_b`, `c_out`, `p`, `g`, `overflow`)
- Descrição da operação sendo executada
- Mensagens de verificação indicando se o teste passou ou falhou

### Análise de Forma de Onda

Ao analisar formas de onda no GTKWave, observe:

1. **Temporização**: Note os 10ns de atraso entre mudanças de entrada para permitir a estabilização dos sinais.

2. **Operações Aritméticas**: Verifique os carry-outs e o overflow durante operações como adição e subtração.

3. **Operações Lógicas**: Confirme que os resultados correspondem às operações lógicas esperadas.

4. **Sinais P e G**: Observe como estes sinais se comportam para diferentes combinações de entrada.

## Dicas para Solução de Problemas

- **Erro "file not found"**: Verifique se os caminhos dos arquivos estão corretos nos comandos.
- **Erro de sintaxe**: Verifique se está usando a flag `-g2012` para suporte a SystemVerilog.
- **Resultado incorreto**: Compare com os valores esperados impressos no terminal.
- **Falha ao abrir VCD**: Verifique se o arquivo foi gerado na pasta `sim/` corretamente.

Para uma análise mais detalhada, você pode modificar os testbenches para adicionar mais dumps de sinal ou casos de teste adicionais.
