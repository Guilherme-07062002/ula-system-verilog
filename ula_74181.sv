`timescale 1ns/1ps

module ula_74181 (
    input  wire [3:0] a, b,
    input  wire [3:0] s,      // s = {S3,S2,S1,S0}
    input  wire       m,      // M = 1 -> Lógico; 0 -> Aritmético
    input  wire       c_in,   // Carry-in ≡ Cn
    output reg  [3:0] f,
    output wire       a_eq_b,
    output reg        c_out   // Carry-out ≡ Cn+4
);

    // Comparador A = B
    assign a_eq_b = (a == b);

    // Registrador de 5 bits para soma aritmética (4 bits + carry)
    reg [4:0] sum_arith;

    // Funções lógicas e aritméticas
    always @* begin
        // Inicialização dos sinais
        f = 4'b0000;
        sum_arith = 5'b00000;
        c_out = 1'b0;
    
        if (m) begin
            // Modo lógico (m = 1)
            // C_out deve ser sempre 0 no modo lógico
            case (s)
                4'b0000: f = ~a;        // NOT A
                4'b0001: f = ~(a | b);  // NOR
                4'b0010: f = (~a) & b;  // A̅ & B
                4'b0011: f = 4'b0000;   // ZERO
                4'b0100: f = ~(a & b);  // NAND
                4'b0101: f = ~b;        // NOT B
                4'b0110: f = a ^ b;     // XOR
                4'b0111: f = a & (~b);  // A & B̅
                4'b1000: f = a & b;     // AND
                4'b1001: f = ~(a ^ b);  // XNOR
                4'b1010: f = b;         // B
                4'b1011: f = (~a) | b;  // A̅ | B
                4'b1100: f = 4'b1111;   // ONE
                4'b1101: f = a | (~b);  // A | B̅
                4'b1110: f = a | b;     // OR
                4'b1111: f = a;         // A
                default: f = 4'bxxxx;
            endcase
            c_out = 1'b0;
        end else begin
            // Modo aritmético (m = 0)
            case (s)
                // Funções A+Y
                4'b0000: sum_arith = {1'b0, a} + {1'b0, a};     // F = A + A
                4'b0001: sum_arith = {1'b0, a} + {1'b0, a|b};   // F = A + (A|B)
                4'b0010: sum_arith = {1'b0, a} + {1'b0, a|~b};  // F = A + (A|~B)
                4'b0011: sum_arith = {1'b0, a} + {1'b0, 4'b1111}; // F = A + (-1)
                4'b0100: sum_arith = {1'b0, a} + {1'b0, a&b};   // F = A + (A&B)
                4'b0101: sum_arith = {1'b0, a} + {1'b0, b};       // F = A + B
                4'b0110: sum_arith = {1'b0, a} + {1'b0, b};     // F = A + B
                4'b0111: sum_arith = {1'b0, a} + {1'b0, a};     // F = A + A
                // Funções F = (X) + Y + C_in
                4'b1000: sum_arith = {1'b0, a} + {1'b0, ~b} + c_in;    // F = A + ~B + C_in
                4'b1001: sum_arith = {1'b0, a&b} + {1'b0, ~b} + c_in;   // F = (A&B) + ~B + C_in
                4'b1010: sum_arith = {1'b0, a&~b} + {1'b0, ~b} + c_in;  // F = (A&~B) + ~B + C_in
                4'b1011: sum_arith = {1'b0, a&b} + {1'b0, a} + c_in; // F = (A&B) + A + C_in
                4'b1100: sum_arith = {1'b0, a|~b} + {1'b0, a} + c_in;  // F = (A|~B) + A + C_in
                4'b1101: sum_arith = {1'b0, a|b} + {1'b0, a} + c_in;  // F = (A|B) + A + C_in
                4'b1110: sum_arith = {1'b0, a|b} + {1'b0, 4'b1111} + c_in;  // F = (A|B) - 1 + C_in
                4'b1111: sum_arith = {1'b0, a} + {1'b0, 4'b1111} + c_in;  // F = A - 1 + C_in
                default: sum_arith = 5'bxxxxx;
            endcase

            f = sum_arith[3:0];
            // O carry-out no modo aritmético é o bit de carry da soma,
            // exceto para subtrações, onde ele é o complemento do carry.
            case (s)
                4'b1000, 4'b1001, 4'b1010, 4'b1011:
                    c_out = ~sum_arith[4]; // Subtração F=A-B ou similar
                default:
                    c_out = sum_arith[4];
            endcase
        end
    end

endmodule