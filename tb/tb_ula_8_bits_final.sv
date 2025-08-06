`timescale 1ns/1ps

module tb_ula_8_bits_final;

    // Sinais de entrada
    reg [7:0] a, b;
    reg [3:0] s;
    reg m, c_in;
    
    // Sinais de saída
    wire [7:0] f;
    wire a_eq_b, c_out, overflow;
    wire p, g;
    
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
    
    // Instanciações separadas de duas ULAs 74181 para comparação
    wire [3:0] f_lsb_ref, f_msb_ref;
    wire c_out_lsb_ref, c_out_msb_ref;
    wire a_eq_b_lsb_ref, a_eq_b_msb_ref;
    wire p_lsb_ref, p_msb_ref, g_lsb_ref, g_msb_ref;
    
    // ULA de referência para os 4 bits menos significativos
    ula_74181 ref_lsb (
        .a(a[3:0]),
        .b(b[3:0]),
        .s(s),
        .m(m),
        .c_in(c_in),
        .f(f_lsb_ref),
        .a_eq_b(a_eq_b_lsb_ref),
        .c_out(c_out_lsb_ref),
        .p(p_lsb_ref),
        .g(g_lsb_ref)
    );
    
    // ULA de referência para os 4 bits mais significativos
    ula_74181 ref_msb (
        .a(a[7:4]),
        .b(b[7:4]),
        .s(s),
        .m(m),
        .c_in(c_out_lsb_ref),
        .f(f_msb_ref),
        .a_eq_b(a_eq_b_msb_ref),
        .c_out(c_out_msb_ref),
        .p(p_msb_ref),
        .g(g_msb_ref)
    );
    
    // Sinais para validação
    wire [7:0] f_ref;
    wire a_eq_b_ref, c_out_ref;
    wire p_ref, g_ref;
    
    // Combinando os resultados das duas ULAs de referência
    assign f_ref = {f_msb_ref, f_lsb_ref};
    assign a_eq_b_ref = a_eq_b_lsb_ref & a_eq_b_msb_ref;
    assign c_out_ref = c_out_msb_ref;
    assign p_ref = p_lsb_ref & p_msb_ref;
    assign g_ref = g_msb_ref | (p_msb_ref & g_lsb_ref);
    
    // Cálculo de overflow esperado
    wire overflow_ref;
    wire is_add, is_sub;
    
    assign is_add = (m == 1'b0) && (s == 4'b1001);
    assign is_sub = (m == 1'b0) && (s == 4'b0110);
    
    assign overflow_ref = (m == 1'b1) ? 1'b0 : 
                         (is_add) ? ((a[7] == b[7]) && (a[7] != f_ref[7])) :
                         (is_sub) ? ((a[7] != b[7]) && (f_ref[7] == b[7])) : 1'b0;
    
    // Variáveis para estatísticas de teste
    integer errors = 0;
    integer tests = 0;
    
    // Função para verificar operações
    task check_operation;
        input [7:0] a_val, b_val;
        input [3:0] s_val;
        input m_val, c_in_val;
        begin
            a = a_val;
            b = b_val;
            s = s_val;
            m = m_val;
            c_in = c_in_val;
            
            #10; // Tempo para estabilização
            
            tests = tests + 1;
            
            // Verificação comparando nossa implementação com as ULAs de referência
            if (f !== f_ref || c_out !== c_out_ref || a_eq_b !== a_eq_b_ref || 
                p !== p_ref || g !== g_ref || overflow !== overflow_ref) begin
                errors = errors + 1;
                $display("| %1b | %04b | %02h | %02h |  %1b  | %02h | %02h |  %1b   |    %1b     |  %1b  |   %1b    | ERRO |", m_val, s_val, a_val, b_val, c_in_val, f, f_ref, c_out, c_out_ref, overflow, overflow_ref);
            end else begin
                $display("| %1b | %04b | %02h | %02h |  %1b  | %02h | %02h |  %1b   |    %1b     |  %1b  |   %1b    | OK |", m_val, s_val, a_val, b_val, c_in_val, f, f_ref, c_out, c_out_ref, overflow, overflow_ref);
            end
        end
    endtask
    
    // Função para testar uma operação específica com múltiplos valores
    task test_operation;
        input [3:0] s_val;
        input m_val;
        begin
        $display("\nTestando operacao: M=%b, S=%04b", m_val, s_val);
            
            // Testamos com carry in 0 e 1
            for (int ci = 0; ci <= 1; ci = ci + 1) begin
                // Casos de teste variados
                check_operation(8'h00, 8'h00, s_val, m_val, ci);
                check_operation(8'hFF, 8'h00, s_val, m_val, ci);
                check_operation(8'h00, 8'hFF, s_val, m_val, ci);
                check_operation(8'hAA, 8'h55, s_val, m_val, ci);
                check_operation(8'h0F, 8'hF0, s_val, m_val, ci);
                check_operation(8'hFF, 8'hFF, s_val, m_val, ci);
                
                // Casos de teste específicos para overflow
                if (m_val == 0 && (s_val == 4'b1001 || s_val == 4'b0110)) begin
                    // Casos específicos para adição (S=1001)
                    if (s_val == 4'b1001) begin
                        check_operation(8'h7F, 8'h01, s_val, m_val, ci); // Positivo + positivo = negativo (overflow)
                        check_operation(8'h80, 8'h80, s_val, m_val, ci); // Negativo + negativo = positivo (overflow)
                    end
                    // Casos específicos para subtração (S=0110)
                    if (s_val == 4'b0110) begin
                        check_operation(8'h80, 8'h01, s_val, m_val, ci); // Negativo - positivo = positivo (overflow)
                        check_operation(8'h7F, 8'hFF, s_val, m_val, ci); // Positivo - negativo = negativo (overflow)
                    end
                end
            end
        end
    endtask
    
    // Teste principal
    initial begin
        $dumpfile("../sim/ula_8_bits_final.vcd");
        $dumpvars(0, tb_ula_8_bits_final);
        
        $display("=== Testbench Final da ULA de 8 bits ===");
        
        // Testes no modo lógico (M=1)
        for (int op = 0; op < 16; op = op + 1) begin
            test_operation(op, 1);
        end
        
        // Testes no modo aritmético (M=0)
        for (int op = 0; op < 16; op = op + 1) begin
            test_operation(op, 0);
        end
        
        // Testes específicos para ripple carry
        $display("\n=== Testes Especificos de Ripple Carry ===");
        
        // Adição que propaga carry do LSB para o MSB
        s = 4'b1001; // A + B
        m = 0;       // Modo aritmético
        c_in = 0;
        a = 8'h0F;
        b = 8'h01;
        #10;
        $display("Ripple carry: A=%02h + B=%02h = F=%02h, Cout=%b, OVF=%b", a, b, f, c_out, overflow);
        if (f === 8'h10 && c_out === 0 && overflow === 0) begin
            $display("  PASSOU: Ripple carry funcionando corretamente");
        end else begin
            $display("  FALHOU: Ripple carry incorreto");
            errors = errors + 1;
        end
        
        // Overflow na adição
        a = 8'h7F;
        b = 8'h01;
        #10;
        $display("Overflow positivo-para-negativo: A=%02h + B=%02h = F=%02h, Cout=%b, OVF=%b", a, b, f, c_out, overflow);
        if (f === 8'h80 && overflow === 1) begin
            $display("  PASSOU: Deteccao de overflow funcionando corretamente");
        end else begin
            $display("  FALHOU: Deteccao de overflow incorreta");
            errors = errors + 1;
        end
        
        // Resultado final
        $display("\n=== Resultados do Teste ===");
        $display("Total de testes: %d", tests + 2);
        $display("Total de erros: %d", errors);
        
        if (errors == 0) begin
        $display("SUCESSO: Todos os testes passaram!");
        end else begin
        $display("FALHA: %d erros detectados.", errors);
        end
        
        $finish;
    end
    
endmodule
