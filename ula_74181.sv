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

    // Variáveis internas para facilitar a lógica de carry e outras operações
    reg [4:0] sum_arith; // 4 bits para a soma e 1 bit para o carry out interno
    
    always_comb begin
        // Inicializa saídas
        f = 4'b0;
        a_eq_b = 1'b0;
        c_out = 1'b0;

        if (m == 1'b1) begin // Modo Lógico
            case (s)
                4'b0000: f = ~a;          // F = NOT A
                4'b0001: f = ~(a & b);    // F = NOT (A AND B)
                4'b0010: f = (~a) & b;    // F = (NOT A) AND B
                4'b0011: f = 4'b0000;     // F = 0
                4'b0100: f = ~(a | b);    // F = NOT (A OR B)
                4'b0101: f = ~b;          // F = NOT B
                4'b0110: f = a ^ b;       // F = A XOR B
                4'b0111: f = a & (~b);    // F = A AND (NOT B)
                4'b1000: f = (~a) | b;    // F = (NOT A) OR B
                4'b1001: f = ~(a ^ b);    // F = NOT (A XOR B)
                4'b1010: f = b;           // F = B
                4'b1011: f = a & b;       // F = A AND B
                4'b1100: f = 4'b1111;     // F = 1
                4'b1101: f = a | (~b);    // F = A OR (NOT B)
                4'b1110: f = a | b;       // F = A OR B
                4'b1111: f = a;           // F = A
                default: f = 4'bxxxx;     // Caso de erro/não especificado
            endcase
            // No modo lógico, o carry out não é gerado pela operação lógica.
            // A comparação a_eq_b pode ser feita independentemente do modo.
            a_eq_b = (a == b);
        end else begin // m == 1'b0 - Modo Aritmético
            // Para as operações aritméticas, as entradas s, a, b e c_in
            // precisam ser interpretadas de acordo com as funções do datasheet.
            // As operações aritméticas muitas vezes são implementadas de forma
            // que uma função "s" corresponde a uma operação particular com carry-in.
            // A ULA 74181 usa a lógica de A, B e C_in para construir as 16 operações.

            // Para simplificar a implementação, você pode usar uma combinação
            // de `s` e `c_in` para determinar a operação e então realizar
            // a soma ou subtração apropriada.
            // O datasheet mostra que a_s e b_s são os "operandos internos"
            // que são combinados com s para gerar o resultado final F.

            // A forma mais direta de implementar as operações aritméticas
            // é seguir a tabela do datasheet, que mapeia s para F.
            // No modo aritmético, a entrada A é combinada com B ou NOT B
            // dependendo da operação. As operações são tipicamente A + B, A - B, etc.
            // O carry-in (C_n) afeta o resultado final.

            // Vamos considerar a implementação para um somador/subtrator
            // baseado nas combinações de s e c_in.
            // A 74181 não é um somador direto A+B. Ela implementa as operações
            // como A mais alguma transformação de B e C_in.

            // Exemplo de como algumas operações aritméticas podem ser vistas:
            // S=9 (1001), M=0 -> F = A + B + C_in
            // S=6 (0110), M=0 -> F = A - B - 1 + C_in (ou A + ~B + C_in)

            // Para uma implementação fiel, você precisaria de um somador completo de 4 bits.
            // A lógica interna do 74181 é mais complexa, mas podemos usar a capacidade
            // do SystemVerilog para descrever as operações resultantes diretamente.

            // O datasheet é chave:
            // S = 0000 -> F = A
            // S = 0001 -> F = A + B + C_in
            // S = 0010 -> F = A + (~B) + C_in  (A - B - 1)
            // S = 0011 -> F = A - 1 + C_in
            // S = 0100 -> F = A + (A | ~B) + C_in  (A + A OR NOT B)
            // S = 0101 -> F = (A + B) + (A & ~B) + C_in
            // S = 0110 -> F = A - B - 1 + C_in
            // S = 0111 -> F = A + (~B) + C_in (igual a S=0010)

            // Simplificando e usando as operações equivalentes no SystemVerilog:
            case (s)
                4'b0000: begin // F = A (A-1 com C_n=0, A com C_n=1)
                    sum_arith = a + c_in;
                end
                4'b0001: begin // F = A + B + C_n
                    sum_arith = a + b + c_in;
                end
                4'b0010: begin // F = A + (~B) + C_n (A - B - 1)
                    sum_arith = a + (~b) + c_in;
                end
                4'b0011: begin // F = A - 1 + C_n (ou A + 1 com C_n=1)
                    sum_arith = a + 4'b1111 + c_in; // A + (-1) + C_n
                end
                4'b0100: begin // F = A + (A | ~B) + C_n
                    sum_arith = a + (a | (~b)) + c_in;
                end
                4'b0101: begin // F = (A + B) + (A & ~B) + C_n
                    sum_arith = (a + b) + (a & (~b)) + c_in;
                end
                4'b0110: begin // F = A - B - 1 + C_n
                    sum_arith = a + (~b) + c_in; // Equivalentemente, A + complement_of_B + C_n
                end
                4'b0111: begin // F = A + (~B) + C_n
                    sum_arith = a + (~b) + c_in;
                end
                4'b1000: begin // F = A + A + C_n (2A + C_n)
                    sum_arith = a + a + c_in;
                end
                4'b1001: begin // F = A + B + C_n
                    sum_arith = a + b + c_in;
                end
                4'b1010: begin // F = A + (~B) + C_n
                    sum_arith = a + (~b) + c_in;
                end
                4'b1011: begin // F = A - 1 + C_n
                    sum_arith = a + 4'b1111 + c_in;
                end
                4'b1100: begin // F = A + A + C_n
                    sum_arith = a + a + c_in;
                end
                4'b1101: begin // F = A + B + C_n
                    sum_arith = a + b + c_in;
                end
                4'b1110: begin // F = A + (~B) + C_n
                    sum_arith = a + (~b) + c_in;
                end
                4'b1111: begin // F = A + C_n
                    sum_arith = a + c_in;
                end
                default: sum_arith = 5'bxxxxx;
            endcase
            
            f = sum_arith[3:0];
            c_out = sum_arith[4]; // O carry out é o bit mais significativo

            // Para a_eq_b no modo aritmético:
            // A 74181 não tem uma saída a_eq_b direta para modo aritmético na mesma forma.
            // Geralmente, a igualdade é verificada por A-B = 0.
            // Se (A - B - 1 + c_in) = 0 e c_in = 1, então A == B.
            // No entanto, para simplificar e seguir a instrução do "comparador (ativa em nível alto quando a==b)",
            // podemos manter a comparação a==b, que é puramente lógica.
            // Para ser exato com a 74181, a A=B é derivada internamente de P e G (que você não precisa implementar).
            // Mantenha a_eq_b como (a == b) para consistência, a menos que especificado de outra forma pelo professor.
            a_eq_b = (a == b);
        end
    end

endmodule