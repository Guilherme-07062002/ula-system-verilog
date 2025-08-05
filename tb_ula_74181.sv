`timescale 1ns/1ps

module tb_ula_74181;

    // Sinais de entrada
    reg [3:0] a, b, s;
    reg m, c_in;
    
    // Sinais de saída
    wire [3:0] f;
    wire a_eq_b, c_out;
    
    // Instanciação da ULA
    ula_74181 uut (
        .a(a),
        .b(b),
        .s(s),
        .m(m),
        .c_in(c_in),
        .f(f),
        .a_eq_b(a_eq_b),
        .c_out(c_out)
    );
    
    // Variáveis para controle do teste
    integer i, fn;
    
    // Função para obter a descrição da função lógica
    function string get_logic_function(input [3:0] sel);
        case(sel)
            4'b0000: return "NOT A";
            4'b0001: return "NOR";
            4'b0010: return "A̅ & B";
            4'b0011: return "ZERO";
            4'b0100: return "NAND";
            4'b0101: return "NOT B";
            4'b0110: return "XOR";
            4'b0111: return "A & B̅";
            4'b1000: return "AND";
            4'b1001: return "XNOR";
            4'b1010: return "B";
            4'b1011: return "A̅ | B";
            4'b1100: return "ONE";
            4'b1101: return "A | B̅";
            4'b1110: return "OR";
            4'b1111: return "A";
            default: return "UNKNOWN";
        endcase
    endfunction
    
    // Função para obter a descrição da função aritmética
    function string get_arith_function(input [3:0] sel);
        case(sel)
            4'b0000: return "A + Cin";
            4'b0001: return "A + B + Cin";
            4'b0010: return "A + ~B + Cin";
            4'b0011: return "-1 + Cin";
            4'b0100: return "A + (A & ~B) + Cin";
            4'b0101: return "(A | B) + (A & ~B) + Cin";
            4'b0110: return "A - B - 1 + Cin";
            4'b0111: return "(A & ~B) - 1 + Cin";
            4'b1000: return "A + (A & B) + Cin";
            4'b1001: return "A + B + Cin";
            4'b1010: return "(A | ~B) + (A & B) + Cin";
            4'b1011: return "A + Cin";
            4'b1100: return "(A & B) - 1 + Cin";
            4'b1101: return "A + B + Cin";
            4'b1110: return "(A & ~B) + Cin";
            4'b1111: return "A - 1 + Cin";
            default: return "UNKNOWN";
        endcase
    endfunction
    
    // Função para calcular o resultado esperado no modo lógico
    function [3:0] calc_logic_expected(input [3:0] sel, input [3:0] a, input [3:0] b);
        case(sel)
            4'b0000: return ~a;                    // NOT A
            4'b0001: return ~(a | b);              // NOR
            4'b0010: return (~a) & b;              // A̅ & B
            4'b0011: return 4'b0000;               // ZERO
            4'b0100: return ~(a & b);              // NAND
            4'b0101: return ~b;                    // NOT B
            4'b0110: return a ^ b;                 // XOR
            4'b0111: return a & (~b);              // A & B̅
            4'b1000: return a & b;                 // AND
            4'b1001: return ~(a ^ b);              // XNOR
            4'b1010: return b;                     // B
            4'b1011: return (~a) | b;              // A̅ | B
            4'b1100: return 4'b1111;               // ONE
            4'b1101: return a | (~b);              // A | B̅
            4'b1110: return a | b;                 // OR
            4'b1111: return a;                     // A
            default: return 4'bxxxx;
        endcase
    endfunction
    
    // Função para calcular o resultado esperado no modo aritmético
    function [4:0] calc_arith_expected(input [3:0] sel, input [3:0] a, input [3:0] b, input c_in);
        case(sel)
            4'b0000: return a + 4'b1111 + c_in;                             // A - 1 + Cin
            4'b0001: return a + b + c_in;                                   // A + B + Cin
            4'b0010: return a + (~b) + c_in;                                // A + ~B + Cin
            4'b0011: return 4'b1111 + c_in;                                 // -1 + Cin
            4'b0100: return a + (a & ~b) + c_in;                            // A + (A & ~B) + Cin
            4'b0101: return (a | b) + (a & ~b) + c_in;                      // (A | B) + (A & ~B) + Cin
            4'b0110: return a + (~b) + 4'b1111 + c_in;                      // A - B - 1 + Cin
            4'b0111: return (a & ~b) + 4'b1111 + c_in;                      // (A & ~B) - 1 + Cin
            4'b1000: return a + a + c_in;                                   // A + A + Cin
            4'b1001: return a + (a | b) + c_in;                             // A + (A | B) + Cin
            4'b1010: return a + (a | ~b) + c_in;                            // A + (A | ~B) + Cin
            4'b1011: return a + 4'b1111 + c_in;                             // A - 1 + Cin
            4'b1100: return a + (a & b) + c_in;                             // A + (A & B) + Cin
            4'b1101: return (a | b) + (a & b) + c_in;                       // (A | B) + (A & B) = A + B + (A & B) + Cin
            4'b1110: return (a | ~b) + (a & b) + c_in;                      // (A | ~B) + (A & B) + Cin
            4'b1111: return a + c_in;                                       // A + Cin
            default: return 5'bxxxxx;
        endcase
    endfunction
    
    initial begin
        $dumpfile("ula_74181.vcd");
        $dumpvars(0, tb_ula_74181);
        
        $display("=== Testbench ULA 74181 ===");
        $display("Testando todas as 32 funcoes (16 logicas + 16 aritmeticas)");
        $display("Formato: Modo | S | A | B | Cin || F | A=B | Cout");
        $display("--------------------------------------------------------");
        
        // Teste das funções lógicas (m = 1)
        m = 1'b1;
        c_in = 1'b0;
        
        $display("\n=== MODO LOGICO (M=1) ===");
        
        for (fn = 0; fn < 16; fn = fn + 1) begin
            s = fn[3:0];
            $display("\nFuncao S=%04b: %s", s, get_logic_function(s));
            
            for (i = 0; i < 5; i = i + 1) begin
                case (i)
                    0: begin a = 4'h0; b = 4'h0; end
                    1: begin a = 4'hF; b = 4'h0; end
                    2: begin a = 4'hA; b = 4'h5; end
                    3: begin a = 4'h5; b = 4'hA; end
                    4: begin a = 4'h3; b = 4'h3; end
                endcase
                
                #10;
                $display("  LOG  | %04b | %04b | %04b | %b || %04b | %b | %b", 
                        s, a, b, c_in, f, a_eq_b, c_out);
                
                // Verificação automática para todas as funções lógicas
                if (f !== calc_logic_expected(s, a, b)) 
                    $display("Erro: S=%04b, A=%04b, B=%04b, F esperado=%04b, obtido=%04b", 
                             s, a, b, calc_logic_expected(s, a, b), f);
                if (c_out !== 1'b0)
                    $display("Erro: S=%04b, Cout esperado=0, obtido=%b", s, c_out);
                if (a_eq_b !== (a == b))
                    $display("Erro: S=%04b, A=%04b, B=%04b, A=B esperado=%b, obtido=%b", 
                             s, a, b, (a == b), a_eq_b);
            end
            
            // Teste com Cin=1 no modo lógico
            c_in = 1'b1;
            a = 4'hA; b = 4'h5;
            #10;
            $display("  LOG  | %04b | %04b | %04b | %b || %04b | %b | %b (Cin=1, deve ignorar)", 
                    s, a, b, c_in, f, a_eq_b, c_out);
            if (f !== calc_logic_expected(s, a, b)) 
                $display("Erro: S=%04b, A=%04b, B=%04b, Cin=1, F esperado=%04b, obtido=%04b", 
                         s, a, b, calc_logic_expected(s, a, b), f);
            c_in = 1'b0;
        end
        
        // Teste das funções aritméticas (m = 0)
        m = 1'b0;
        
        $display("\n=== MODO ARITMETICO (M=0) ===");
        
        for (fn = 0; fn < 16; fn = fn + 1) begin
            s = fn[3:0];
            $display("\nFuncao S=%04b: %s", s, get_arith_function(s));
            
            for (i = 0; i < 6; i = i + 1) begin
                case (i)
                    0: begin a = 4'h0; b = 4'h0; c_in = 1'b0; end
                    1: begin a = 4'hF; b = 4'h1; c_in = 1'b0; end
                    2: begin a = 4'h5; b = 4'h3; c_in = 1'b0; end
                    3: begin a = 4'hA; b = 4'hA; c_in = 1'b1; end
                    4: begin a = 4'hF; b = 4'hF; c_in = 1'b1; end
                    5: begin a = 4'h5; b = 4'hA; c_in = 1'b0; end
                endcase
                
                #10;
                $display("  ARI  | %04b | %04b | %04b | %b || %04b | %b | %b", 
                        s, a, b, c_in, f, a_eq_b, c_out);
                
                // Verificação automática para todas as funções aritméticas
                begin
                    reg [4:0] expected;
                    expected = calc_arith_expected(s, a, b, c_in);
                    if ({c_out, f} !== expected)
                        $display("Erro: S=%04b, A=%04b, B=%04b, Cin=%b, F esperado=%04b, Cout esperado=%b, obtido F=%04b, Cout=%b", 
                                 s, a, b, c_in, expected[3:0], expected[4], f, c_out);
                    if (a_eq_b !== (a == b))
                        $display("Erro: S=%04b, A=%04b, B=%04b, A=B esperado=%b, obtido=%b", 
                                 s, a, b, (a == b), a_eq_b);
                end
            end
        end

        $display("\n=== Teste de Comparacao A=B no Modo Logico ===");
        m = 1'b1;
        s = 4'b0000;
        
        for (i = 0; i < 4; i = i + 1) begin
            a = i[3:0];
            b = i[3:0];
            #10;
            $display("A=%04b, B=%04b, A=B=%b (esperado: 1)", a, b, a_eq_b);
            if (a_eq_b !== 1)
                $display("Erro: A=%04b, B=%04b, A=B esperado=1, obtido=%b", a, b, a_eq_b);
            
            b = ~i[3:0];
            #10;
            $display("A=%04b, B=%04b, A=B=%b (esperado: 0)", a, b, a_eq_b);
            if (a_eq_b !== 0)
                $display("Erro: A=%04b, B=%04b, A=B esperado=0, obtido=%b", a, b, a_eq_b);
        end
        
        $display("\n=== Teste de Comparacao A=B no Modo Aritmetico ===");
        m = 1'b0;
        s = 4'b0000;
        
        for (i = 0; i < 4; i = i + 1) begin
            a = i[3:0];
            b = i[3:0];
            #10;
            $display("A=%04b, B=%04b, A=B=%b (esperado: 1)", a, b, a_eq_b);
            if (a_eq_b !== 1)
                $display("Erro: A=%04b, B=%04b, A=B esperado=1, obtido=%b", a, b, a_eq_b);
            
            b = ~i[3:0];
            #10;
            $display("A=%04b, B=%04b, A=B=%b (esperado: 0)", a, b, a_eq_b);
            if (a_eq_b !== 0)
                $display("Erro: A=%04b, B=%04b, A=B esperado=0, obtido=%b", a, b, a_eq_b);
        end
        
        $display("\n=== Simulacao Concluida ===");
        #100;
        $finish;
    end

endmodule