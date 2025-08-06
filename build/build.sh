#!/bin/bash
# Script de construção para compilar e executar os testbenches

# Imprimir os comandos ao executá-los para depuração
set -x

# Obter o diretório atual e o diretório base do projeto
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PROJECT_DIR=$(dirname "$SCRIPT_DIR")

# Definir diretórios usando caminhos absolutos
RTL_DIR="$PROJECT_DIR/rtl"
TB_DIR="$PROJECT_DIR/tb"
SIM_DIR="$PROJECT_DIR/sim"

# Cria diretório de saída se não existir
mkdir -p "$SIM_DIR"

# Função para compilar e executar um testbench específico
compile_and_run() {
    local name=$1
    shift  # Remove o primeiro argumento (nome)
    local tb_file=${!#}  # Último argumento é o testbench
    # Remove o último argumento (testbench)
    set -- "${@:1:$(($#-1))}"
    
    echo "=== Compilando $name ==="
    
    # Comando completo para debug
    echo "iverilog -g2012 -o \"$SIM_DIR/${name}.vvp\" $* \"$tb_file\""
    
    # Executar a compilação
    iverilog -g2012 -o "$SIM_DIR/${name}.vvp" "$@" "$tb_file"
    
    local result=$?
    if [ $result -eq 0 ]; then
        echo "=== Executando $name ==="
        vvp "$SIM_DIR/${name}.vvp"
    else
        echo "Erro na compilação de $name (código: $result)"
    fi
    echo
}

# Testbench ULA 74181 básico
compile_and_run "ula_74181" "$RTL_DIR/ula_74181.sv" "$TB_DIR/tb_ula_74181.sv"

# Testbench ULA 74181 Datasheet
compile_and_run "ula_74181_datasheet" "$RTL_DIR/ula_74181.sv" "$TB_DIR/tb_ula_74181_datasheet.sv"

# Testbench ULA 8 bits básico
compile_and_run "ula_8_bits" "$RTL_DIR/ula_74181.sv" "$RTL_DIR/ula_8_bits.sv" "$TB_DIR/tb_ula_8_bits.sv"

# Testbench ULA 8 bits Final
compile_and_run "ula_8_bits_final" "$RTL_DIR/ula_74181.sv" "$RTL_DIR/ula_8_bits.sv" "$TB_DIR/tb_ula_8_bits_final.sv"

# Testbench ULA 8 bits Datasheet
compile_and_run "ula_8_bits_datasheet" "$RTL_DIR/ula_74181.sv" "$RTL_DIR/ula_8_bits.sv" "$TB_DIR/tb_ula_8_bits_datasheet.sv"

# Testbench ULA 8 bits Simples
compile_and_run "ula_8_bits_simples" "$RTL_DIR/ula_74181.sv" "$RTL_DIR/ula_8_bits.sv" "$TB_DIR/tb_ula_8_bits_simples.sv"

# Testbench ULA 8 bits Enhanced
compile_and_run "ula_8_bits_enhanced" "$RTL_DIR/ula_74181.sv" "$RTL_DIR/ula_8_bits_enhanced.sv" "$TB_DIR/tb_ula_8_bits_enhanced.sv"

echo "=== Todos os testbenches foram compilados e executados ==="
