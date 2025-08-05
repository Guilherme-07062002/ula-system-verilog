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
        $display("Adição: %d + %d = %d, Cout=%b, Overflow=%b", a, b, f, c_out, overflow);
        
        // 127 + 1 = 128 (teste de overflow positivo)
        a = 8'h7F;
        b = 8'h01;
        #10;
        $display("Adição com overflow positivo: %d + %d = %d, Cout=%b, Overflow=%b", 
                 $signed(a), $signed(b), $signed(f), c_out, overflow);
                 
        // 128 + 127 = 255 (outro teste de overflow)
        a = 8'h80;
        b = 8'h7F;
        #10;
        $display("Adição com overflow: %d + %d = %d, Cout=%b, Overflow=%b", 
                 $signed(a), $signed(b), $signed(f), c_out, overflow);
        
        // 255 + 1 = 0 (com carry)
        a = 8'hFF;
        b = 8'h01;
        #10;
        $display("Adição com carry: %d + %d = %d, Cout=%b, Overflow=%b", 
                 a, b, f, c_out, overflow);
        
        // Test Case 2: Subtração (A - B - 1 + Cin)
        m = 0;         // Modo aritmético
        s = 4'b0110;   // A - B - 1 + Cin
        c_in = 1;      // Com Cin=1, temos A - B
        
        // 10 - 5 = 5
        a = 8'h0A;
        b = 8'h05;
        #10;
        $display("\nSubtração: %d - %d = %d, Cout=%b, Overflow=%b", 
                 a, b, f, c_out, overflow);
        
        // 0 - 1 = -1
        a = 8'h00;
        b = 8'h01;
        #10;
        $display("Subtração: %d - %d = %d, Cout=%b, Overflow=%b", 
                 a, b, $signed(f), c_out, overflow);
        
        // -128 - 1 = 127 (overflow)
        a = 8'h80;
        b = 8'h01;
        #10;
        $display("Subtração com overflow: %d - %d = %d, Cout=%b, Overflow=%b", 
                 $signed(a), $signed(b), $signed(f), c_out, overflow);
        
        // Test Case 3: Operação Lógica (AND)
        m = 1;         // Modo lógico
        s = 4'b1000;   // A AND B
        c_in = 0;
        
        a = 8'hAA;
        b = 8'h55;
        #10;
        $display("\nOperação AND: 0x%h AND 0x%h = 0x%h", a, b, f);
        
        // Test Case 4: Operação Lógica (OR)
        m = 1;         // Modo lógico
        s = 4'b1110;   // A OR B
        
        a = 8'hAA;
        b = 8'h55;
        #10;
        $display("Operação OR: 0x%h OR 0x%h = 0x%h", a, b, f);
        
        // Test Case 5: Operação Lógica (XOR)
        m = 1;         // Modo lógico
        s = 4'b0110;   // A XOR B
        
        a = 8'hAA;
        b = 8'h55;
        #10;
        $display("Operação XOR: 0x%h XOR 0x%h = 0x%h", a, b, f);
        
        // Test Case 6: Teste de igualdade
        m = 1;         // Modo lógico
        s = 4'b1001;   // XNOR (para igualdade)
        
        // Valores iguais
        a = 8'h55;
        b = 8'h55;
        #10;
        $display("\nTeste de igualdade: A=%h, B=%h, A_EQ_B=%b", a, b, a_eq_b);
        
        // Valores diferentes
        a = 8'h55;
        b = 8'hAA;
        #10;
        $display("Teste de igualdade: A=%h, B=%h, A_EQ_B=%b", a, b, a_eq_b);
        
        // Test Case 7: Teste de Carry Look-ahead
        m = 0;         // Modo aritmético
        s = 4'b1001;   // A + B
        c_in = 0;
        
        // Operação que deve ativar P
        a = 8'h0F;
        b = 8'hF0;
        #10;
        $display("\nTeste de Carry Look-ahead: A=%h, B=%h, P=%b, G=%b", a, b, p, g);
        
        // Operação que deve ativar G
        a = 8'hFF;
        b = 8'h01;
        #10;
        $display("Teste de Carry Look-ahead: A=%h, B=%h, P=%b, G=%b", a, b, p, g);
        
        $display("\n=== Simulação Concluída ===");
        #100;
        $finish;
    end

endmodule
