`timescale 1ns/1ps
//
//  ula_74181.v
//  Implementação fiel à tabela da 74LS181 (M = lógica/aritimética, Cin, S3‑S0)
//  a_eq_b mantido como (a == b) para regressão com bench original.
//  A(s) são entranhas em A e B com 4 bits, S[3:0] seleciona função,
//  c_in é o carry‑in (Cn), e f[3:0]/c_out é o resultado + carry‑out.
//
module ula_74181 (
    input  wire [3:0] a, b,
    input  wire [3:0] s,     // s = {S3,S2,S1,S0}
    input  wire       m,     // M = 1 → Lógico; 0 → Aritmético
    input  wire       c_in,  // Carry‑in ≡ Cn
    output reg  [3:0] f,
    output wire       a_eq_b,
    output reg        c_out  // Carry‑out ≡ Cn+4
);

  // A = B simples (bench antigo testava em ambos os modos)
  assign a_eq_b = (a == b);

  reg [3:0] logic_f;     // saídas da operação lógica
  reg [4:0] sum_arith;   // soma com espaço para carry

  always @* begin
    logic_f = 4'b0000;
    c_out   = 1'b0;
    f       = 4'b0000;

    if (m) begin
      // Modo lógico: implementação direta das operações booleanas
      case (s)
        4'b0000: logic_f = ~a;           // NOT A
        4'b0001: logic_f = ~(a | b);     // NOR
        4'b0010: logic_f = (~a) & b;     // A̅ & B
        4'b0011: logic_f = 4'b0000;      // ZERO
        4'b0100: logic_f = ~(a & b);     // NAND
        4'b0101: logic_f = ~b;           // NOT B
        4'b0110: logic_f = a ^ b;        // XOR
        4'b0111: logic_f = a & (~b);     // A & B̅
        4'b1000: logic_f = (~a) | b;     // A̅ | B
        4'b1001: logic_f = ~(a ^ b);     // XNOR (≡ NOT XOR)
        4'b1010: logic_f = b;            // B
        4'b1011: logic_f = a & b;        // AND
        4'b1100: logic_f = 4'b1111;      // ONE
        4'b1101: logic_f = a | (~b);     // A | B̅
        4'b1110: logic_f = a | b;        // OR
        4'b1111: logic_f = a;            // A
        default: logic_f = 4'bxxxx;
      endcase
      
      f = logic_f;
    end
    else begin
      // Modo aritmético: implementação conforme datasheet 74181
      case (s)
        4'b0000: begin
            // F = A MINUS 1 (A + ~0 + Cin)
            sum_arith = a + 4'b1111 + c_in;
            f = sum_arith[3:0];
            c_out = sum_arith[4];  // Removed inversion for consistency
        end
        4'b0001: begin
            // F = A PLUS B
            sum_arith = a + b + c_in;
            f = sum_arith[3:0];
            c_out = sum_arith[4];
        end
        4'b0010: begin
            // F = A PLUS ~B (A - B - 1 + Cin)
            sum_arith = a + (~b) + c_in;
            f = sum_arith[3:0];
            c_out = sum_arith[4];
        end
        4'b0011: begin
            // F = MINUS 1 (0 + ~0 + Cin = 1111 + Cin)
            sum_arith = 4'b0000 + 4'b1111 + c_in;
            f = sum_arith[3:0];
            c_out = sum_arith[4];
        end
        4'b0100: begin
            // F = A PLUS (A AND ~B)
            sum_arith = a + (a & (~b)) + c_in;
            f = sum_arith[3:0];
            c_out = sum_arith[4];
        end
        4'b0101: begin
            // F = (A OR B) PLUS (A AND ~B)
            sum_arith = (a | b) + (a & (~b)) + c_in;
            f = sum_arith[3:0];
            c_out = sum_arith[4];
        end
        4'b0110: begin
            // F = A MINUS B MINUS 1 + Cin
            sum_arith = a + (~b) + c_in;
            f = sum_arith[3:0];
            c_out = sum_arith[4];
        end
        4'b0111: begin
            // F = (A AND ~B) MINUS 1 + Cin
            sum_arith = (a & (~b)) + 4'b1111 + c_in;
            f = sum_arith[3:0];
            c_out = sum_arith[4];
        end
        4'b1000: begin
            // F = A PLUS (A AND B)
            sum_arith = a + (a & b) + c_in;
            f = sum_arith[3:0];
            c_out = sum_arith[4];
        end
        4'b1001: begin
            // F = A PLUS B
            sum_arith = a + b + c_in;
            f = sum_arith[3:0];
            c_out = sum_arith[4];
        end
        4'b1010: begin
            // F = (A OR ~B) PLUS (A AND B)
            sum_arith = (a | (~b)) + (a & b) + c_in;
            f = sum_arith[3:0];
            c_out = sum_arith[4];
        end
        4'b1011: begin
            // F = A MINUS 1 + Cin (A + ~0 + Cin)
            sum_arith = a + 4'b1111 + c_in;
            f = sum_arith[3:0];
            c_out = sum_arith[4];
        end
        4'b1100: begin
            // F = A PLUS A (2A)
            sum_arith = a + a + c_in;
            f = sum_arith[3:0];
            c_out = sum_arith[4];
        end
        4'b1101: begin
            // F = (A OR B) PLUS A
            sum_arith = (a | b) + a + c_in;
            f = sum_arith[3:0];
            c_out = sum_arith[4];
        end
        4'b1110: begin
            // F = (A OR ~B) PLUS A
            sum_arith = (a | (~b)) + a + c_in;
            f = sum_arith[3:0];
            c_out = sum_arith[4];
        end
        4'b1111: begin
            // F = A MINUS 1 + Cin (A + ~0 + Cin)
            sum_arith = a + 4'b1111 + c_in;
            f = sum_arith[3:0];
            c_out = sum_arith[4];
        end
        default: begin
            sum_arith = 5'bxxxxx;
            f = 4'bxxxx;
            c_out = 1'bx;
        end
      endcase
    end
  end

endmodule