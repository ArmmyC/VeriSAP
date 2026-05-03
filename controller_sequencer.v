module controller_sequencer (
    input  wire       CLK,
    input  wire [7:4] I,
    output wire       Cp, Ep, Lm, CE, Li, Ei,
    output wire       La, Ea, Su, Eu, Lb, Lo,
    output wire       Mul, Div,
    output wire       HALT
  );

  wire [6:1] T;
  wire LDA, ADD, SUB, OUTPUT, HLT, MUL, DIV;

  ring_counter RC (
                 .CLK(CLK),
                 .T(T)
               );

  instruction_decoder ID (
                        .I7(I[7]),
                        .I6(I[6]),
                        .I5(I[5]),
                        .I4(I[4]),
                        .LDA(LDA),
                        .ADD(ADD),
                        .SUB(SUB),
                        .MUL(MUL),
                        .DIV(DIV),
                        .HLT(HLT),
                        .OUTPUT(OUTPUT)
                      );

  assign Cp   = T[2];
  assign Ep   = T[1];

  assign Lm   = ~((T[4] & LDA) | (T[4] & ADD) | (T[4] & SUB) | (T[4] & MUL) | (T[4] & DIV) | T[1]);
  assign CE   = ~((T[5] & LDA) | (T[5] & ADD) | (T[5] & SUB) | (T[5] & MUL) | (T[5] & DIV) | T[3]);
  assign Li   = ~T[3];
  assign Ei   = ~((T[4] & LDA) | (T[4] & ADD) | (T[4] & SUB) | (T[4] & MUL) | (T[4] & DIV));

  assign La   = ~((T[5] & LDA) | (T[6] & ADD) | (T[6] & SUB) | (T[6] & MUL) | (T[6] & DIV));
  assign Ea   = T[4] & OUTPUT;
  assign Su   = T[6] & SUB;
  assign Eu   = (T[6] & ADD) | (T[6] & SUB) | (T[6] & MUL) | (T[6] & DIV);
  assign Lb   = ~((T[5] & ADD) | (T[5] & SUB) | (T[5] & MUL) | (T[5] & DIV));
  assign Lo   = ~(T[4] & OUTPUT);   // NAND
  assign Mul  = T[6] & MUL;
  assign Div  = T[6] & DIV;

  assign HALT = HLT;

endmodule
