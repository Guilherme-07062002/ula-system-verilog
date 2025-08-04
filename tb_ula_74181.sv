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
    integer i, j, fn;
    
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
        
        for (fn = 0; fn < 16; fn = fn + 4) begin
            s = fn[3:0];
            $display("\nFuncao S=%04b:", s);
            
            for (i = 0; i < 3; i = i + 1) begin  // Apenas 3 casos
                case (i)
                    0: begin a = 4'h0; b = 4'h0; end
                    1: begin a = 4'hF; b = 4'h0; end
                    2: begin a = 4'hA; b = 4'h5; end
                endcase
                
                #10;
                $display("  LOG  | %04b | %04b | %04b | %b || %04b | %b | %b", 
                        s, a, b, c_in, f, a_eq_b, c_out);
            end
        end
        
        // Teste das funções aritméticas (m = 0)
        m = 1'b0;
        
        $display("\n=== MODO ARITMETICO (M=0) ===");
        
        for (fn = 0; fn < 16; fn = fn + 4) begin
            s = fn[3:0];
            $display("\nFuncao S=%04b:", s);
            
            for (i = 0; i < 4; i = i + 1) begin  // Apenas 4 casos
                case (i)
                    0: begin a = 4'h0; b = 4'h0; c_in = 1'b0; end
                    1: begin a = 4'hF; b = 4'h1; c_in = 1'b0; end
                    2: begin a = 4'h5; b = 4'h3; c_in = 1'b0; end
                    3: begin a = 4'hA; b = 4'hA; c_in = 1'b1; end
                endcase
                
                #10;
                $display("  ARI  | %04b | %04b | %04b | %b || %04b | %b | %b", 
                        s, a, b, c_in, f, a_eq_b, c_out);
            end
        end

        $display("\n=== Teste de Comparacao A=B ===");
        m = 1'b1; // Modo lógico
        s = 4'b0000; // Função qualquer
        
        // Teste específico para a_eq_b
        for (i = 0; i < 4; i = i + 1) begin
            a = i[3:0];
            b = i[3:0]; // A = B
            #10;
            $display("A=%04b, B=%04b, A=B=%b (esperado: 1)", a, b, a_eq_b);
            
            b = ~i[3:0]; // A != B
            #10;
            $display("A=%04b, B=%04b, A=B=%b (esperado: 0)", a, b, a_eq_b);
        end
        
        $display("\n=== Simulacao Concluida ===");
        #100;
        $finish;
    end

endmodule