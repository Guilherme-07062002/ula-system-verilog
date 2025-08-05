`timescale 1ns/1ps

module ula_74181 (
    input  wire [3:0] a, b,
    input  wire [3:0] s,     // s = {S3,S2,S1,S0}
    input  wire       m,     // M = 1 → Lógico; 0 → Aritmético
    input  wire       c_in,  // Carry‑in ≡ Cn
    output reg  [3:0] f,
    output wire       a_eq_b,
    output reg        c_out  // Carry‑out ≡ Cn+4
);

    // A = B simples
    assign a_eq_b = (a == b);

    // Funções lógicas e aritméticas
    always @* begin
        if (m) begin
            // Modo lógico
            case (s)
                4'b0000: f = ~a;           // NOT A
                4'b0001: f = ~(a | b);     // NOR
                4'b0010: f = (~a) & b;     // A̅ & B
                4'b0011: f = 4'b0000;      // ZERO
                4'b0100: f = ~(a & b);     // NAND
                4'b0101: f = ~b;           // NOT B
                4'b0110: f = a ^ b;        // XOR
                4'b0111: f = a & (~b);     // A & B̅
                4'b1000: f = a & b;        // AND
                4'b1001: f = ~(a ^ b);     // XNOR
                4'b1010: f = b;            // B
                4'b1011: f = (~a) | b;     // A̅ | B
                4'b1100: f = 4'b1111;      // ONE
                4'b1101: f = a | (~b);     // A | B̅
                4'b1110: f = a | b;        // OR
                4'b1111: f = a;            // A
                default: f = 4'bxxxx;
            endcase
            c_out = 1'b0;
        end else begin
            // Modo aritmético
            case (s)
                4'b0000: {c_out, f} = a + c_in;                    // A + Cin
                4'b0001: {c_out, f} = a + b + c_in;                // A + B + Cin
                4'b0010: {c_out, f} = a + (~b) + c_in;             // A + ~B + Cin
                4'b0011: {c_out, f} = -1 + c_in;                   // -1 + Cin
                4'b0100: {c_out, f} = a + (a & ~b) + c_in;         // A + (A & ~B) + Cin
                4'b0101: {c_out, f} = (a + b) + (a & ~b) + c_in;   // (A + B) + (A & ~B) + Cin
                4'b0110: {c_out, f} = a - b - 1 + c_in;            // A - B - 1 + Cin
                4'b0111: {c_out, f} = (a & ~b) - 1 + c_in;         // (A & ~B) - 1 + Cin
                4'b1000: {c_out, f} = a + (a & b) + c_in;          // A + (A & B) + Cin
                4'b1001: {c_out, f} = a + b + c_in;                // A + B + Cin
                4'b1010: {c_out, f} = (a + ~b) + (a & b) + c_in;   // (A + ~B) + (A & B) + Cin
                4'b1011: {c_out, f} = a + c_in;                    // A + Cin
                4'b1100: {c_out, f} = (a & b) - 1 + c_in;          // (A & B) - 1 + Cin
                4'b1101: {c_out, f} = a + b + c_in;                // A + B + Cin
                4'b1110: {c_out, f} = (a & ~b) + c_in;             // (A & ~B) + Cin
                4'b1111: {c_out, f} = a - 1 + c_in;                // A - 1 + Cin
                default: {c_out, f} = 5'bxxxxx;
            endcase
        end
    end

endmodule