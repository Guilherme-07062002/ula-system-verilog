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
    integer i, j;
    
    initial begin
        // Configuração para gerar arquivo VCD
        $dumpfile("ula_74181.vcd");
        $dumpvars(0, tb_ula_74181);
        
        $display("=== Testbench ULA 74181 ===");
        $display("Testando todas as 32 funções (16 lógicas + 16 aritméticas)");
        $display("Formato: Modo | S | A | B | Cin || F | A=B | Cout");
        $display("--------------------------------------------------------");
        
        // Teste das funções lógicas (m = 1)
        m = 1'b1;
        c_in = 1'b0; // Carry não usado no modo lógico
        
        $display("\n=== MODO LÓGICO (M=1) ===");
        
        for (s = 0; s < 16; s = s + 1) begin
            $display("\nFunção S=%04b:", s);
            
            // Testa diferentes combinações de A e B
            for (i = 0; i < 4; i = i + 1) begin
                case (i)
                    0: begin a = 4'b0000; b = 4'b0000; end
                    1: begin a = 4'b1111; b = 4'b0000; end
                    2: begin a = 4'b0000; b = 4'b1111; end
                    3: begin a = 4'b1111; b = 4'b1111; end
                endcase
                
                #10;
                $display("  LOG  | %04b | %04b | %04b | %b || %04b | %b | %b", 
                        s, a, b, c_in, f, a_eq_b, c_out);
            end
        end
        
        // Teste das funções aritméticas (m = 0)
        m = 1'b0;
        
        $display("\n=== MODO ARITMÉTICO (M=0) ===");
        
        for (s = 0; s < 16; s = s + 1) begin
            $display("\nFunção S=%04b:", s);
            
            // Testa diferentes combinações de A, B e Cin
            for (i = 0; i < 8; i = i + 1) begin
                case (i)
                    0: begin a = 4'b0000; b = 4'b0000; c_in = 1'b0; end
                    1: begin a = 4'b0000; b = 4'b0000; c_in = 1'b1; end
                    2: begin a = 4'b0101; b = 4'b0011; c_in = 1'b0; end
                    3: begin a = 4'b0101; b = 4'b0011; c_in = 1'b1; end
                    4: begin a = 4'b1111; b = 4'b0001; c_in = 1'b0; end
                    5: begin a = 4'b1111; b = 4'b0001; c_in = 1'b1; end
                    6: begin a = 4'b1010; b = 4'b1010; c_in = 1'b0; end
                    7: begin a = 4'b1010; b = 4'b1010; c_in = 1'b1; end
                endcase
                
                #10;
                $display("  ARI  | %04b | %04b | %04b | %b || %04b | %b | %b", 
                        s, a, b, c_in, f, a_eq_b, c_out);
            end
        end
        
        $display("\n=== Teste de Comparação A=B ===");
        m = 1'b1; // Modo lógico
        s = 4'b0000; // Função qualquer
        
        // Teste específico para a_eq_b
        for (i = 0; i < 16; i = i + 1) begin
            a = i[3:0];
            b = i[3:0]; // A = B
            #10;
            $display("A=%04b, B=%04b, A=B=%b (esperado: 1)", a, b, a_eq_b);
            
            b = ~i[3:0]; // A != B
            #10;
            $display("A=%04b, B=%04b, A=B=%b (esperado: 0)", a, b, a_eq_b);
        end
        
        $display("\n=== Simulação Concluída ===");
        #100;
        $finish;
    end

endmodule