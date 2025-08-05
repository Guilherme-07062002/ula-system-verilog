@echo off
REM Script de construção para Windows para compilar e executar os testbenches

REM Obtém o caminho absoluto do diretório do projeto
pushd %~dp0\..
set PROJECT_DIR=%CD%
popd

REM Define diretórios usando caminhos absolutos
set RTL_DIR=%PROJECT_DIR%\rtl
set TB_DIR=%PROJECT_DIR%\tb
set SIM_DIR=%PROJECT_DIR%\sim

REM Cria diretório de saída se não existir
if not exist "%SIM_DIR%" mkdir "%SIM_DIR%"

echo === Compilando ULA 74181 ===
iverilog -g2012 -o "%SIM_DIR%\ula_74181.vvp" "%RTL_DIR%\ula_74181.sv" "%TB_DIR%\tb_ula_74181.sv"
if %ERRORLEVEL% EQU 0 (
    echo === Executando ULA 74181 ===
    vvp "%SIM_DIR%\ula_74181.vvp"
)

echo.
echo === Compilando ULA 74181 Datasheet ===
iverilog -g2012 -o "%SIM_DIR%\ula_74181_datasheet.vvp" "%RTL_DIR%\ula_74181.sv" "%TB_DIR%\tb_ula_74181_datasheet.sv"
if %ERRORLEVEL% EQU 0 (
    echo === Executando ULA 74181 Datasheet ===
    vvp "%SIM_DIR%\ula_74181_datasheet.vvp"
)

echo.
echo === Compilando ULA 8 bits ===
iverilog -g2012 -o "%SIM_DIR%\ula_8_bits.vvp" "%RTL_DIR%\ula_74181.sv" "%RTL_DIR%\ula_8_bits.sv" "%TB_DIR%\tb_ula_8_bits.sv"
if %ERRORLEVEL% EQU 0 (
    echo === Executando ULA 8 bits ===
    vvp "%SIM_DIR%\ula_8_bits.vvp"
)

echo.
echo === Compilando ULA 8 bits Final ===
iverilog -g2012 -o "%SIM_DIR%\ula_8_bits_final.vvp" "%RTL_DIR%\ula_74181.sv" "%RTL_DIR%\ula_8_bits.sv" "%TB_DIR%\tb_ula_8_bits_final.sv"
if %ERRORLEVEL% EQU 0 (
    echo === Executando ULA 8 bits Final ===
    vvp "%SIM_DIR%\ula_8_bits_final.vvp"
)

echo.
echo === Compilando ULA 8 bits Datasheet ===
iverilog -g2012 -o "%SIM_DIR%\ula_8_bits_datasheet.vvp" "%RTL_DIR%\ula_74181.sv" "%RTL_DIR%\ula_8_bits.sv" "%TB_DIR%\tb_ula_8_bits_datasheet.sv"
if %ERRORLEVEL% EQU 0 (
    echo === Executando ULA 8 bits Datasheet ===
    vvp "%SIM_DIR%\ula_8_bits_datasheet.vvp"
)

echo.
echo === Compilando ULA 8 bits Simples ===
iverilog -g2012 -o "%SIM_DIR%\ula_8_bits_simples.vvp" "%RTL_DIR%\ula_74181.sv" "%RTL_DIR%\ula_8_bits.sv" "%TB_DIR%\tb_ula_8_bits_simples.sv"
if %ERRORLEVEL% EQU 0 (
    echo === Executando ULA 8 bits Simples ===
    vvp "%SIM_DIR%\ula_8_bits_simples.vvp"
)

echo.
echo === Todos os testbenches foram compilados e executados ===
pause
