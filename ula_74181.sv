`timescale 1ns/1ps

module ula_74181 (
    input  wire [3:0] a, b,
    input  wire [3:0] s,     // s = {S3,S2,S1,S0}
    input  wire       m,     // M = 1 → Lógico; 0 → Aritmético
    input  wire       c_in,  // Carry-in ≡ Cn
    output reg  [3:0] f,
    output wire       a_eq_b,
    output reg        c_out  // Carry-out ≡ Cn+4
);

    // Comparador A = B
    assign a_eq_b = (a == b);

    // Registrador de 5 bits para soma aritmética (4 bits + carry)
    reg [4:0] sum_arith;

    // Funções lógicas e aritméticas
    always @* begin
        // Inicialização dos sinais
        sum_arith = 5'b00000;
        f = 4'b0000;
        c_out = 1'b0;

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
                4'b0000: begin // A - 1 + Cin
                    sum_arith = a + 4'b1111 + c_in;
                end
                4'b0001: begin // A + B + Cin
                    sum_arith = a + b + c_in;
                end
                4'b0010: begin // A + ~B + Cin
                    sum_arith = a + (~b) + c_in;
                end
                4'b0011: begin // -1 + Cin (4'b1111 + Cin)
                    sum_arith = 4'b1111 + c_in;
                end
                4'b0100: begin // A + (A & ~B) + Cin
                    sum_arith = a + (a & ~b) + c_in;
                end
                4'b0101: begin // (A | B) + (A & ~B) + Cin
                    sum_arith = (a | b) + (a & ~b) + c_in;
                end
                4'b0110: begin // A - B - 1 + Cin
                    sum_arith = a + (~b) + 4'b1111 + c_in;
                end
                4'b0111: begin // (A & ~B) - 1 + Cin
                    sum_arith = (a & ~b) + 4'b1111 + c_in;
                end
                4'b1000: begin // A + A + Cin (2A)
                    sum_arith = a + a + c_in;
                end
                4'b1001: begin // A + (A | B) + Cin
                    sum_arith = a + (a | b) + c_in;
                end
                4'b1010: begin // A + (A | ~B) + Cin
                    sum_arith = a + (a | ~b) + c_in;
                end
                4'b1011: begin // A - 1 + Cin
                    sum_arith = a + 4'b1111 + c_in;
                end
                4'b1100: begin // A + (A & B) + Cin
                    sum_arith = a + (a & b) + c_in;
                end
                4'b1101: begin // (A | B) + (A & B) + Cin
                    sum_arith = (a | b) + (a & b) + c_in;
                end
                4'b1110: begin // (A | ~B) + (A & B) + Cin
                    sum_arith = (a | ~b) + (a & b) + c_in;
                end
                4'b1111: begin // A + Cin
                    sum_arith = a + c_in;
                end
                default: sum_arith = 5'bxxxxx;
            endcase
            
            // Atribuição do resultado e carry-out
            f = sum_arith[3:0];
            c_out = sum_arith[4];
        end
    end

endmodule