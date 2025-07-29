module tb_ula_74181;
  logic [3:0] a, b;
  logic [3:0] s;
  logic m;
  logic c_in;
  logic [3:0] f;
  logic a_eq_b;
  logic c_out;

  ula_74181 uut (
    .a(a),
    .b(b),
    .s(s),
    .m(m),
    .c_in(c_in),
    .f(f),
    .a_eq_b(a_eq_b),
    .c_out(c_out)
  );

  initial begin
    $dumpfile("ula_74181.vcd");
    $dumpvars(0, tb_ula_74181);

    // Teste das operações lógicas
    for (int i = 0; i < 16; i++) begin
      s = i;
      m = 1;
      a = 4'b1010;
      b = 4'b1100;
      c_in = 0;
      #10;
      $display("s = %b, a = %b, b = %b, f = %b", s, a, b, f);
    end

    // Teste das operações aritméticas
    for (int i = 0; i < 16; i++) begin
      s = i;
      m = 0;
      a = 4'b1010;
      b = 4'b1100;
      c_in = 0;
      #10;
      $display("s = %b, a = %b, b = %b, f = %b", s, a, b, f);
    end

    $finish;
  end
endmodule