module ula_74181 (
    input [3:0] a,
    input [3:0] b,
    input [3:0] s,
    input       m,
    input       c_in,
    output reg [3:0] f,
    output reg  a_eq_b,
    output reg  c_out
);

    reg [4:0] sum_arith; // 5 bits para incluir carry out
    
    always @(*) begin
        // Inicializa saídas
        f = 4'b0;
        a_eq_b = (a == b); // Comparação válida para ambos os modos
        c_out = 1'b0;

        if (m == 1'b1) begin // Modo Lógico
            case (s)
                4'b0000: f = ~a;                    // F = NOT A
                4'b0001: f = ~(a | b);              // F = NOT (A OR B)
                4'b0010: f = (~a) & b;              // F = (NOT A) AND B
                4'b0011: f = 4'b0000;               // F = 0
                4'b0100: f = ~(a & b);              // F = NOT (A AND B)
                4'b0101: f = ~b;                    // F = NOT B
                4'b0110: f = a ^ b;                 // F = A XOR B
                4'b0111: f = a & (~b);              // F = A AND (NOT B)
                4'b1000: f = (~a) | b;              // F = (NOT A) OR B
                4'b1001: f = ~(a ^ b);              // F = NOT (A XOR B)
                4'b1010: f = b;                     // F = B
                4'b1011: f = a & b;                 // F = A AND B
                4'b1100: f = 4'b1111;               // F = 1
                4'b1101: f = a | (~b);              // F = A OR (NOT B)
                4'b1110: f = a | b;                 // F = A OR B
                4'b1111: f = a;                     // F = A
                default: f = 4'bxxxx;
            endcase
        end else begin // m == 1'b0 - Modo Aritmético
            // Operações aritméticas baseadas no datasheet 74181
            case (s)
                4'b0000: sum_arith = a + c_in;                      // F = A
                4'b0001: sum_arith = (a | b) + c_in;                // F = (A OR B)
                4'b0010: sum_arith = (a | (~b)) + c_in;             // F = (A OR NOT B)
                4'b0011: sum_arith = 4'b1111 + c_in;                // F = -1 (all ones)
                4'b0100: sum_arith = a + (a & (~b)) + c_in;         // F = A + (A AND NOT B)
                4'b0101: sum_arith = (a | b) + (a & (~b)) + c_in;   // F = (A OR B) + (A AND NOT B)
                4'b0110: sum_arith = a + (~b) + c_in;               // F = A - B - 1
                4'b0111: sum_arith = (a & (~b)) + 4'b1110 + c_in;   // F = (A AND NOT B) - 1
                4'b1000: sum_arith = a + (a & b) + c_in;            // F = A + (A AND B)
                4'b1001: sum_arith = a + b + c_in;                  // F = A + B
                4'b1010: sum_arith = (a | (~b)) + (a & b) + c_in;   // F = (A OR NOT B) + (A AND B)
                4'b1011: sum_arith = (a & b) + 4'b1110 + c_in;      // F = (A AND B) - 1
                4'b1100: sum_arith = a + a + c_in;                  // F = A + A (A shift left)
                4'b1101: sum_arith = (a | b) + a + c_in;            // F = (A OR B) + A
                4'b1110: sum_arith = (a | (~b)) + a + c_in;         // F = (A OR NOT B) + A
                4'b1111: sum_arith = a + 4'b1110 + c_in;            // F = A - 1
                default: sum_arith = 5'bxxxxx;
            endcase
            
            f = sum_arith[3:0];
            c_out = sum_arith[4];
        end
    end

endmodule