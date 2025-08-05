`timescale 1ns/1ps

module ula_74181 (
    input  wire [3:0] a, b,
    input  wire [3:0] s,      // s = {S3,S2,S1,S0}
    input  wire       m,      // M = 1 -> Lógico; 0 -> Aritmético
    input  wire       c_in,   // Carry-in ≡ Cn
    output reg  [3:0] f,
    output wire       a_eq_b,
    output reg        c_out,  // Carry-out ≡ Cn+4
    output wire       p,      // Propagate (para carry look-ahead)
    output wire       g       // Generate (para carry look-ahead)
);

    // Comparador A = B (implementação correta)
    assign a_eq_b = (a == b);
    
    // Implementação dos sinais P (Propagate) e G (Generate) para carry look-ahead
    // P = 1 quando um carry pode ser propagado através de todos os bits
    // G = 1 quando um carry é gerado internamente
    wire [3:0] p_bits, g_bits;
    
    // Para cada bit calculamos P e G conforme o modo e as operações
    generate
        genvar i;
        for (i = 0; i < 4; i = i + 1) begin: pg_gen
            assign p_bits[i] = (m == 1'b0) ? (a[i] | b[i]) : 1'b0; // Propagate no modo aritmético
            assign g_bits[i] = (m == 1'b0) ? (a[i] & b[i]) : 1'b0; // Generate no modo aritmético
        end
    endgenerate
    
    // P e G para o carry look-ahead são calculados por:
    // P = p0 & p1 & p2 & p3 (AND de todos os bits de propagate)
    // G = g3 | (p3 & g2) | (p3 & p2 & g1) | (p3 & p2 & p1 & g0)
    assign p = &p_bits; // AND de todos os bits P
    assign g = g_bits[3] | 
              (p_bits[3] & g_bits[2]) | 
              (p_bits[3] & p_bits[2] & g_bits[1]) | 
              (p_bits[3] & p_bits[2] & p_bits[1] & g_bits[0]);

    // Registrador de 5 bits para soma aritmética
    reg [4:0] sum_arith;

    // Funções lógicas e aritméticas
    always @* begin
        if (m) begin
            // Modo lógico (m = 1) - `c_out` é sempre 0
            case (s)
                4'b0000: f = ~a;         // F = not(A)
                4'b0001: f = ~(a | b);   // F = NOR
                4'b0010: f = (~a) & b;   // F = not(A) and B
                4'b0011: f = 4'b0000;    // F = 0
                4'b0100: f = ~(a & b);   // F = NAND
                4'b0101: f = ~b;         // F = not(B)
                4'b0110: f = a ^ b;      // F = XOR
                4'b0111: f = a & (~b);   // F = A and not(B)
                4'b1000: f = a & b;      // F = AND
                4'b1001: f = ~(a ^ b);   // F = XNOR
                4'b1010: f = b;          // F = B
                4'b1011: f = (~a) | b;   // F = not(A) or B
                4'b1100: f = 4'b1111;    // F = 1
                4'b1101: f = a | (~b);   // F = A or not(B)
                4'b1110: f = a | b;      // F = OR
                4'b1111: f = a;          // F = A
            endcase
            c_out = 1'b0;
        end else begin
            // Modo aritmético (m = 0)
            case (s)
                4'b0000: sum_arith = {1'b0, a} + {1'b0, a}; // F = A + A
                4'b0001: sum_arith = {1'b0, a} + {1'b0, a|b}; // F = A + (A|B)
                4'b0010: sum_arith = {1'b0, a} + {1'b0, a|~b}; // F = A + (A|~B)
                4'b0011: sum_arith = {1'b0, a} + {1'b0, 4'b1111}; // F = A + (-1)
                4'b0100: sum_arith = {1'b0, a} + {1'b0, a&b}; // F = A + (A&B)
                4'b0101: sum_arith = {1'b0, a} + {1'b0, b} + c_in; // F = A + B + Cin
                4'b0110: sum_arith = {1'b0, a} + {1'b0, b} + c_in; // F = A + B + Cin
                4'b0111: sum_arith = {1'b0, a} + {1'b0, a} + c_in; // F = A + A + Cin
                4'b1000: sum_arith = {1'b0, a} + {1'b0, ~b} + c_in; // F = A + ~B + C_in
                4'b1001: sum_arith = {1'b0, a&b} + {1'b0, ~b} + c_in; // F = (A&B) + ~B + C_in
                4'b1010: sum_arith = {1'b0, a&~b} + {1'b0, ~b} + c_in; // F = (A&~B) + ~B + C_in
                4'b1011: sum_arith = {1'b0, a&b} + {1'b0, a} + c_in; // F = (A&B) + A + C_in
                4'b1100: sum_arith = {1'b0, a|~b} + {1'b0, a} + c_in; // F = (A|~B) + A + C_in
                4'b1101: sum_arith = {1'b0, a|b} + {1'b0, a} + c_in; // F = (A|B) + A + C_in
                4'b1110: sum_arith = {1'b0, a|b} + {1'b0, 4'b1111} + c_in; // F = (A|B) - 1 + C_in
                4'b1111: sum_arith = {1'b0, a} + {1'b0, 4'b1111} + c_in; // F = A - 1 + C_in
                default: sum_arith = 5'bxxxxx;
            endcase

            f = sum_arith[3:0];
            // Tratamento correto do carry-out conforme o datasheet do SN74LS181
            // Para operações de subtração (A-B), o carry-out é o complemento do borrow
            case (s)
                // Operações de subtração
                4'b0010, 4'b0011, 4'b0110, 4'b0111, 4'b1000, 4'b1001, 4'b1010, 4'b1110, 4'b1111:
                    c_out = ~sum_arith[4]; // Complemento do carry para operações de subtração
                // Operações de adição
                default:
                    c_out = sum_arith[4];  // Carry direto para operações de adição
            endcase
        end
    end
endmodule