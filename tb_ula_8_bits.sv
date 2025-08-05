`timescale 1ns/1ps

module tb_ula_8_bits;

    // Sinais de entrada
    reg [7:0] a, b;
    reg [3:0] s;
    reg m, c_in;
    
    // Sinais de saída
    wire [7:0] f;
    wire a_eq_b, c_out, overflow;
    
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
        .overflow(overflow)
    );
    
    initial begin
        // Configuração para gerar arquivo VCD
        $dumpfile("ula_8_bits.vcd");
        $dumpvars(0, tb_ula_8_bits);
        
        $display("=== Testbench ULA 8 bits ===");
        $display("Testando operações específicas para verificar overflow e cascateamento");
        $display("Formato: Modo | S | A | B | Cin || F | A=B | Cout | Overflow");
        
        // Teste de soma com e sem overflow
        m = 1'b0; // Modo aritmético
        s = 4'b0101; // Função A + B + Cin
        c_in = 1'b0;
        
        $display("\n=== Teste de Soma com Ripple Carry e Overflow ===");
        
        // Caso 1: Soma simples sem overflow
        a = 8'h01; b = 8'h02;
        #10;
        $display("Soma sem overflow: %02h + %02h = %02h (Cout=%b, Overflow=%b)", a, b, f, c_out, overflow);
        
        // Caso 2: Soma com carry entre ULAs
        a = 8'h0F; b = 8'h01;
        #10;
        $display("Soma com ripple carry: %02h + %02h = %02h (Cout=%b, Overflow=%b)", a, b, f, c_out, overflow);
        
        // Caso 3: Soma com overflow de sinal (complemento a dois)
        a = 8'h7F; b = 8'h01; // 127 + 1 = 128 (overflow)
        #10;
        $display("Soma com overflow de sinal: %02h + %02h = %02h (Cout=%b, Overflow=%b)", a, b, f, c_out, overflow);
        
        // Caso 4: Soma que causa carry mas não overflow
        a = 8'hFF; b = 8'h01; // 255 + 1 = 0 com carry
        #10;
        $display("Soma com carry: %02h + %02h = %02h (Cout=%b, Overflow=%b)", a, b, f, c_out, overflow);
        
        // Teste de subtração
        s = 4'b1000; // Função A - B + Cin
        
        $display("\n=== Teste de Subtração ===");
        
        // Caso 1: Subtração simples
        a = 8'h0A; b = 8'h05; // 10 - 5 = 5
        #10;
        $display("Subtração sem overflow: %02h - %02h = %02h (Cout=%b, Overflow=%b)", a, b, f, c_out, overflow);
        
        // Caso 2: Subtração com resultado negativo
        a = 8'h05; b = 8'h0A; // 5 - 10 = -5 (complemento a dois)
        #10;
        $display("Subtração com resultado negativo: %02h - %02h = %02h (Cout=%b, Overflow=%b)", a, b, f, c_out, overflow);
        
        // Caso 3: Subtração que causa overflow de sinal
        a = 8'h80; b = 8'h01; // -128 - 1 = -129 (overflow em complemento a dois)
        #10;
        $display("Subtração com overflow de sinal: %02h - %02h = %02h (Cout=%b, Overflow=%b)", a, b, f, c_out, overflow);
        
        // Teste do comparador para 8 bits
        $display("\n=== Teste de Comparação A=B (8 bits) ===");
        
        // Caso 1: A = B, comparação exata
        a = 8'h55; b = 8'h55;
        #10;
        $display("A=B (iguais): A=%02h, B=%02h, A=B=%b (esperado: 1)", a, b, a_eq_b);
        
        // Caso 2: A ≠ B, diferem em 1 bit
        a = 8'h55; b = 8'h54;
        #10;
        $display("A≠B (diferem em LSB): A=%02h, B=%02h, A=B=%b (esperado: 0)", a, b, a_eq_b);
        
        // Caso 3: A ≠ B, diferem em bits MSB
        a = 8'h55; b = 8'hD5;
        #10;
        $display("A≠B (diferem em MSB): A=%02h, B=%02h, A=B=%b (esperado: 0)", a, b, a_eq_b);
        
        $display("\n=== Simulação Concluída ===");
        #100;
        $finish;
    end

endmodule
