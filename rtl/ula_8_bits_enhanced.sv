`timescale 1ns/1ps

module ula_8_bits_enhanced (
    input [7:0] a,
    input [7:0] b,
    input [3:0] s,
    input       m,
    input       c_in,
    output wire [7:0] f,
    output wire       a_eq_b,
    output wire       c_out,
    output wire       overflow,
    output wire       p,
    output wire       g
);

    // Sinais internos para cascateamento das ULAs de 4 bits
    wire [3:0] f_lsb; // Saída da ULA dos 4 bits menos significativos
    wire       c_out_lsb; // Carry Out da ULA dos 4 bits menos significativos
    wire       a_eq_b_lsb; // A=B da ULA dos 4 bits menos significativos

    wire [3:0] f_msb; // Saída da ULA dos 4 bits mais significativos
    wire       c_out_msb; // Carry Out da ULA dos 4 bits mais significativos
    wire       a_eq_b_msb; // A=B da ULA dos 4 bits mais significativos

    // Sinais para carry look-ahead (P e G)
    wire p_lsb, g_lsb, p_msb, g_msb;

    // Detectar operações aritméticas
    wire is_add = (m == 1'b0) && (s == 4'b1001); // S=1001 é operação A+B
    wire is_sub = (m == 1'b0) && (s == 4'b0110); // S=0110 é operação A-B-1
    wire is_dec = (m == 1'b0) && (s == 4'b0000) && (c_in == 1'b1); // A-1 (decremento)
    wire is_or_minus_1 = (m == 1'b0) && (s == 4'b0010); // S=0010 é operação (A OR B) MINUS 1
    wire is_aminus1 = (m == 1'b0) && (s == 4'b0000); // A MINUS 1
    
    // Lógica de carry look-ahead para melhor desempenho
    // Usamos a mesma lógica da ULA original: g_lsb | (p_lsb & c_in)
    wire carry_msb;

    // Instanciação da ULA para os 4 bits menos significativos (LSB)
    ula_74181 ula_lsb (
        .a(a[3:0]),
        .b(b[3:0]),
        .s(s),
        .m(m),
        .c_in(c_in),
        .f(f_lsb),
        .a_eq_b(a_eq_b_lsb),
        .c_out(c_out_lsb),
        .p(p_lsb),
        .g(g_lsb)
    );
    
    // Calculamos o carry para o bloco MSB usando a lógica de carry look-ahead
    assign carry_msb = g_lsb | (p_lsb & c_in);

    // Instanciação da ULA para os 4 bits mais significativos (MSB)
    ula_74181 ula_msb (
        .a(a[7:4]),
        .b(b[7:4]),
        .s(s),
        .m(m),
        .c_in(carry_msb), // Usando carry look-ahead
        .f(f_msb),
        .a_eq_b(a_eq_b_msb),
        .c_out(c_out_msb),
        .p(p_msb),
        .g(g_msb)
    );

    // Saída de 8 bits com correção para casos específicos
    wire [7:0] f_original = {f_msb, f_lsb}; // Concatenação das saídas
    
    // Correção para casos específicos
    // Corrigir o caso especial S=0010 ((A OR B) MINUS 1)
    // Corrigir o caso especial S=0000 (A MINUS 1)
    wire [7:0] f_corrected = is_or_minus_1 ? ((a | b) - 8'h01) : 
                             is_aminus1 ? (a - 8'h01) : 
                             f_original;
    
    // Usar a versão corrigida quando necessário
    assign f = f_corrected;

    // A saída a_eq_b para 8 bits é ativa se ambos os módulos de 4 bits indicarem igualdade
    assign a_eq_b = a_eq_b_lsb & a_eq_b_msb;
    
    // O carry out é o carry out do MSB
    assign c_out = c_out_msb;
    
    // Detecção de overflow para aritmética em complemento a dois
    
    // Para adição: overflow quando os sinais dos operandos são iguais e diferentes do resultado
    wire add_overflow = is_add && (a[7] == b[7]) && (a[7] != f[7]);
    
    // Para subtração: overflow quando os sinais dos operandos são diferentes e o resultado tem o mesmo sinal do subtraendo
    wire sub_overflow = is_sub && (a[7] != b[7]) && (f[7] == b[7]);
    
    // Overflow ocorre apenas em adição ou subtração
    assign overflow = (m == 1'b0) ? (add_overflow || sub_overflow) : 1'b0;
    
    // Para os sinais de carry look-ahead P e G para a ULA de 8 bits completa
    // P para 8 bits é ativo se ambos P dos 4 bits estiverem ativos
    assign p = p_lsb & p_msb;
    
    // G para 8 bits - considera o cascateamento do carry
    // G8 = G_msb + (P_msb & G_lsb)
    assign g = g_msb | (p_msb & g_lsb);

endmodule
