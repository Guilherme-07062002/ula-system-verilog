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
        
        for (fn = 0; fn < 16; fn = fn + 1) begin  // Alterado: testar todas as 16 funções
            s = fn[3:0];
            $display("\nFuncao S=%04b:", s);
            
            // Reduzindo número de casos de teste
            for (i = 0; i < 3; i = i + 1) begin
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
        
        $display("\n=== MODO ARITMETICO (M=0) - 8 bits ===");
        
        for (fn = 0; fn < 16; fn = fn + 1) begin
            s = fn[3:0];
            
            // Corrigir descrições para corresponder às operações implementadas na ULA 74181
            case (s)
                4'b0000: $display("\nFuncao S=%04b: A MINUS 1 + Cin (A + ~0 + Cin)", s);
                4'b0001: $display("\nFuncao S=%04b: A PLUS B + Cin (A + B + Cin)", s);
                4'b0010: $display("\nFuncao S=%04b: A PLUS ~B + Cin (A - B - 1 + Cin)", s);
                4'b0011: $display("\nFuncao S=%04b: MINUS 1 + Cin (~0 + Cin = -1 + Cin)", s);
                4'b0100: $display("\nFuncao S=%04b: A PLUS (A AND ~B) + Cin", s);
                4'b0101: $display("\nFuncao S=%04b: (A OR B) PLUS (A AND ~B) + Cin", s);
                4'b0110: $display("\nFuncao S=%04b: A MINUS B MINUS 1 + Cin", s);
                4'b0111: $display("\nFuncao S=%04b: (A AND ~B) MINUS 1 + Cin", s);
                4'b1000: $display("\nFuncao S=%04b: A PLUS (A AND B) + Cin", s);
                4'b1001: $display("\nFuncao S=%04b: A PLUS B + Cin (A + B + Cin)", s);
                4'b1010: $display("\nFuncao S=%04b: (A OR ~B) PLUS (A AND B) + Cin", s);
                4'b1011: $display("\nFuncao S=%04b: A MINUS 1 + Cin (A + ~0 + Cin)", s);
                4'b1100: $display("\nFuncao S=%04b: A PLUS A + Cin (2A + Cin)", s);
                4'b1101: $display("\nFuncao S=%04b: (A OR B) PLUS A + Cin", s);
                4'b1110: $display("\nFuncao S=%04b: (A OR ~B) PLUS A + Cin", s);
                4'b1111: $display("\nFuncao S=%04b: A MINUS 1 + Cin (A + ~0 + Cin)", s);
                default: $display("\nFuncao S=%04b: Desconhecida", s);
            endcase
            
            // Casos de teste para funções aritméticas
            for (i = 0; i < 8; i = i + 1) begin
                case (i)
                    0: begin a = 8'h00; b = 8'h00; c_in = 1'b0; end  // Caso base
                    1: begin a = 8'h0F; b = 8'h01; c_in = 1'b0; end  // Teste LSB
                    2: begin a = 8'hFF; b = 8'h01; c_in = 1'b0; end  // Overflow
                    3: begin a = 8'hAA; b = 8'hAA; c_in = 1'b1; end  // Números iguais com carry
                    4: begin a = 8'h0F; b = 8'hF0; c_in = 1'b0; end  // Teste propagação entre ULAs
                    5: begin a = 8'h7F; b = 8'h01; c_in = 1'b0; end  // Teste carry entre ULAs
                    6: begin a = 8'hFF; b = 8'hFF; c_in = 1'b1; end  // Máximo overflow
                    7: begin a = 8'h55; b = 8'hAA; c_in = 1'b0; end  // Padrão alternado
                endcase
                
                #10;
                $display("  ARI  | %04b | %08b | %08b | %b || %08b | %b | %b", 
                        s, a, b, c_in, f, a_eq_b, c_out);
            end
        end

        // Mantendo apenas os testes essenciais de ripple carry e comparação
        $display("\n=== Teste de Ripple Carry ===");
        m = 1'b0; // Modo aritmético
        s = 4'b0101; // Soma A + B (função direta de soma)
        c_in = 1'b0;

        // Teste que force carry entre as ULAs de 4 bits
        a = 8'b00001111; // 15 decimal
        b = 8'b00000001; // 1 decimal
        #10;
        $display("Soma sem overflow: %08b + %08b = %08b (carry=%b) - Esperado: 00010000", a, b, f, c_out);     

        a = 8'b11111111; // 255 decimal
        b = 8'b00000001; // 1 decimal
        #10;
        $display("Soma com overflow: %08b + %08b = %08b (carry=%b) - Esperado: 00000000 com carry=1", a, b, f, c_out);  

        // Teste de propagação de carry através das ULAs
        a = 8'b00001111; // 15 decimal - todos os bits LSB em 1
        b = 8'b00010000; // 16 decimal - primeiro bit MSB em 1
        #10;
        $display("Propagação de carry: %08b + %08b = %08b (carry=%b) - Esperado: 00011111", a, b, f, c_out);        $display("\n=== Teste de Comparacao A=B (8 bits) ===");
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