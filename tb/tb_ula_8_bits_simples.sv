`timescale 1ns/1ps

module tb_ula_8_bits_simples;

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
    
    initial begin
        // Configuração para gerar arquivo VCD na pasta sim/
        $dumpfile("../sim/ula_8_bits_simples.vcd");
        $dumpvars(0, tb_ula_8_bits_simples);
        
        $display("=== Testando ULA de 8 bits - Casos Importantes ===");
        $display("| Operação         |   M   |   S   |   A   |   B   | Cin |   F   | Cout | Overflow | A_EQ_B | P | G |");
        $display("|------------------|-------|-------|-------|-------|-----|-------|------|----------|--------|---|---|");
        
        // Inicializa sinais
        a = 8'h00;
        b = 8'h00;
        s = 4'b0000;
        m = 0;
        c_in = 0;
        
        // Test Case 1: Adição Básica (A + B)
        #10;
        m = 0;         // Modo aritmético
        s = 4'b1001;   // A + B
        c_in = 0;
        
        // 5 + 3 = 8
        a = 8'h05;
        b = 8'h03;
        #10;
        $display("| Adicao           |  %1b   | %04b  | %02h  | %02h  |  %1b  | %02h  |  %1b   |    %1b     |   %1b   | %1b | %1b |", m, s, a, b, c_in, f, c_out, overflow, a_eq_b, p, g);
        
        // 127 + 1 = 128 (teste de overflow positivo)
        a = 8'h7F;
        b = 8'h01;
        #10;
        $display("Adicao com overflow positivo: %d + %d = %d, Cout=%b, Overflow=%b", 
                 $signed(a), $signed(b), $signed(f), c_out, overflow);
        $display("| Adicao ovf+      |  %1b   | %04b  | %02h  | %02h  |  %1b  | %02h  |  %1b   |    %1b     |   %1b   | %1b | %1b |", m, s, a, b, c_in, f, c_out, overflow, a_eq_b, p, g);
                 
        // 128 + 127 = 255 (outro teste de overflow)
        a = 8'h80;
        b = 8'h7F;
        #10;
        $display("Adicao com overflow: %d + %d = %d, Cout=%b, Overflow=%b", 
                 $signed(a), $signed(b), $signed(f), c_out, overflow);
        $display("| Adicao ovf       |  %1b   | %04b  | %02h  | %02h  |  %1b  | %02h  |  %1b   |    %1b     |   %1b   | %1b | %1b |", m, s, a, b, c_in, f, c_out, overflow, a_eq_b, p, g);
        
        // 255 + 1 = 0 (com carry)
        a = 8'hFF;
        b = 8'h01;
        #10;
        $display("Adicao com carry: %d + %d = %d, Cout=%b, Overflow=%b", 
                 a, b, f, c_out, overflow);
        $display("| Adicao carry     |  %1b   | %04b  | %02h  | %02h  |  %1b  | %02h  |  %1b   |    %1b     |   %1b   | %1b | %1b |", m, s, a, b, c_in, f, c_out, overflow, a_eq_b, p, g);
        
        // Test Case 2: Subtração (A - B - 1 + Cin)
        m = 0;         // Modo aritmético
        s = 4'b0110;   // A - B - 1 + Cin
        c_in = 1;      // Com Cin=1, temos A - B
        
        // 10 - 5 = 5
        a = 8'h0A;
        b = 8'h05;
        #10;
        $display("\nSubtracao: %d - %d = %d, Cout=%b, Overflow=%b", 
                 a, b, f, c_out, overflow);
        $display("| Subtracao        |  %1b   | %04b  | %02h  | %02h  |  %1b  | %02h  |  %1b   |    %1b     |   %1b   | %1b | %1b |", m, s, a, b, c_in, f, c_out, overflow, a_eq_b, p, g);
        
        // 0 - 1 = -1
        a = 8'h00;
        b = 8'h01;
        #10;
        $display("Subtracao: %d - %d = %d, Cout=%b, Overflow=%b", 
                 a, b, $signed(f), c_out, overflow);
        $display("| Subtracao neg    |  %1b   | %04b  | %02h  | %02h  |  %1b  | %02h  |  %1b   |    %1b     |   %1b   | %1b | %1b |", m, s, a, b, c_in, f, c_out, overflow, a_eq_b, p, g);
        
        // -128 - 1 = 127 (overflow)
        a = 8'h80;
        b = 8'h01;
        #10;
        $display("Subtracao com overflow: %d - %d = %d, Cout=%b, Overflow=%b", 
                 $signed(a), $signed(b), $signed(f), c_out, overflow);
        $display("| Subtracao ovf    |  %1b   | %04b  | %02h  | %02h  |  %1b  | %02h  |  %1b   |    %1b     |   %1b   | %1b | %1b |", m, s, a, b, c_in, f, c_out, overflow, a_eq_b, p, g);
        
        // Test Case 3: Operação Lógica (AND)
        m = 1;         // Modo lógico
        s = 4'b1000;   // A AND B
        c_in = 0;
        
        a = 8'hAA;
        b = 8'h55;
        #10;
        $display("\nOperacao AND: 0x%h AND 0x%h = 0x%h", a, b, f);
        $display("| AND              |  %1b   | %04b  | %02h  | %02h  |  %1b  | %02h  |  %1b   |    %1b     |   %1b   | %1b | %1b |", m, s, a, b, c_in, f, c_out, overflow, a_eq_b, p, g);
        
        // Test Case 4: Operação Lógica (OR)
        m = 1;         // Modo lógico
        s = 4'b1110;   // A OR B
        
        a = 8'hAA;
        b = 8'h55;
        #10;
        $display("Operacao OR: 0x%h OR 0x%h = 0x%h", a, b, f);
        $display("| OR               |  %1b   | %04b  | %02h  | %02h  |  %1b  | %02h  |  %1b   |    %1b     |   %1b   | %1b | %1b |", m, s, a, b, c_in, f, c_out, overflow, a_eq_b, p, g);
        
        // Test Case 5: Operação Lógica (XOR)
        m = 1;         // Modo lógico
        s = 4'b0110;   // A XOR B
        
        a = 8'hAA;
        b = 8'h55;
        #10;
        $display("Operacao XOR: 0x%h XOR 0x%h = 0x%h", a, b, f);
        $display("| XOR              |  %1b   | %04b  | %02h  | %02h  |  %1b  | %02h  |  %1b   |    %1b     |   %1b   | %1b | %1b |", m, s, a, b, c_in, f, c_out, overflow, a_eq_b, p, g);
        
        // Test Case 6: Teste de igualdade
        m = 1;         // Modo lógico
        s = 4'b1001;   // XNOR (para igualdade)
        
        // Valores iguais
        a = 8'h55;
        b = 8'h55;
        #10;
        $display("\nTeste de igualdade: A=%h, B=%h, A_EQ_B=%b", a, b, a_eq_b);
        $display("| Igualdade        |  %1b   | %04b  | %02h  | %02h  |  %1b  | %02h  |  %1b   |    %1b     |   %1b   | %1b | %1b |", m, s, a, b, c_in, f, c_out, overflow, a_eq_b, p, g);
        
        // Valores diferentes
        a = 8'h55;
        b = 8'hAA;
        #10;
        $display("Teste de igualdade: A=%h, B=%h, A_EQ_B=%b", a, b, a_eq_b);
        $display("| Igualdade dif    |  %1b   | %04b  | %02h  | %02h  |  %1b  | %02h  |  %1b   |    %1b     |   %1b   | %1b | %1b |", m, s, a, b, c_in, f, c_out, overflow, a_eq_b, p, g);
        
        // Test Case 7: Teste de Carry Look-ahead
        m = 0;         // Modo aritmético
        s = 4'b1001;   // A + B
        c_in = 0;
        
        // Operação que deve ativar P
        a = 8'h0F;
        b = 8'hF0;
        #10;
        $display("\nTeste de Carry Look-ahead: A=%h, B=%h, P=%b, G=%b", a, b, p, g);
        $display("| Carry P          |  %1b   | %04b  | %02h  | %02h  |  %1b  | %02h  |  %1b   |    %1b     |   %1b   | %1b | %1b |", m, s, a, b, c_in, f, c_out, overflow, a_eq_b, p, g);
        
        // Operação que deve ativar G
        a = 8'hFF;
        b = 8'h01;
        #10;
        $display("Teste de Carry Look-ahead: A=%h, B=%h, P=%b, G=%b", a, b, p, g);
        $display("| Carry G          |  %1b   | %04b  | %02h  | %02h  |  %1b  | %02h  |  %1b   |    %1b     |   %1b   | %1b | %1b |", m, s, a, b, c_in, f, c_out, overflow, a_eq_b, p, g);
        
        $display("\n=== Simulacao Concluida ===");
        #100;
        $finish;
    end

endmodule
