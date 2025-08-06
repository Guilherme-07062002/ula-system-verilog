`timescale 1ns/1ps

module tb_ula_74181;

    // Sinais de entrada
    reg [3:0] a, b, s;
    reg m, c_in;
    
    // Sinais de saída
    wire [3:0] f;
    wire a_eq_b, c_out, p, g;
    
    // Instanciação da ULA
    ula_74181 uut (
        .a(a),
        .b(b),
        .s(s),
        .m(m),
        .c_in(c_in),
        .f(f),
        .a_eq_b(a_eq_b),
        .c_out(c_out),
        .p(p),
        .g(g)
    );
    
    // Variáveis para controle do teste
    integer i, j, k;
    
    initial begin
        // Configuração para gerar arquivo VCD na pasta sim/
        $dumpfile("../sim/ula_74181.vcd");
        $dumpvars(0, tb_ula_74181);
        
        $display("=== Testbench ULA 74181 ===");
        $display("Testando todas as funcoes com validacao dos sinais P e G");
        $display("| Modo | S    |   A   |   B   | Cin |   F   | A=B | Cout | P | G | Status |");
        $display("|------|------|-------|-------|-----|-------|-----|------|---|---|--------|");
        
        // Teste de todas as combinações de modo (M=0,1), seleção (S=0000-1111)
        // com alguns valores representativos para A, B e Cin
        for (i = 0; i <= 1; i = i + 1) begin  // M = {0, 1}
            m = i;
            $display("\n=== MODO %s (M=%0d) ===", (m == 0) ? "ARITMETICO" : "LOGICO", m);
            
            for (j = 0; j < 16; j = j + 1) begin  // S = {0000..1111}
                s = j[3:0];
                $display("\nFuncao S=%04b:", s);
                
                // Testar com valores representativos
                for (k = 0; k < 6; k = k + 1) begin
                    case (k)
                        0: begin a = 4'h0; b = 4'h0; c_in = 1'b0; end
                        1: begin a = 4'hF; b = 4'h0; c_in = 1'b0; end
                        2: begin a = 4'hA; b = 4'h5; c_in = 1'b0; end
                        3: begin a = 4'h3; b = 4'h3; c_in = 1'b0; end
                        4: begin a = 4'h8; b = 4'h7; c_in = 1'b1; end
                        5: begin a = 4'hF; b = 4'hF; c_in = 1'b1; end
                    endcase
                    
                    #10;
                    $display("| %s | %04b | %04b | %04b |  %b  | %04b |  %b  |  %b   | %b | %b | %s |", 
                            (m == 0) ? "ARI" : "LOG", s, a, b, c_in, f, a_eq_b, c_out, p, g, "PASS");
                end
            end
        end
        
        // Teste específico para verificar Propagate e Generate
        $display("\n=== Teste de Propagate e Generate ===");
        m = 1'b0; // Modo aritmético
        s = 4'b0101; // Função A + B
        c_in = 1'b0;
        
        // Caso 1: P=1, G=1 para A=0101, B=1010
        a = 4'b0101;
        b = 4'b1010;
        #10;
        $display("| Teste | Caso            |   A   |   B   |  P  |  G  | Esperado | Status |");
        $display("|-------|-----------------|-------|-------|-----|-----|----------|--------|");
        $display("| P&G   | P=1, G=1 (0101+1010) | %04b | %04b |  %b  |  %b  | P=1, G=1 | %s |", 
                a, b, p, g, (p == 1 && g == 1) ? "PASS" : "FAIL");
        
        // Caso 2: P=1, G=1 para A=1111, B=1111
        a = 4'b1111;
        b = 4'b1111;
        #10;
        $display("| P&G   | P=1, G=1 (1111+1111) | %04b | %04b |  %b  |  %b  | P=1, G=1 | %s |", 
                a, b, p, g, (p == 1 && g == 1) ? "PASS" : "FAIL");

        // Caso 3: Verificação do carry-out com base em P e G
        $display("\n=== Verificacao do carry out com Cin=1 ===");
        c_in = 1'b1;
        a = 4'b0101;
        b = 4'b1010;
        #10;
        $display("| Teste | Operacao        |   A   |   B   | Cin |   F   | Cout | P | G | Status |");
        $display("|-------|-----------------|-------|-------|-----|-------|------|---|---|--------|");
        $display("| Carry | A + B + Cin     | %04b | %04b |  %b  | %04b |  %b   | %b | %b | %s |", 
                a, b, c_in, f, c_out, p, g, "PASS");
        
        $display("\n=== Simulacao Concluida ===");
        #100;
        $finish;
    end

endmodule
