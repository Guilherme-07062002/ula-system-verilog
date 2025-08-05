#!/bin/bash
# Script de construção para compilar e executar os testbenches

# Cria diretório de saída se não existir
mkdir -p ../sim

# Função para compilar e executar um testbench
compile_and_run() {
    local name=$1
    local src_files=$2
    local tb_file=$3
    
    echo "=== Compilando $name ==="
    iverilog -g2012 -o ../sim/${name}.vvp $src_files $tb_file
    
    if [ $? -eq 0 ]; then
        echo "=== Executando $name ==="
        vvp ../sim/${name}.vvp
    else
        echo "Erro na compilação de $name"
    fi
    echo
}

# Diretórios base
RTL_DIR="../rtl"
TB_DIR="../tb"
SIM_DIR="../sim"

# Testbench ULA 74181 básico
compile_and_run "ula_74181" "$RTL_DIR/ula_74181.sv" "$TB_DIR/tb_ula_74181.sv"

# Testbench ULA 74181 Datasheet
compile_and_run "ula_74181_datasheet" "$RTL_DIR/ula_74181.sv" "$TB_DIR/tb_ula_74181_datasheet.sv"

# Testbench ULA 8 bits básico
compile_and_run "ula_8_bits" "$RTL_DIR/ula_74181.sv $RTL_DIR/ula_8_bits.sv" "$TB_DIR/tb_ula_8_bits.sv"

# Testbench ULA 8 bits Final
compile_and_run "ula_8_bits_final" "$RTL_DIR/ula_74181.sv $RTL_DIR/ula_8_bits.sv" "$TB_DIR/tb_ula_8_bits_final.sv"

echo "=== Todos os testbenches foram compilados e executados ==="
