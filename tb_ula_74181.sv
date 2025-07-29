module tb_ula_74181;

    // Sinais para conectar ao DUT (Device Under Test)
    reg [3:0] a, b;
    reg [3:0] s;
    reg       m;
    reg       c_in;
    wire [3:0] f;
    wire       a_eq_b;
    wire       c_out;

    // Instanciação da ULA 74181
    ula_74181 dut (
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
        $dumpfile("ula_74181.vcd");
        $dumpvars(0, tb_ula_74181); // Dump all signals in the current scope
    end

    initial begin
        $display("---------------------------------------------------------------------------------------------------------------------------------------------");
        $display("Iniciando simulação da ULA 74181 (4 bits)");
        $display("m | s    | a    | b    | c_in | f    | c_out | a_eq_b | Operação");
        $display("---------------------------------------------------------------------------------------------------------------------------------------------");

        // Loop para testar todas as 32 funções
        for (m = 0; m <= 1; m = m + 1) begin // Modo (0: Aritmético, 1: Lógico)
            for (s = 0; s <= 15; s = s + 1) begin // Seleção de Função (0 a 15)
                // Testar com diferentes valores de A, B e C_in
                // Cada função pode precisar de vetores de teste específicos para demonstrar
                // seu comportamento. Aqui, vou usar alguns exemplos.

                // Exemplo 1: Valores básicos
                a = 4'b0101; // 5
                b = 4'b0011; // 3
                c_in = 1'b0;
                #10; // Espera para que a lógica se propague
                $display("%b | %b | %b | %b | %b    | %b | %b     | %b      | Teste 1", m, s, a, b, c_in, f, c_out, a_eq_b);

                // Exemplo 2: Outros valores e carry-in
                a = 4'b1000; // 8
                b = 4'b0111; // 7
                c_in = 1'b1;
                #10;
                $display("%b | %b | %b | %b | %b    | %b | %b     | %b      | Teste 2", m, s, a, b, c_in, f, c_out, a_eq_b);

                // Exemplo 3: Borda de valores
                a = 4'b1111; // 15
                b = 4'b0000; // 0
                c_in = 1'b0;
                #10;
                $display("%b | %b | %b | %b | %b    | %b | %b     | %b      | Teste 3", m, s, a, b, c_in, f, c_out, a_eq_b);

                // Exemplo 4: Igualdade de A e B
                a = 4'b1010; // 10
                b = 4'b1010; // 10
                c_in = 1'b0;
                #10;
                $display("%b | %b | %b | %b | %b    | %b | %b     | %b      | Teste 4", m, s, a, b, c_in, f, c_out, a_eq_b);

                // Adicione mais vetores de teste conforme necessário para cobrir casos específicos
                // de cada uma das 32 funções e suas nuances (ex: overflow, underflow, etc.).
                // Por exemplo, para operações lógicas, teste com A=0, B=0; A=0, B=1; A=1, B=0; A=1, B=1.
            end
        end

        $display("---------------------------------------------------------------------------------------------------------------------------------------------");
        $display("Simulação da ULA 74181 concluída.");
        $display("---------------------------------------------------------------------------------------------------------------------------------------------");
        $finish; // Encerra a simulação
    end

    // Monitoramento contínuo para verificar se todas as saídas estão sendo atualizadas
    // Esta diretiva pode ser útil para depuração, mas $display dentro do loop já fornece o que é pedido.
    // $monitor("m=%b s=%b a=%b b=%b c_in=%b => f=%b c_out=%b a_eq_b=%b", m, s, a, b, c_in, f, c_out, a_eq_b);

endmodule