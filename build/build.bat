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

REM Função para compilar e executar um testbench
:compile_and_run
    echo === Compilando %~1 ===
    iverilog -g2012 -o "%SIM_DIR%\%~1.vvp" %~2 %~3 %~4
    if %ERRORLEVEL% EQU 0 (
        echo === Executando %~1 ===
        vvp "%SIM_DIR%\%~1.vvp"
    ) else (
        echo Erro na compilação de %~1 ^(código: %ERRORLEVEL%^)
    )
    echo.
    goto :eof

:main_menu
cls
echo ===== MENU DE TESTES ULA =====
echo 1. ULA de 4 bits (74181)
echo 2. ULA de 8 bits
echo 3. Sair
echo =============================
set /p main_option=Escolha uma opcao: 

if "%main_option%"=="1" goto menu_ula_4bits
if "%main_option%"=="2" goto menu_ula_8bits
if "%main_option%"=="3" goto exit
echo Opcao invalida! Pressione qualquer tecla para continuar...
pause > nul
goto main_menu

:menu_ula_4bits
cls
echo ===== TESTES PARA ULA DE 4 BITS (74181) =====
echo 1. Teste Simples
echo 2. Teste Datasheet (completo)
echo 3. Voltar
echo =========================================
set /p sub_option=Escolha uma opcao: 

if "%sub_option%"=="1" (
    call :compile_and_run "ula_74181" "%RTL_DIR%\ula_74181.sv" "%TB_DIR%\tb_ula_74181.sv"
    pause
    goto menu_ula_4bits
)
if "%sub_option%"=="2" (
    call :compile_and_run "ula_74181_datasheet" "%RTL_DIR%\ula_74181.sv" "%TB_DIR%\tb_ula_74181_datasheet.sv"
    pause
    goto menu_ula_4bits
)
if "%sub_option%"=="3" goto main_menu
echo Opcao invalida! Pressione qualquer tecla para continuar...
pause > nul
goto menu_ula_4bits

:menu_ula_8bits
cls
echo ===== TESTES PARA ULA DE 8 BITS =====
echo 1. Teste Simples
echo 2. Teste Datasheet (completo)
echo 3. Voltar
echo =================================
set /p sub_option=Escolha uma opcao: 

if "%sub_option%"=="1" (
    call :compile_and_run "ula_8_bits" "%RTL_DIR%\ula_74181.sv" "%RTL_DIR%\ula_8_bits.sv" "%TB_DIR%\tb_ula_8_bits.sv"
    pause
    goto menu_ula_8bits
)
if "%sub_option%"=="2" (
    call :compile_and_run "ula_8_bits_datasheet" "%RTL_DIR%\ula_74181.sv" "%RTL_DIR%\ula_8_bits.sv" "%TB_DIR%\tb_ula_8_bits_datasheet.sv"
    pause
    goto menu_ula_8bits
)
if "%sub_option%"=="3" goto main_menu
echo Opcao invalida! Pressione qualquer tecla para continuar...
pause > nul
goto menu_ula_8bits

:exit
echo Saindo do programa...
exit /b 0

REM Inicia o programa no menu principal
goto main_menu
