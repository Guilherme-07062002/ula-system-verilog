@echo off
REM Script de construção para Windows para compilar e executar os testbenches

REM Cria diretório de saída se não existir
if not exist "..\sim" mkdir "..\sim"

echo === Compilando ULA 74181 ===
iverilog -g2012 -o ..\sim\ula_74181.vvp ..\rtl\ula_74181.sv ..\tb\tb_ula_74181.sv
if %ERRORLEVEL% EQU 0 (
    echo === Executando ULA 74181 ===
    vvp ..\sim\ula_74181.vvp
)

echo.
echo === Compilando ULA 74181 Datasheet ===
iverilog -g2012 -o ..\sim\ula_74181_datasheet.vvp ..\rtl\ula_74181.sv ..\tb\tb_ula_74181_datasheet.sv
if %ERRORLEVEL% EQU 0 (
    echo === Executando ULA 74181 Datasheet ===
    vvp ..\sim\ula_74181_datasheet.vvp
)

echo.
echo === Compilando ULA 8 bits ===
iverilog -g2012 -o ..\sim\ula_8_bits.vvp ..\rtl\ula_74181.sv ..\rtl\ula_8_bits.sv ..\tb\tb_ula_8_bits.sv
if %ERRORLEVEL% EQU 0 (
    echo === Executando ULA 8 bits ===
    vvp ..\sim\ula_8_bits.vvp
)

echo.
echo === Compilando ULA 8 bits Final ===
iverilog -g2012 -o ..\sim\ula_8_bits_final.vvp ..\rtl\ula_74181.sv ..\rtl\ula_8_bits.sv ..\tb\tb_ula_8_bits_final.sv
if %ERRORLEVEL% EQU 0 (
    echo === Executando ULA 8 bits Final ===
    vvp ..\sim\ula_8_bits_final.vvp
)

echo.
echo === Todos os testbenches foram compilados e executados ===
pause
