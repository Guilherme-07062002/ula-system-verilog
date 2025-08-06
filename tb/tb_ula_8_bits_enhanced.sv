`timescale 1ns/1ps

module tb_ula_8_bits_enhanced;

    // Sinais de entrada
    reg [7:0] a, b;
    reg [3:0] s;
    reg m, c_in;
    
    // Sinais de saída
    wire [7:0] f, f_enhanced;
    wire a_eq_b, c_out, overflow;
    wire a_eq_b_enhanced, c_out_enhanced, overflow_enhanced;
    wire p, g, p_enhanced, g_enhanced;
    
    // Instanciação da ULA original de 8 bits
    ula_8_bits uut_original (
        .a(a),
        .b(b),
        .s(s),
        .m(m),
        .c_in(c_in),
        .f(f),
        .a_eq_b(a_eq_b),
        .c_out(c_out),
        .overflow(overflow),
        .p(p),
        .g(g)
    );
    
    // Instanciação da ULA aprimorada de 8 bits
    ula_8_bits_enhanced uut_enhanced (
        .a(a),
        .b(b),
        .s(s),
        .m(m),
        .c_in(c_in),
        .f(f_enhanced),
        .a_eq_b(a_eq_b_enhanced),
        .c_out(c_out_enhanced),
        .overflow(overflow_enhanced),
        .p(p_enhanced),
        .g(g_enhanced)
    );
    
    // Variáveis para a verificação
    reg [7:0] expected_f;
    reg expected_cout, expected_overflow;
    integer errors, total_tests;
    
    // Função para calcular o resultado esperado no modo lógico (8 bits)
    function [7:0] calculate_expected_f_logic;
        input [3:0] s;
        input [7:0] a, b;
        begin
            case(s)
                4'b0000: calculate_expected_f_logic = ~a;
                4'b0001: calculate_expected_f_logic = ~(a | b);
                4'b0010: calculate_expected_f_logic = (~a) & b;
                4'b0011: calculate_expected_f_logic = 8'b00000000;
                4'b0100: calculate_expected_f_logic = ~(a & b);
                4'b0101: calculate_expected_f_logic = ~b;
                4'b0110: calculate_expected_f_logic = a ^ b;
                4'b0111: calculate_expected_f_logic = a & (~b);
                4'b1000: calculate_expected_f_logic = a & b;
                4'b1001: calculate_expected_f_logic = ~(a ^ b);
                4'b1010: calculate_expected_f_logic = b;
                4'b1011: calculate_expected_f_logic = (~a) | b;
                4'b1100: calculate_expected_f_logic = 8'b11111111;
                4'b1101: calculate_expected_f_logic = a | (~b);
                4'b1110: calculate_expected_f_logic = a | b;
                4'b1111: calculate_expected_f_logic = a;
                default: calculate_expected_f_logic = 8'bxxxxxxxx;
            endcase
        end
    endfunction
    
    // Função para calcular o resultado esperado no modo aritmético (8 bits)
    function [8:0] calculate_expected_f_arith;
        input [3:0] s;
        input [7:0] a, b;
        input c_in;
        reg [8:0] temp;
        begin
            case(s)
                4'b0000: temp = {1'b0, a} + 9'b011111111 + c_in;               // A MINUS 1
                4'b0001: temp = {1'b0, a} + {1'b0, a|b} + c_in;                // A PLUS (A OR B)
                4'b0010: temp = {1'b0, a|b} + 9'b011111111 + c_in;             // (A OR B) MINUS 1
                4'b0011: temp = 9'b011111111 + c_in;                           // MINUS 1
                4'b0100: temp = {1'b0, a} + {1'b0, a&b} + c_in;                // A PLUS (A AND B)
                4'b0101: temp = {1'b0, a|b} + {1'b0, a&b} + c_in;              // (A OR B) PLUS (A AND B)
                4'b0110: temp = {1'b0, a} + {1'b0, ~b} + c_in;                 // A MINUS B MINUS 1
                4'b0111: temp = {1'b0, a&~b} + 9'b011111111 + c_in;            // (A AND ~B) MINUS 1
                4'b1000: temp = {1'b0, a} + {1'b0, a&~b} + c_in;               // A PLUS (A AND ~B)
                4'b1001: temp = {1'b0, a} + {1'b0, b} + c_in;                  // A PLUS B
                4'b1010: temp = {1'b0, a|~b} + {1'b0, a&b} + c_in;             // (A OR ~B) PLUS (A AND B)
                4'b1011: temp = {1'b0, a&b} + 9'b011111111 + c_in;             // (A AND B) MINUS 1
                4'b1100: temp = {1'b0, a} + {1'b0, a} + c_in;                  // A PLUS A
                4'b1101: temp = {1'b0, a|b} + {1'b0, a} + c_in;                // (A OR B) PLUS A
                4'b1110: temp = {1'b0, a|~b} + {1'b0, a} + c_in;               // (A OR ~B) PLUS A
                4'b1111: temp = {1'b0, a} + {1'b0, 8'b00000000} + c_in;        // A
                default: temp = 9'bxxxxxxxxx;
            endcase
            calculate_expected_f_arith = temp;
        end
    endfunction
    
    // Função para calcular o carry-out esperado
    function calculate_expected_cout;
        input [3:0] s;
        input [8:0] result;
        input m;
        begin
            if (m == 1'b1) begin
                calculate_expected_cout = 1'b0; // No modo lógico, cout é sempre 0
            end else begin
                case(s)
                    // Operações com carry complementado
                    4'b0000, 4'b0010, 4'b0011, 4'b0110, 4'b0111, 4'b1011:
                        calculate_expected_cout = ~result[8];
                    // Operações com carry direto
                    default:
                        calculate_expected_cout = result[8];
                endcase
            end
        end
    endfunction
    
    // Task para verificar a operação
    task verify_operation;
        input [3:0] s_val;
        input [7:0] a_val, b_val;
        input m_val, c_in_val;
        reg [8:0] result_arith;
        begin
            // Configuramos os valores de entrada
            s = s_val;
            a = a_val;
            b = b_val;
            m = m_val;
            c_in = c_in_val;
            
            // Aguardamos um pouco para estabilizar
            #5;
            
            total_tests = total_tests + 1;
            
            // Calculamos os resultados esperados
            if (m == 1'b1) begin
                // Modo lógico
                expected_f = calculate_expected_f_logic(s, a, b);
            end else begin
                // Modo aritmético
                result_arith = calculate_expected_f_arith(s, a, b, c_in);
                expected_f = result_arith[7:0];
                expected_cout = calculate_expected_cout(s, result_arith, m);
            end
            
            // Comparamos os resultados da implementação original e aprimorada com o esperado
            // Testamos todas as operações, não apenas as problemáticas
            begin
                reg orig_ok, enhanced_ok;
                reg orig_match, enhanced_match;

                orig_ok = (f == expected_f && c_out == expected_cout);
                enhanced_ok = (f_enhanced == expected_f && c_out_enhanced == expected_cout);

                // Cabeçalho da tabela (apenas no primeiro teste)
                if (total_tests == 1) begin
                    $display("| Teste | M | S    |   A   |   B   | Cin | Esperado      | ULA Orig        | ULA Aprim      | Status |");
                    $display("|-------|---|------|-------|-------|-----|---------------|-----------------|---------------|--------|");
                end

                // Status

                // Exibição em formato de tabela (status calculado inline)
                $display("| %5d | %1b | %4b | %5h | %5h |  %1b  | F=%2h,C=%1b | F=%2h,C=%1b %s | F=%2h,C=%1b %s | %s |",
                    total_tests, m, s, a, b, c_in,
                    expected_f, expected_cout,
                    f, c_out, orig_ok ? "OK" : "ERRO",
                    f_enhanced, c_out_enhanced, enhanced_ok ? "OK" : "ERRO",
                    (orig_ok && enhanced_ok) ? "OK" :
                    (!orig_ok && enhanced_ok) ? "Corrigido" :
                    (!orig_ok && !enhanced_ok) ? "Erro" : "Diferença");

                // Verificar se a versão aprimorada corrige o problema
                orig_match = (f == expected_f && c_out == expected_cout);
                enhanced_match = (f_enhanced == expected_f && c_out_enhanced == expected_cout);

                if (!orig_match && enhanced_match) begin
                    // $display("  => Correção bem-sucedida! A ULA aprimorada resolveu o problema.");
                end else if (!orig_match && !enhanced_match) begin
                    // $display("  => Ambas as implementações diferem do resultado esperado.");
                    errors = errors + 1;
                end
            end
        end
    endtask
    
    // Testes específicos para ripple carry
    task test_problematic_cases;
        begin
            $display("\n=== Testando Casos Problemáticos ===");
            
            // Adição com carry entre nibbles
            m = 0; // Modo aritmético
            s = 4'b1001; // A + B
            c_in = 0;
            
            // 127 + 1 = 128 (carry entre nibbles)
            a = 8'h7F; b = 8'h01;
            #5;
            $display("A=%h + B=%h (Carry entre nibbles)", a, b);
            $display("  Esperado: F=80, Cout=0, Overflow=1");
            $display("  ULA Original: F=%h, Cout=%b, Overflow=%b", f, c_out, overflow);
            $display("  ULA Aprimorada: F=%h, Cout=%b, Overflow=%b", f_enhanced, c_out_enhanced, overflow_enhanced);
            $display("");
            
            // 255 + 1 = 0 com carry out
            a = 8'hFF; b = 8'h01;
            #5;
            $display("A=%h + B=%h (Carry out)", a, b);
            $display("  Esperado: F=00, Cout=1");
            $display("  ULA Original: F=%h, Cout=%b", f, c_out);
            $display("  ULA Aprimorada: F=%h, Cout=%b", f_enhanced, c_out_enhanced);
            $display("");
            
            // Subtração com borrow
            s = 4'b0110; // A - B - 1
            c_in = 1; // Equivalente a +1 no complemento a dois
            
            a = 8'h40; b = 8'h01;
            #5;
            $display("A=%h - B=%h (Subtração simples)", a, b);
            $display("  Esperado: F=3F");
            $display("  ULA Original: F=%h", f);
            $display("  ULA Aprimorada: F=%h", f_enhanced);
            $display("");
            
            a = 8'h50; b = 8'h21;
            #5;
            $display("A=%h - B=%h (Subtração com nibble)", a, b);
            $display("  Esperado: F=2F");
            $display("  ULA Original: F=%h", f);
            $display("  ULA Aprimorada: F=%h", f_enhanced);
            $display("");
            
            // A - 1
            s = 4'b0000; // A - 1
            c_in = 1;
            
            a = 8'h40; b = 8'h00;
            #5;
            $display("A=%h - 1 (Decremento sem borrow entre nibbles)", a);
            $display("  Esperado: F=3F");
            $display("  ULA Original: F=%h", f);
            $display("  ULA Aprimorada: F=%h", f_enhanced);
            $display("");
            
            a = 8'h10; b = 8'h00;
            #5;
            $display("A=%h - 1 (Decremento com borrow entre nibbles)", a);
            $display("  Esperado: F=0F");
            $display("  ULA Original: F=%h", f);
            $display("  ULA Aprimorada: F=%h", f_enhanced);
            $display("");
        end
    endtask
    
    initial begin
        // Configuração para gerar arquivo VCD
        $dumpfile("ula_8_bits_enhanced.vcd");
        $dumpvars(0, tb_ula_8_bits_enhanced);
        
        $display("=== Testbench Comparativo: ULA Original vs ULA Aprimorada ===");
        
        errors = 0;
        total_tests = 0;
        
        // Testamos casos específicos que demonstram as diferenças entre as implementações
        test_problematic_cases();
        
        $display("\n=== Testando Todas as Operações ===");
        $display("Testando modo aritmético (M=0) e modo lógico (M=1) com diferentes valores de entrada");
        
        // Testamos todas as operações em ambos os modos (aritmético e lógico)
        for (integer m_val = 0; m_val <= 1; m_val = m_val + 1) begin
            for (integer i = 0; i < 16; i = i + 1) begin
                s = i[3:0];
                m = m_val[0];
                
                // Teste com diferentes valores de entrada e carry-in
                // 1. Valores pequenos sem carry/borrow
                verify_operation(s, 8'h02, 8'h03, m, 1'b0);
                verify_operation(s, 8'h02, 8'h03, m, 1'b1);
                
                // 2. Casos com carry/borrow entre nibbles
                verify_operation(s, 8'h0F, 8'h01, m, 1'b0);
                verify_operation(s, 8'h10, 8'h01, m, 1'b0);
                
                // 3. Casos de overflow potencial
                verify_operation(s, 8'h7F, 8'h01, m, 1'b0);
                verify_operation(s, 8'h80, 8'h80, m, 1'b0);
                
                // 4. Casos com carry out
                verify_operation(s, 8'hFF, 8'h01, m, 1'b0);
                verify_operation(s, 8'hFF, 8'hFF, m, 1'b0);
                
                // 5. Padrões de bit interessantes
                verify_operation(s, 8'hAA, 8'h55, m, 1'b0);
                verify_operation(s, 8'hF0, 8'h0F, m, 1'b0);
            end
        end
        
        // Exibimos o resultado final
        if (errors == 0) begin
            $display("\n=== TODOS OS TESTES PASSARAM! (%0d testes) ===", total_tests);
        end else begin
            $display("\n=== %0d ERROS em %0d testes! ===", errors, total_tests);
        end
        
        $display("\n=== Simulacao Concluida ===");
        #100;
        $finish;
    end

endmodule
