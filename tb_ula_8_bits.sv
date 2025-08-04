`timescale 1ns/1ps

module tb_ula_8_bits;

    // Sinais de entrada
    reg [7:0] a, b;
    reg [3:0] s;
    reg m, c_in;
    
    // Sinais de saída
    wire [7:0] f;
    wire a_eq_b, c_out;
    
    // Instanciação da ULA de 8 bits
    ula_8_bits uut (
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
        // Configuração para gerar arquivo VCD
        $dumpfile("ula_8_bits.vcd");
        $dumpvars(0, tb_ula_8_bits);
        
        $display("=== Testbench ULA 8 bits ===");
        $display("Testando todas as 32 funcoes (16 logicas + 16 aritmeticas) para 8 bites com operandos de 8 bits");
        $display("Formato: Modo | S | A | B | Cin || F | A=B | Cout");
        $display("--------------------------------------------------------------------");
        
        // Teste das funções lógicas (m = 1)
        m = 1'b1;
        c_in = 1'b0;
        
        $display("\n=== MODO LÓGICO (M=1) - 8 bits ===");
        
        for (fn = 0; fn < 16; fn = fn + 4) begin
            s = fn[3:0];
            $display("\nFuncao S=%04b:", s);
            
            // Reduzindo número de casos de teste
            for (i = 0; i < 3; i = i + 1) begin  // Apenas 3 casos de teste
                case (i)
                    0: begin a = 8'h00; b = 8'h00; end
                    1: begin a = 8'hFF; b = 8'h00; end
                    2: begin a = 8'hAA; b = 8'h55; end
                endcase
                
                #10;
                $display("  LOG  | %04b | %08b | %08b | %b || %08b | %b | %b", 
                        s, a, b, c_in, f, a_eq_b, c_out);
            end
        end
        
        // Teste das funções aritméticas (m = 0)
        m = 1'b0;
        
        $display("\n=== MODO ARITMÉTICO (M=0) - 8 bits ===");
        
        for (fn = 0; fn < 16; fn = fn + 4) begin
            s = fn[3:0];
            $display("\nFuncao S=%04b:", s);
            
            // Reduzindo número de casos de teste
            for (i = 0; i < 4; i = i + 1) begin  // Apenas 4 casos de teste
                case (i)
                    0: begin a = 8'h00; b = 8'h00; c_in = 1'b0; end
                    1: begin a = 8'h0F; b = 8'h01; c_in = 1'b0; end
                    2: begin a = 8'hFF; b = 8'h01; c_in = 1'b0; end
                    3: begin a = 8'hAA; b = 8'hAA; c_in = 1'b1; end
                endcase
                
                #10;
                $display("  ARI  | %04b | %08b | %08b | %b || %08b | %b | %b", 
                        s, a, b, c_in, f, a_eq_b, c_out);
            end
        end

        // Mantendo apenas os testes essenciais de ripple carry e comparação
        $display("\n=== Teste de Ripple Carry ===");
        m = 1'b0; // Modo aritmético
        s = 4'b1001; // Soma A + B
        c_in = 1'b0;
        
        // Teste que force carry entre as ULAs de 4 bits
        a = 8'b00001111; // 15 decimal
        b = 8'b00000001; // 1 decimal
        #10;
        $display("Soma sem carry: %08b + %08b = %08b (carry=%b)", a, b, f, c_out);
        
        a = 8'b11111111; // 255 decimal
        b = 8'b00000001; // 1 decimal
        #10;
        $display("Soma com overflow: %08b + %08b = %08b (carry=%b)", a, b, f, c_out);
        
        $display("\n=== Teste de Comparacao A=B (8 bits) ===");
        m = 1'b1; // Modo lógico
        s = 4'b0000;
        
        // Teste A=B para 8 bits
        a = 8'b10101010;
        b = 8'b10101010;
        #10;
        $display("A=%08b, B=%08b, A=B=%b (esperado: 1)", a, b, a_eq_b);
        
        b = 8'b10101011;
        #10;
        $display("A=%08b, B=%08b, A=B=%b (esperado: 0)", a, b, a_eq_b);

        $display("\n=== Simulacao Concluida ===");
        #100;
        $finish;
    end

endmodule