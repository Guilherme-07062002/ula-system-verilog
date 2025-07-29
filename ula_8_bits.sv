module ula_8_bits (
    input [7:0] a,
    input [7:0] b,
    input [3:0] s,
    input       m,
    input       c_in,
    output wire [7:0] f,
    output wire       a_eq_b,
    output wire       c_out
);

    // Sinais internos para cascateamento das ULAs de 4 bits
    wire [3:0] f_lsb; // Saída da ULA dos 4 bits menos significativos
    wire       c_out_lsb; // Carry Out da ULA dos 4 bits menos significativos
    wire       a_eq_b_lsb; // A=B da ULA dos 4 bits menos significativos

    wire [3:0] f_msb; // Saída da ULA dos 4 bits mais significativos
    wire       c_out_msb; // Carry Out da ULA dos 4 bits mais significativos
    wire       a_eq_b_msb; // A=B da ULA dos 4 bits mais significativos

    // Instanciação da ULA para os 4 bits menos significativos (LSB)
    ula_74181 ula_lsb (
        .a(a[3:0]),
        .b(b[3:0]),
        .s(s),
        .m(m),
        .c_in(c_in),
        .f(f_lsb),
        .a_eq_b(a_eq_b_lsb),
        .c_out(c_out_lsb)
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
        .c_out(c_out_msb)
    );

    // Conectando as saídas dos módulos de 4 bits para formar a saída de 8 bits
    assign f = {f_msb, f_lsb}; // Concatenação das saídas

    // A saída a_eq_b para 8 bits é ativa se ambos os módulos de 4 bits indicarem igualdade
    assign a_eq_b = a_eq_b_lsb & a_eq_b_msb;

    // O carry out final é o carry out da ULA mais significativa
    assign c_out = c_out_msb;

endmodule