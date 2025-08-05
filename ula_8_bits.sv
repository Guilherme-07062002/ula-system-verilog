module ula_8_bits (
    input [7:0] a,
    input [7:0] b,
    input [3:0] s,
    input       m,
    input       c_in,
    output wire [7:0] f,
    output wire       a_eq_b,
    output wire       c_out,
    output wire       overflow  // Sinal de overflow para aritmética de complemento a dois
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

    // Instanciação da ULA para os 4 bits mais significativos (MSB)
    // O carry_in da ULA MSB é o carry_out da ULA LSB (ripple carry)
    ula_74181 ula_msb (
        .a(a[7:4]),
        .b(b[7:4]),
        .s(s),
        .m(m),
        .c_in(c_out_lsb), // Conexão Ripple Carry
        .f(f_msb),
        .a_eq_b(a_eq_b_msb),
        .c_out(c_out),    // O carry_out do MSB é o carry_out final
        .p(p_msb),
        .g(g_msb)
    );

    // Conectando as saídas dos módulos de 4 bits para formar a saída de 8 bits
    assign f = {f_msb, f_lsb}; // Concatenação das saídas

    // A saída a_eq_b para 8 bits é ativa se ambos os módulos de 4 bits indicarem igualdade
    assign a_eq_b = a_eq_b_lsb & a_eq_b_msb;
    
    // Detecção de overflow para aritmética em complemento a dois
    // Overflow ocorre quando o carry dos dois bits mais significativos diferem
    // Na prática, isso significa que o sinal do resultado mudou de forma inesperada
    wire carry_bit_6_to_7; // Carry do bit 6 para o bit 7 (entre MSB-1 e MSB)
    
    // Para simplicidade, calculamos o overflow apenas para operações de adição e subtração (S=0101, S=1000)
    // Overflow = carry_in_to_msb XOR carry_out_from_msb
    assign carry_bit_6_to_7 = (a[6] & b[6]) | ((a[6] | b[6]) & f[6]);
    assign overflow = (m == 1'b0) ? (carry_bit_6_to_7 ^ c_out) : 1'b0;

    // O carry out final já está conectado diretamente na instanciação da ULA MSB
    // Não é necessário fazer um assign adicional pois já foi feito na instanciação

endmodule