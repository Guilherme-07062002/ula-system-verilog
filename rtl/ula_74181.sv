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
    // De acordo com o datasheet SN74LS181:
    // - No modo aritmético (M=0), P e G dependem das funções selecionadas por S
    // - No modo lógico (M=1), P=0 e G=1 (para desabilitar carry look-ahead)
    
    // Sinais intermediários para cada bit
    wire [3:0] p_bits, g_bits;
    reg [3:0] op_result; // Resultado intermediário baseado nas seleções S
    
    // Cálculo dos operandos para P e G de acordo com S
    always @* begin
        if (m == 1'b0) begin // Modo aritmético
            case (s)
                // Para cada código S, calculamos os operandos conforme o datasheet
                4'b0000: op_result = 4'b1111; // Para A MINUS 1
                4'b0001: op_result = a | b;    // Para A PLUS (A OR B)
                4'b0010: op_result = a | b;    // Para (A OR B) MINUS 1
                4'b0011: op_result = 4'b1111;  // Para MINUS 1
                4'b0100: op_result = a & b;    // Para A PLUS (A AND B)
                4'b0101: op_result = (a | b) | (a & b); // Para (A OR B) PLUS (A AND B)
                4'b0110: op_result = ~b;       // Para A MINUS B MINUS 1
                4'b0111: op_result = a & ~b;   // Para (A AND ~B) MINUS 1
                4'b1000: op_result = a & ~b;   // Para A PLUS (A AND ~B)
                4'b1001: op_result = b;        // Para A PLUS B
                4'b1010: op_result = (a | ~b) | (a & b); // Para (A OR ~B) PLUS (A AND B)
                4'b1011: op_result = a & b;    // Para (A AND B) MINUS 1
                4'b1100: op_result = a;        // Para A PLUS A
                4'b1101: op_result = (a | b) | a; // Para (A OR B) PLUS A
                4'b1110: op_result = (a | ~b) | a; // Para (A OR ~B) PLUS A
                4'b1111: op_result = a;        // Para A
                default: op_result = 4'b0000;
            endcase
        end else begin
            op_result = 4'b0000; // No modo lógico
        end
    end
    
    // Para cada bit, calculamos P e G conforme o datasheet
    generate
        genvar i;
        for (i = 0; i < 4; i = i + 1) begin: pg_gen
            // No modo aritmético, P e G dependem das operações
            // No modo lógico, P=0 e G=1 (desabilita look-ahead)
            assign p_bits[i] = (m == 1'b0) ? (a[i] | op_result[i]) : 1'b0;
            assign g_bits[i] = (m == 1'b0) ? (a[i] & op_result[i]) : 1'b0;
        end
    endgenerate
    
    // P e G para o carry look-ahead (para todo o grupo de 4 bits)
    // P = p0 & p1 & p2 & p3 (AND de todos os bits de propagate)
    // G = g3 | (p3 & g2) | (p3 & p2 & g1) | (p3 & p2 & p1 & g0)
    assign p = (m == 1'b0) ? &p_bits : 1'b0; // AND de todos os bits P
    assign g = (m == 1'b0) ? (
                g_bits[3] | 
                (p_bits[3] & g_bits[2]) | 
                (p_bits[3] & p_bits[2] & g_bits[1]) | 
                (p_bits[3] & p_bits[2] & p_bits[1] & g_bits[0])
              ) : 1'b1; // G = 1 no modo lógico

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
            // Modo aritmético (m = 0) - Operações conforme datasheet SN74LS181
            case (s)
                // F = A MINUS 1 (A - 1, implementado como A + 1111 + Cin)
                4'b0000: sum_arith = {1'b0, a} + {1'b0, 4'b1111} + c_in;

                // F = A PLUS (A OR B) (A + (A|B) + Cin)
                4'b0001: sum_arith = {1'b0, a} + {1'b0, a|b} + c_in;
                
                // F = (A OR B) MINUS 1 (implementado como (A|B) + 1111 + Cin)
                4'b0010: sum_arith = {1'b0, a|b} + {1'b0, 4'b1111} + c_in;
                
                // F = MINUS 1 (implementado como 0 + 1111 + Cin)
                4'b0011: sum_arith = {1'b0, 4'b0000} + {1'b0, 4'b1111} + c_in;
                
                // F = A PLUS (A AND B) (A + (A&B) + Cin)
                4'b0100: sum_arith = {1'b0, a} + {1'b0, a&b} + c_in;
                
                // F = (A OR B) PLUS (A AND B) (implementado como (A|B) + (A&B) + Cin)
                4'b0101: sum_arith = {1'b0, a|b} + {1'b0, a&b} + c_in;
                
                // F = A MINUS B MINUS 1 (implementado como A + ~B + Cin)
                4'b0110: sum_arith = {1'b0, a} + {1'b0, ~b} + c_in;
                
                // F = (A AND ~B) MINUS 1 (implementado como (A&~B) + 1111 + Cin)
                4'b0111: sum_arith = {1'b0, a&~b} + {1'b0, 4'b1111} + c_in;
                
                // F = A PLUS (A AND ~B) (A + (A&~B) + Cin)
                4'b1000: sum_arith = {1'b0, a} + {1'b0, a&~b} + c_in;
                
                // F = A PLUS B (A + B + Cin)
                4'b1001: sum_arith = {1'b0, a} + {1'b0, b} + c_in;
                
                // F = (A OR ~B) PLUS (A AND B) ((A|~B) + (A&B) + Cin)
                4'b1010: sum_arith = {1'b0, a|~b} + {1'b0, a&b} + c_in;
                
                // F = (A AND B) MINUS 1 ((A&B) + 1111 + Cin)
                4'b1011: sum_arith = {1'b0, a&b} + {1'b0, 4'b1111} + c_in;
                
                // F = A PLUS A (2*A + Cin)
                4'b1100: sum_arith = {1'b0, a} + {1'b0, a} + c_in;
                
                // F = (A OR B) PLUS A ((A|B) + A + Cin)
                4'b1101: sum_arith = {1'b0, a|b} + {1'b0, a} + c_in;
                
                // F = (A OR ~B) PLUS A ((A|~B) + A + Cin)
                4'b1110: sum_arith = {1'b0, a|~b} + {1'b0, a} + c_in;
                
                // F = A (A + 0 + Cin)
                4'b1111: sum_arith = {1'b0, a} + {1'b0, 4'b0000} + c_in;
                default: sum_arith = 5'bxxxxx;
            endcase

            f = sum_arith[3:0];
            
            // Tratamento do carry-out conforme exatamente a tabela do datasheet SN74LS181
            // O comportamento do carry varia conforme o código da operação S
            case (s)
                // Operações com carry complementado (subtração ou outras operações específicas)
                4'b0000: c_out = ~sum_arith[4]; // A MINUS 1
                4'b0010: c_out = ~sum_arith[4]; // (A OR B) MINUS 1
                4'b0011: c_out = ~sum_arith[4]; // MINUS 1
                4'b0110: c_out = ~sum_arith[4]; // A MINUS B MINUS 1
                4'b0111: c_out = ~sum_arith[4]; // (A AND ~B) MINUS 1
                4'b1011: c_out = ~sum_arith[4]; // (A AND B) MINUS 1
                
                // Operações com carry direto (adição e outras operações)
                default: c_out = sum_arith[4];
            endcase
        end
    end
endmodule