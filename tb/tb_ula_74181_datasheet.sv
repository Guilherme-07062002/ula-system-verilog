`timescale 1ns/1ps

module tb_ula_74181_datasheet;

    // Sinais de entrada
    reg [3:0] a, b, s;
    reg m, c_in;
    
    // Sinais de saída
    wire [3:0] f;
    wire a_eq_b, c_out, p, g;
    
    // Instanciacao da ULA
    ula_74181 uut (
        .a(a),
        .b(b),
        .s(s),
        .m(m),
        .c_in(c_in),
        .f(f),
        .a_eq_b(a_eq_b),
        .c_out(c_out),
        .p(p),
        .g(g)
    );
    
    // Declaração das variáveis para referência de resultados esperados
    reg [3:0] expected_f;
    reg expected_cout, expected_p, expected_g;
    reg test_pass;
    integer errors, total_tests;
    
    // Definição das funções para calcular os resultados esperados
    function [3:0] calculate_expected_f_logic;
        input [3:0] s, a, b;
        begin
            case(s)
                4'b0000: calculate_expected_f_logic = ~a;
                4'b0001: calculate_expected_f_logic = ~(a | b);
                4'b0010: calculate_expected_f_logic = (~a) & b;
                4'b0011: calculate_expected_f_logic = 4'b0000;
                4'b0100: calculate_expected_f_logic = ~(a & b);
                4'b0101: calculate_expected_f_logic = ~b;
                4'b0110: calculate_expected_f_logic = a ^ b;
                4'b0111: calculate_expected_f_logic = a & (~b);
                4'b1000: calculate_expected_f_logic = a & b;
                4'b1001: calculate_expected_f_logic = ~(a ^ b);
                4'b1010: calculate_expected_f_logic = b;
                4'b1011: calculate_expected_f_logic = (~a) | b;
                4'b1100: calculate_expected_f_logic = 4'b1111;
                4'b1101: calculate_expected_f_logic = a | (~b);
                4'b1110: calculate_expected_f_logic = a | b;
                4'b1111: calculate_expected_f_logic = a;
                default: calculate_expected_f_logic = 4'bxxxx;
            endcase
        end
    endfunction
    
    function [4:0] calculate_expected_f_arith;
        input [3:0] s, a, b;
        input c_in;
        reg [4:0] temp;
        begin
            case(s)
                4'b0000: temp = {1'b0, a} + 5'b01111 + c_in;           // A MINUS 1
                4'b0001: temp = {1'b0, a} + {1'b0, a|b} + c_in;        // A PLUS (A OR B)
                4'b0010: temp = {1'b0, a|b} + 5'b01111 + c_in;         // (A OR B) MINUS 1
                4'b0011: temp = 5'b01111 + c_in;                       // MINUS 1
                4'b0100: temp = {1'b0, a} + {1'b0, a&b} + c_in;        // A PLUS (A AND B)
                4'b0101: temp = {1'b0, a|b} + {1'b0, a&b} + c_in;      // (A OR B) PLUS (A AND B)
                4'b0110: temp = {1'b0, a} + {1'b0, ~b} + c_in;         // A MINUS B MINUS 1
                4'b0111: temp = {1'b0, a&~b} + 5'b01111 + c_in;        // (A AND ~B) MINUS 1
                4'b1000: temp = {1'b0, a} + {1'b0, a&~b} + c_in;       // A PLUS (A AND ~B)
                4'b1001: temp = {1'b0, a} + {1'b0, b} + c_in;          // A PLUS B
                4'b1010: temp = {1'b0, a|~b} + {1'b0, a&b} + c_in;     // (A OR ~B) PLUS (A AND B)
                4'b1011: temp = {1'b0, a&b} + 5'b01111 + c_in;         // (A AND B) MINUS 1
                4'b1100: temp = {1'b0, a} + {1'b0, a} + c_in;          // A PLUS A
                4'b1101: temp = {1'b0, a|b} + {1'b0, a} + c_in;        // (A OR B) PLUS A
                4'b1110: temp = {1'b0, a|~b} + {1'b0, a} + c_in;       // (A OR ~B) PLUS A
                4'b1111: temp = {1'b0, a} + {1'b0, 4'b0000} + c_in;    // A
                default: temp = 5'bxxxxx;
            endcase
            calculate_expected_f_arith = temp;
        end
    endfunction
    
    function calculate_expected_cout;
        input [3:0] s;
        input [4:0] result;
        input m;
        begin
            if (m == 1'b1) begin
                calculate_expected_cout = 1'b0; // No modo logico, cout e sempre 0
            end else begin
                case(s)
                    // Operações com carry complementado
                    4'b0000, 4'b0010, 4'b0011, 4'b0110, 4'b0111, 4'b1011:
                        calculate_expected_cout = ~result[4];
                    // Operações com carry direto
                    default:
                        calculate_expected_cout = result[4];
                endcase
            end
        end
    endfunction
    
    // Calcular p e g esperados com base no datasheet
    function calculate_expected_p;
        input [3:0] a, op_result;
        input m;
        reg [3:0] p_bits;
        begin
            if (m == 1'b1) begin
                calculate_expected_p = 1'b0; // No modo logico, p e sempre 0
            end else begin
                // P = (A0 | Y0) & (A1 | Y1) & (A2 | Y2) & (A3 | Y3)
                p_bits[0] = a[0] | op_result[0];
                p_bits[1] = a[1] | op_result[1];
                p_bits[2] = a[2] | op_result[2];
                p_bits[3] = a[3] | op_result[3];
                calculate_expected_p = &p_bits;
            end
        end
    endfunction
    
    function calculate_expected_g;
        input [3:0] a, op_result;
        input m;
        reg [3:0] p_bits, g_bits;
        begin
            if (m == 1'b1) begin
                calculate_expected_g = 1'b1; // No modo logico, g e sempre 1
            end else begin
                // Calculamos p_bits e g_bits para cada bit
                for (int i = 0; i < 4; i = i + 1) begin
                    p_bits[i] = a[i] | op_result[i];
                    g_bits[i] = a[i] & op_result[i];
                end
                // G = G3 | (P3 & G2) | (P3 & P2 & G1) | (P3 & P2 & P1 & G0)
                calculate_expected_g = g_bits[3] |
                                      (p_bits[3] & g_bits[2]) |
                                      (p_bits[3] & p_bits[2] & g_bits[1]) |
                                      (p_bits[3] & p_bits[2] & p_bits[1] & g_bits[0]);
            end
        end
    endfunction
    
    // Task para calcular o resultado esperado e verificar a operação
    task verify_operation;
        input [3:0] s_val, a_val, b_val;
        input m_val, c_in_val;
        reg [4:0] result_arith;
        reg [3:0] op_result;
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
                expected_cout = 1'b0; // No modo logico, cout e sempre 0
                expected_p = 1'b0;    // No modo logico, p e sempre 0
                expected_g = 1'b1;    // No modo logico, g e sempre 1
            end else begin
                // Modo aritmético
                // Calculamos o resultado esperado
                result_arith = calculate_expected_f_arith(s, a, b, c_in);
                expected_f = result_arith[3:0];
                expected_cout = calculate_expected_cout(s, result_arith, m);
                
                // Calculamos op_result para P e G
                case(s)
                    4'b0000: op_result = 4'b1111;               // Para A MINUS 1
                    4'b0001: op_result = a | b;                 // Para A PLUS (A OR B)
                    4'b0010: op_result = a | b;                 // Para (A OR B) MINUS 1
                    4'b0011: op_result = 4'b1111;               // Para MINUS 1
                    4'b0100: op_result = a & b;                 // Para A PLUS (A AND B)
                    4'b0101: op_result = (a | b) | (a & b);     // Para (A OR B) PLUS (A AND B)
                    4'b0110: op_result = ~b;                    // Para A MINUS B MINUS 1
                    4'b0111: op_result = a & ~b;                // Para (A AND ~B) MINUS 1
                    4'b1000: op_result = a & ~b;                // Para A PLUS (A AND ~B)
                    4'b1001: op_result = b;                     // Para A PLUS B
                    4'b1010: op_result = (a | ~b) | (a & b);    // Para (A OR ~B) PLUS (A AND B)
                    4'b1011: op_result = a & b;                 // Para (A AND B) MINUS 1
                    4'b1100: op_result = a;                     // Para A PLUS A
                    4'b1101: op_result = (a | b) | a;           // Para (A OR B) PLUS A
                    4'b1110: op_result = (a | ~b) | a;          // Para (A OR ~B) PLUS A
                    4'b1111: op_result = a;                     // Para A
                    default: op_result = 4'b0000;
                endcase
                
                expected_p = calculate_expected_p(a, op_result, m);
                expected_g = calculate_expected_g(a, op_result, m);
            end
            
            // Verificamos se os resultados estão corretos
            test_pass = (f === expected_f) && (c_out === expected_cout) && 
                        (p === expected_p) && (g === expected_g);
            
            // Exibir resultados em formato de tabela
            $display("| %s | %04b | %04b | %04b |  %b  | %04b |  %b  |  %b   | %b | %b |  %s  |", 
                    (m == 0) ? "ARI" : "LOG", s, a, b, c_in, f, a_eq_b, c_out, p, g,
                    test_pass ? "PASS" : "FAIL");
            
            // Se houver erro, mostrar informações adicionais
            if (!test_pass) begin
                errors = errors + 1;
                $display("  ERRO: Esperado: F=%04b, Cout=%b, P=%b, G=%b", expected_f, expected_cout, expected_p, expected_g);
            end
        end
    endtask
    
    initial begin
        // Configuração para gerar arquivo VCD na pasta sim/
        $dumpfile("../sim/ula_74181_datasheet.vcd");
        $dumpvars(0, tb_ula_74181_datasheet);
        
        $display("=== Testbench de Validacao Completa da ULA 74181 ===");
        $display("Testando todos os 64 casos (16 funcoes x 2 modos x 2 valores de Cin)");
        
        errors = 0;
        total_tests = 0;
        
        // Cabeçalho da tabela para facilitar a leitura dos resultados
        $display("| Modo | S    |   A   |   B   | Cin |   F   | A=B | Cout | P | G | Status |");
        $display("|------|------|-------|-------|-----|-------|-----|------|---|---|--------|");
        
        // Testamos cada função com diferentes valores de entradas
        for (int mode = 0; mode <= 1; mode = mode + 1) begin
            m = mode;
            $display("\n=== MODO %s (M=%0d) ===", (m == 0) ? "ARITMETICO" : "LOGICO", m);
            $display("| Modo | S    |   A   |   B   | Cin |   F   | A=B | Cout | P | G | Status |");
            $display("|------|------|-------|-------|-----|-------|-----|------|---|---|--------|");
            
            for (int func = 0; func < 16; func = func + 1) begin
                s = func[3:0];
                $display("\nFuncao S=%04b:", s);
                $display("| Modo | S    |   A   |   B   | Cin |   F   | A=B | Cout | P | G | Status |");
                $display("|------|------|-------|-------|-----|-------|-----|------|---|---|--------|");
                
                for (int cin_val = 0; cin_val <= 1; cin_val = cin_val + 1) begin
                    c_in = cin_val;
                    
                    // Testamos alguns casos representativos
                    verify_operation(s, 4'h0, 4'h0, m, c_in);  // Zeros
                    verify_operation(s, 4'hF, 4'h0, m, c_in);  // A=1111, B=0000
                    verify_operation(s, 4'hA, 4'h5, m, c_in);  // A=1010, B=0101
                    verify_operation(s, 4'h3, 4'h3, m, c_in);  // A=B=0011
                    verify_operation(s, 4'h8, 4'h7, m, c_in);  // A=1000, B=0111
                    verify_operation(s, 4'hF, 4'hF, m, c_in);  // A=B=1111
                end
            end
        end
        
        // Exibimos o resultado final
        $display("\n=== Resultado Final ===");
        if (errors == 0) begin
            $display("=== TODOS OS TESTES PASSARAM! (%0d testes) ===", total_tests);
        end else begin
            $display("=== %0d ERROS em %0d testes! ===", errors, total_tests);
        end
        
        $display("\n=== Simulacao Concluida ===");
        #100;
        $finish;
    end

endmodule
