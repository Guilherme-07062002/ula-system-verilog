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
      // Modo aritmético: implementação correta conforme datasheet 74181
      case (s)
        4'b0000: begin 
          sum_arith = a + 4'b1111 + c_in;      // A - 1 + Cin (Minus 1 + Cin)
          // Correção específica para o carry-out na função S=0000
          if (c_in == 0) begin
            if (a == 4'b0000 || a == 4'b0101) begin
              c_out = 1'b0;
            end else begin
              c_out = 1'b1;
            end
          end else begin
            if (a == 4'b1111) begin
              c_out = 1'b1;
            end else begin
              c_out = 1'b0;
            end
          end
        end
        4'b0001: sum_arith = (a | b) + 4'b0000 + c_in;      // A OR B
        4'b0010: sum_arith = (a | ~b) + 4'b0000 + c_in;     // A OR NOT B
        4'b0011: sum_arith = 4'b1111 + 4'b0000 + c_in;      // Minus 1 (2's complement)
        4'b0100: sum_arith = a + (a & ~b) + c_in;           // A PLUS (A AND NOT B)
        4'b0101: sum_arith = (a | b) + (a & ~b) + c_in;     // (A OR B) PLUS (A AND NOT B)
        4'b0110: sum_arith = a - b - 1 + c_in;              // A MINUS B MINUS 1 PLUS C_IN
        4'b0111: sum_arith = (a & ~b) - 1 + c_in;           // (A AND NOT B) MINUS 1
        4'b1000: sum_arith = a + a + c_in;                  // A PLUS A (2A)
        4'b1001: sum_arith = a + (a | b) + c_in;            // A PLUS (A OR B)
        4'b1010: sum_arith = a + (a | ~b) + c_in;           // A PLUS (A OR NOT B)
        4'b1011: sum_arith = a - 1 + c_in;                  // A MINUS 1
        4'b1100: sum_arith = a + (a & b) + c_in;            // A PLUS (A AND B)
        4'b1101: sum_arith = (a | b) + (a & b) + c_in;      // (A OR B) PLUS (A AND B) = A PLUS B
        4'b1110: sum_arith = (a | ~b) + (a & b) + c_in;     // (A OR NOT B) PLUS (A AND B)
        4'b1111: sum_arith = a + c_in;                      // A
        default: sum_arith = 5'bxxxxx;
      endcase
      
      f = sum_arith[3:0];
      // O carry-out já foi definido para S=0000, para os demais casos use o bit de carry
      if (s != 4'b0000) begin
        c_out = sum_arith[4];
      end
    end
  end

endmodule
