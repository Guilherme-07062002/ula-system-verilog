#!/bin/bash
# Script de construção para compilar e executar os testbenches

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

# Função para exibir o menu principal
show_main_menu() {
    echo "===== MENU DE TESTES ULA ====="
    echo "1. ULA de 4 bits (74181)"
    echo "2. ULA de 8 bits"
    echo "3. Visualizar ondas (GTKWave)"
    echo "4. Sair"
    echo "============================="
    echo "Escolha uma opção: "
}

# Função para exibir o submenu
show_submenu() {
    local ula_name=$1
    echo "===== TESTES PARA $ula_name ====="
    echo "1. Teste Simples"
    echo "2. Teste Datasheet (completo)"
    echo "3. Voltar"
    echo "============================="
    echo "Escolha uma opção: "
}

# Função para executar os testes da ULA de 4 bits (74181)
run_ula_4bits() {
    local option=$1
    case $option in
        1) # Teste Simples
            compile_and_run "ula_74181" "$RTL_DIR/ula_74181.sv" "$TB_DIR/tb_ula_74181.sv"
            ;;
        2) # Teste Datasheet
            compile_and_run "ula_74181_datasheet" "$RTL_DIR/ula_74181.sv" "$TB_DIR/tb_ula_74181_datasheet.sv"
            ;;
        *) 
            echo "Opção inválida!"
            ;;
    esac
}

# Função para executar os testes da ULA de 8 bits
run_ula_8bits() {
    local option=$1
    case $option in
        1) # Teste Simples
            compile_and_run "ula_8_bits" "$RTL_DIR/ula_74181.sv" "$RTL_DIR/ula_8_bits.sv" "$TB_DIR/tb_ula_8_bits.sv"
            ;;
        2) # Teste Datasheet
            compile_and_run "ula_8_bits_datasheet" "$RTL_DIR/ula_74181.sv" "$RTL_DIR/ula_8_bits.sv" "$TB_DIR/tb_ula_8_bits_datasheet.sv"
            ;;
        *) 
            echo "Opção inválida!"
            ;;
    esac
}

# Função para abrir um VCD no GTKWave (se existir)
open_vcd() {
    local vcd_file="$SIM_DIR/$1"
    if [ -f "$vcd_file" ]; then
        if command -v gtkwave >/dev/null 2>&1; then
            echo "Abrindo $vcd_file no GTKWave..."
            gtkwave "$vcd_file" &
        else
            echo "GTKWave não encontrado no PATH. Instale o GTKWave e tente novamente."
            echo "Baixe em: http://gtkwave.sourceforge.net/"
        fi
    else
        echo "Arquivo não encontrado: $vcd_file"
        echo "Execute o teste correspondente antes para gerar o VCD."
        read -r -p "Pressione ENTER para continuar..."
    fi
}

# Submenu para visualização de ondas
show_gtkwave_menu() {
    while true; do
        clear
        echo "===== VISUALIZAR ONDAS (GTKWave) ====="
        echo "1. 74181 (ula_74181.vcd)"
        echo "2. 74181 - Datasheet (ula_74181_datasheet.vcd)"
        echo "3. ULA 8 bits (ula_8_bits.vcd)"
        echo "4. ULA 8 bits - Datasheet (ula_8_bits_datasheet.vcd)"
        echo "5. Voltar"
        echo "======================================"
        echo -n "Escolha uma opção: "
        read -r opt
        case $opt in
            1) open_vcd "ula_74181.vcd" ;;
            2) open_vcd "ula_74181_datasheet.vcd" ;;
            3) open_vcd "ula_8_bits.vcd" ;;
            4) open_vcd "ula_8_bits_datasheet.vcd" ;;
            5) break ;;
            *) echo "Opção inválida!"; read -r -p "Pressione ENTER para continuar..." ;;
        esac
    done
}

# Loop principal do menu
while true; do
    clear
    show_main_menu
    read -r main_option
    
    case $main_option in
        1) # ULA de 4 bits
            while true; do
                show_submenu "ULA DE 4 BITS (74181)"
                read -r sub_option
                
                if [ "$sub_option" == "3" ]; then
                    break
                fi
                
                run_ula_4bits "$sub_option"
                echo "Pressione ENTER para continuar..."
                read -r
            done
            ;;
            
        2) # ULA de 8 bits
            while true; do
                show_submenu "ULA DE 8 BITS"
                read -r sub_option
                
                if [ "$sub_option" == "3" ]; then
                    break
                fi
                
                run_ula_8bits "$sub_option"
                echo "Pressione ENTER para continuar..."
                read -r
            done
            ;;
        3) # Visualizar ondas (GTKWave)
            show_gtkwave_menu
            ;;

        4) # Sair
            echo "Saindo do programa..."
            exit 0
            ;;
            
        *)
            echo "Opção inválida! Pressione ENTER para continuar..."
            read -r
            ;;
    esac
done
