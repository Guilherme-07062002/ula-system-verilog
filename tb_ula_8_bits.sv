module tb_ula_8_bits;

    // Sinais para conectar ao DUT (Device Under Test)
    reg [7:0] a, b;
    reg [3:0] s;
    reg       m;
    reg       c_in;
    wire [7:0] f;
    wire       a_eq_b;
    wire       c_out;

    // Instanciação da ULA de 8 bits
    ula_8_bits dut_8_bits (
        .a(a),
        .b(b),
        .s(s),
        .m(m),
        .c_in(c_in),
        .f(f),
        .a_eq_b(a_eq_b),
        .c_out(c_out)
    );

    // Configuração para geração de arquivo VCD
    initial begin
        $dumpfile("ula_8_bits.vcd");
        $dumpvars(0, tb_ula_8_bits); // Dump all signals in the current scope
    end

    initial begin
        $display("---------------------------------------------------------------------------------------------------------------------------------------------");
        $display("Iniciando simulação da ULA de 8 bits");
        $display("m | s    | a        | b        | c_in | f        | c_out | a_eq_b | Operação");
        $display("---------------------------------------------------------------------------------------------------------------------------------------------");

        // Loop para testar todas as 32 funções
        for (m = 0; m <= 1; m = m + 1) begin // Modo (0: Aritmético, 1: Lógico)
            for (s = 0; s <= 15; s = s + 1) begin // Seleção de Função (0 a 15)
                // Testar com diferentes valores de A, B e C_in de 8 bits

                // Exemplo 1: Valores básicos
                a = 8'h3F; // 63
                b = 8'h0A; // 10
                c_in = 1'b0;
                #10;
                $display("%b | %b | %h     | %h     | %b    | %h     | %b     | %b      | Teste 1", m, s, a, b, c_in, f, c_out, a_eq_b);

                // Exemplo 2: Valores maiores e carry-in
                a = 8'hF0; // 240
                b = 8'h1C; // 28
                c_in = 1'b1;
                #10;
                $display("%b | %b | %h     | %h     | %b    | %h     | %b     | %b      | Teste 2", m, s, a, b, c_in, f, c_out, a_eq_b);

                // Exemplo 3: Borda de valores (máximo)
                a = 8'hFF; // 255
                b = 8'h01; // 1
                c_in = 1'b0;
                #10;
                $display("%b | %b | %h     | %h     | %b    | %h     | %b     | %b      | Teste 3", m, s, a, b, c_in, f, c_out, a_eq_b);

                // Exemplo 4: Igualdade de A e B
                a = 8'hAA; // 170
                b = 8'hAA; // 170
                c_in = 1'b0;
                #10;
                $display("%b | %b | %h     | %h     | %b    | %h     | %b     | %b      | Teste 4", m, s, a, b, c_in, f, c_out, a_eq_b);
                
                // Exemplo 5: Teste com carry para o MSB
                a = 8'h0F; // 15
                b = 8'h01; // 1
                c_in = 1'b0;
                m = 0; // Modo aritmético
                s = 4'b0001; // A + B + C_in
                #10;
                $display("%b | %b | %h     | %h     | %b    | %h     | %b     | %b      | Teste 5 (Carry LSB->MSB)", m, s, a, b, c_in, f, c_out, a_eq_b);
                
                a = 8'h10; // 16
                b = 8'h01; // 1
                c_in = 1'b0;
                m = 0; // Modo aritmético
                s = 4'b0001; // A + B + C_in
                #10;
                $display("%b | %b | %h     | %h     | %b    | %h     | %b     | %b      | Teste 6 (No Carry LSB->MSB)", m, s, a, b, c_in, f, c_out, a_eq_b);

                // Adicione mais vetores de teste para cobrir uma gama completa
                // de operações e garantir que o ripple carry esteja funcionando.
            end
        end

        $display("---------------------------------------------------------------------------------------------------------------------------------------------");
        $display("Simulação da ULA de 8 bits concluída.");
        $display("---------------------------------------------------------------------------------------------------------------------------------------------");
        $finish;
    end

endmodule