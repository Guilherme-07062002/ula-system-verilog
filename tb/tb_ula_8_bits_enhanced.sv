`timescale 1ns/1ps

module tb_ula_8_bits_enhanced;

    // Sinais de entrada
    reg [7:0] a, b;
    reg [3:0] s;
    reg m, c_in;
    
    // Sinais de saída
    wire [7:0] f;
    wire a_eq_b, c_out, overflow;
    wire p, g;
    
    // Instanciação da ULA aprimorada de 8 bits
    ula_8_bits_enhanced uut (
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
    
    // Variáveis para a verificação
    reg [7:0] expected_f;
    reg expected_cout, expected_overflow;
    integer errors, total_tests;

    // Teste inicial
    initial begin
        // Inicialização de sinais
        a = 8'h00;
        b = 8'h00;
        s = 4'b0000;
        m = 1'b0;
        c_in = 1'b0;
        errors = 0;
        total_tests = 0;
        
        // Aguardar estabilização
        #10;
        
        $display("=== Testbench ULA 8 bits Aprimorada ===");
        $display("Testando operações específicas");
        
        // Teste de operações aritméticas
        
        // ADIÇÃO (M=0, S=1001)
        m = 0; s = 4'b1001; c_in = 0;
        a = 8'h05; b = 8'h03;
        expected_f = 8'h08; expected_cout = 0; expected_overflow = 0;
        #10;
        test_operation("Adição simples", a, b, s, m, c_in, expected_f, expected_cout, expected_overflow);
        
        // ADIÇÃO COM OVERFLOW POSITIVO
        a = 8'h7F; b = 8'h01;
        expected_f = 8'h80; expected_cout = 0; expected_overflow = 1;
        #10;
        test_operation("Adição com overflow positivo", a, b, s, m, c_in, expected_f, expected_cout, expected_overflow);
        
        // ADIÇÃO COM CARRY OUT
        a = 8'hFF; b = 8'h01;
        expected_f = 8'h00; expected_cout = 1; expected_overflow = 0;
        #10;
        test_operation("Adição com carry out", a, b, s, m, c_in, expected_f, expected_cout, expected_overflow);
        
        // SUBTRAÇÃO (M=0, S=0110, Cin=1)
        m = 0; s = 4'b0110; c_in = 1;
        a = 8'h0A; b = 8'h05;
        expected_f = 8'h05; expected_cout = 0; expected_overflow = 0;
        #10;
        test_operation("Subtração", a, b, s, m, c_in, expected_f, expected_cout, expected_overflow);
        
        // SUBTRAÇÃO COM RESULTADO NEGATIVO
        a = 8'h00; b = 8'h01;
        expected_f = 8'hFF; expected_cout = 1; expected_overflow = 0;
        #10;
        test_operation("Subtração com resultado negativo", a, b, s, m, c_in, expected_f, expected_cout, expected_overflow);
        
        // SUBTRAÇÃO COM OVERFLOW
        a = 8'h80; b = 8'h01;
        expected_f = 8'h7F; expected_cout = 0; expected_overflow = 1;
        #10;
        test_operation("Subtração com overflow", a, b, s, m, c_in, expected_f, expected_cout, expected_overflow);
        
        // OPERAÇÕES LÓGICAS
        // AND (M=1, S=1000)
        m = 1; s = 4'b1000; c_in = 0;
        a = 8'hAA; b = 8'h55;
        expected_f = 8'h00; expected_cout = 0; expected_overflow = 0;
        #10;
        test_operation("AND lógico", a, b, s, m, c_in, expected_f, expected_cout, expected_overflow);
        
        // OR (M=1, S=1110)
        m = 1; s = 4'b1110; c_in = 0;
        a = 8'hAA; b = 8'h55;
        expected_f = 8'hFF; expected_cout = 0; expected_overflow = 0;
        #10;
        test_operation("OR lógico", a, b, s, m, c_in, expected_f, expected_cout, expected_overflow);
        
        // XOR (M=1, S=0110)
        m = 1; s = 4'b0110; c_in = 0;
        a = 8'hAA; b = 8'h55;
        expected_f = 8'hFF; expected_cout = 0; expected_overflow = 0;
        #10;
        test_operation("XOR lógico", a, b, s, m, c_in, expected_f, expected_cout, expected_overflow);
        
        // Teste de igualdade (a_eq_b)
        m = 1; s = 4'b1001; c_in = 0;
        a = 8'h55; b = 8'h55;
        #10;
        $display("Teste de igualdade: A=%h, B=%h, A_EQ_B=%b (esperado: 1)", a, b, a_eq_b);
        if (a_eq_b !== 1) begin
            errors += 1;
            $display("ERRO: A_EQ_B deveria ser 1 quando A=B");
        end
        total_tests += 1;
        
        a = 8'h55; b = 8'hAA;
        #10;
        $display("Teste de igualdade: A=%h, B=%h, A_EQ_B=%b (esperado: 0)", a, b, a_eq_b);
        if (a_eq_b !== 0) begin
            errors += 1;
            $display("ERRO: A_EQ_B deveria ser 0 quando A!=B");
        end
        total_tests += 1;
        
        // Teste de Carry Look-ahead (sinais P e G)
        m = 0; s = 4'b1001; c_in = 0;
        a = 8'h0F; b = 8'hF0;
        #10;
        $display("Teste de Carry Look-ahead: A=%h, B=%h, P=%b, G=%b (esperado: P=1, G=0)", a, b, p, g);
        if (p !== 1 || g !== 0) begin
            errors += 1;
            $display("ERRO: Carry Look-ahead errado para P=1, G=0");
        end
        total_tests += 1;
        
        a = 8'hFF; b = 8'h01;
        #10;
        $display("Teste de Carry Look-ahead: A=%h, B=%h, P=%b, G=%b (esperado: P=1, G=1)", a, b, p, g);
        if (p !== 1 || g !== 1) begin
            errors += 1;
            $display("ERRO: Carry Look-ahead errado para P=1, G=1");
        end
        total_tests += 1;
        
        // Resultados do teste
        $display("=== Resultados do Teste ===");
        $display("Total de testes:         %d", total_tests);
        $display("Total de erros:          %d", errors);
        
        if (errors == 0)
            $display("SUCESSO: Todos os testes passaram!");
        else
            $display("FALHA:          %d erros detectados.", errors);
        
        // Configurações para visualização de formas de onda
        $dumpfile("../sim/ula_8_bits_enhanced.vcd");
        $dumpvars(0, tb_ula_8_bits_enhanced);
        
        $display("=== Simulação Concluída ===");
        $finish;
    end
    
    // Tarefa para testar uma operação
    task test_operation;
        input [8*20:1] operation_name;
        input [7:0] test_a, test_b;
        input [3:0] test_s;
        input test_m, test_cin;
        input [7:0] exp_f;
        input exp_cout, exp_ovf;
        
        begin
            $display("Teste: %0s", operation_name);
            $display("  A=%h, B=%h, M=%b, S=%b, Cin=%b", 
                    test_a, test_b, test_m, test_s, test_cin);
            $display("  Esperado: F=%h, Cout=%b, OVF=%b", 
                    exp_f, exp_cout, exp_ovf);
            $display("  Obtido:   F=%h, Cout=%b, OVF=%b %s", 
                    f, c_out, overflow, 
                    ((f === exp_f && c_out === exp_cout && overflow === exp_ovf) ? "OK" : "ERRO"));
            
            if (f !== exp_f || c_out !== exp_cout || overflow !== exp_ovf) begin
                errors += 1;
                $display("  ERRO: Resultado incorreto!");
            end
            total_tests += 1;
        end
    endtask

endmodule
