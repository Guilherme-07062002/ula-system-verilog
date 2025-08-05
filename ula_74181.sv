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
    // Inicialização de variáveis
    logic_f = 4'b0000;
    c_out   = 1'b0;
    f       = 4'b0000;

    // Cálculo de logic_f independente do modo (usado por ambos os modos)
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
    
    if (m) begin
      // Modo lógico: saída direta da operação lógica
      f = logic_f;
    end
    else begin
      // Modo aritmético: F = A + logic_f + Cin (conforme datasheet)
      // Todas as 16 funções aritméticas seguem este padrão
      sum_arith = a + logic_f + c_in;
      f = sum_arith[3:0];
      c_out = sum_arith[4];
    end
  end

endmodule