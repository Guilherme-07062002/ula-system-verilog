module ula_74181(
  input logic [3:0] a, b,
  input logic [3:0] s,
  input logic m,
  input logic c_in,
  output logic [3:0] f,
  output logic a_eq_b,
  output logic c_out
);

  logic [3:0] f_logic, f_arith;
  logic [3:0] carry;

  // Lógica combinacional para as operações lógicas
  always_comb begin
    case (s)
      4'b0000: f_logic = a & b;
      4'b0001: f_logic = a | b;
      4'b0010: f_logic = a ^ b;
      4'b0011: f_logic = ~(a & b);
      4'b0100: f_logic = ~(a | b);
      4'b0101: f_logic = ~(a ^ b);
      4'b0110: f_logic = a;
      4'b0111: f_logic = b;
      4'b1000: f_logic = ~a;
      4'b1001: f_logic = ~b;
      4'b1010: f_logic = a & ~b;
      4'b1011: f_logic = ~a & b;
      4'b1100: f_logic = a | ~b;
      4'b1101: f_logic = ~a | b;
      4'b1110: f_logic = ~(a & ~b);
      4'b1111: f_logic = ~(~a & b);
    endcase
  end

  // Lógica combinacional para as operações aritméticas
  always_comb begin
    case (s)
      4'b0000: f_arith = a + b;
      4'b0001: f_arith = a - b;
      4'b0010: f_arith = a + 1;
      4'b0011: f_arith = a - 1;
      4'b0100: f_arith = b + 1;
      4'b0101: f_arith = b - 1;
      4'b0110: f_arith = a + b + c_in;
      4'b0111: f_arith = a - b + c_in;
      4'b1000: f_arith = a + 1 + c_in;
      4'b1001: f_arith = a - 1 + c_in;
      4'b1010: f_arith = b + 1 + c_in;
      4'b1011: f_arith = b - 1 + c_in;
      4'b1100: f_arith = a + b + c_in + 1;
      4'b1101: f_arith = a - b + c_in + 1;
      4'b1110: f_arith = a + 1 + c_in + 1;
      4'b1111: f_arith = a - 1 + c_in + 1;
    endcase
  end

  // Controle de modo
  assign f = m ? f_logic : f_arith;

  // Saída de carry
  assign c_out = carry[3];

  // Comparador
  assign a_eq_b = (a == b);
endmodule