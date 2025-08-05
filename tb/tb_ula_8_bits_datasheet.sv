`timescale 1ns/1ps

module tb_ula_8_bits_datasheet;

    // Sinais de entrada
    reg [7:0] a, b;
    reg [3:0] s;
    reg m, c_in;
    
    // Sinais de saída
    wire [7:0] f;
    wire a_eq_b, c_out, overflow;
    wire p, g; // Sinais de propagação e geração de carry
    
    // Instanciação da ULA de 8 bits
    ula_8_bits uut (
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
    
    // Variáveis para a verificação
    reg [7:0] expected_f;
    reg expected_cout, expected_overflow;
    reg test_pass;
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
    
    // Função para calcular o overflow esperado (para operações aritméticas)
    function calculate_expected_overflow;
        input [3:0] s;
        input [7:0] a, b, f;
        input m;
        begin
            if (m == 1'b1) begin
                calculate_expected_overflow = 1'b0; // No modo lógico, overflow é irrelevante
            end else begin
                // Detectar overflow nas operações aritméticas
                case(s)
                    // Adição A+B
                    4'b1001: 
                        calculate_expected_overflow = (a[7] == b[7]) && (a[7] != f[7]);
                    // Subtração A-B-1 (A+~B+0)
                    4'b0110:
                        calculate_expected_overflow = (a[7] != b[7]) && (f[7] == b[7]);
                    // Outras operações não são consideradas para overflow
                    default:
                        calculate_expected_overflow = 1'b0;
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
                expected_cout = 1'b0; // No modo lógico, cout é sempre 0
                expected_overflow = 1'b0; // No modo lógico, overflow é irrelevante
            end else begin
                // Modo aritmético
                result_arith = calculate_expected_f_arith(s, a, b, c_in);
                expected_f = result_arith[7:0];
                expected_cout = calculate_expected_cout(s, result_arith, m);
                expected_overflow = calculate_expected_overflow(s, a, b, expected_f, m);
            end
            
            // Verificamos se os resultados estão corretos
            test_pass = (f === expected_f) && (c_out === expected_cout) && 
                        (overflow === expected_overflow);
            
            if (!test_pass) begin
                errors = errors + 1;
                $display("ERRO: M=%b, S=%b, A=%h, B=%h, Cin=%b", m, s, a, b, c_in);
                $display("  Obtido: F=%h, Cout=%b, Overflow=%b", f, c_out, overflow);
                $display("  Esperado: F=%h, Cout=%b, Overflow=%b", expected_f, expected_cout, expected_overflow);
            end
        end
    endtask
    
    // Testes especiais para verificar o ripple carry
    task test_ripple_carry;
        begin
            $display("\n=== Testando Ripple Carry ==="); // 'ç' removido
            
            // Adição de dois números de 8 bits que gera carry
            m = 0; // Modo aritmético
            s = 4'b1001; // A + B
            c_in = 0;
            
            // 127 + 1 = 128 (sem overflow, mas com ripple carry do nibble baixo para o alto)
            a = 8'h7F; b = 8'h01;
            #5;
            $display("A=%h + B=%h = F=%h, Cout=%b, Overflow=%b", a, b, f, c_out, overflow);
            
            // 255 + 1 = 0 com carry out
            a = 8'hFF; b = 8'h01;
            #5;
            $display("A=%h + B=%h = F=%h, Cout=%b, Overflow=%b", a, b, f, c_out, overflow);
            
            // Testando overflow com números com sinal
            // 127 + 1 = 128 (overflow positivo para negativo)
            a = 8'h7F; b = 8'h01;
            #5;
            $display("A=%h + B=%h = F=%h, Cout=%b, Overflow=%b (Overflow esperado)", a, b, f, c_out, overflow);
            
            // -128 + (-1) = -129 (overflow negativo para positivo, representado como 127)
            a = 8'h80; b = 8'hFF;
            #5;
            $display("A=%h + B=%h = F=%h, Cout=%b, Overflow=%b (Overflow esperado)", a, b, f, c_out, overflow);
        end
    endtask
    
    initial begin
        // Configuração para gerar arquivo VCD na pasta sim/
        $dumpfile("../sim/ula_8_bits_datasheet.vcd");
        $dumpvars(0, tb_ula_8_bits_datasheet);
        
        $display("=== Testbench de Validacao da ULA de 8 bits ==="); // 'ç' -> 'c', 'ã' -> 'a'
        
        errors = 0;
        total_tests = 0;
        
        // Testamos cada função com diferentes valores de entradas
        for (int mode = 0; mode <= 1; mode = mode + 1) begin
            m = mode;
            $display("\n=== MODO %s (M=%0d) ===", (m == 0) ? "ARITMETICO" : "LOGICO", m); // sem acento
            
            for (int func = 0; func < 16; func = func + 1) begin
                s = func[3:0];
                $display("Funcao S=%04b:", s); // 'ç' -> 'c', 'ã' -> 'a'
                
                for (int cin_val = 0; cin_val <= 1; cin_val = cin_val + 1) begin
                    c_in = cin_val;
                    $display("  Cin=%b:", c_in);
                    
                    // Testamos alguns casos representativos para 8 bits
                    verify_operation(s, 8'h00, 8'h00, m, c_in);  // Zeros
                    verify_operation(s, 8'hFF, 8'h00, m, c_in);  // A=FF, B=00
                    verify_operation(s, 8'hAA, 8'h55, m, c_in);  // A=AA, B=55
                    verify_operation(s, 8'h33, 8'h33, m, c_in);  // A=B=33
                    verify_operation(s, 8'h80, 8'h7F, m, c_in);  // A=80, B=7F
                    verify_operation(s, 8'hFF, 8'hFF, m, c_in);  // A=B=FF
                end
            end
        end
        
        // Testes específicos para ripple carry e overflow
        test_ripple_carry();
        
        // Exibimos o resultado final
        if (errors == 0) begin
            $display("\n=== TODOS OS TESTES PASSARAM! (%0d testes) ===", total_tests); // 'ç' -> 'c', 'ã' -> 'a'
        end else begin
            $display("\n=== %0d ERROS em %0d testes! ===", errors, total_tests); // 'ç' -> 'c', 'ã' -> 'a'
        end
        
        $display("\n=== Simulacao Concluida ==="); // 'ç' -> 'c', 'ã' -> 'a', 'ú' -> 'u'
        #100;
        $finish;
    end

endmodule
