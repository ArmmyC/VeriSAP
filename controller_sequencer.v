module controller_sequencer (
    input  wire       CLK,
    input  wire       clear,
    input  wire [7:4] I,
    output wire       Cp, Ep, Lm, CE, Li, Ei,
    output wire       La, Ea, Su, Eu, Lb, Lo,
    output wire       Mul, Div, UMul, UDiv,
    output wire       HALT
  );

  wire [6:1] T;
  wire LDA, ADD, SUB, OUTPUT, HLT, MUL, DIV, UMUL, UDIV;
  wire ALU_MEM_OP;

  ring_counter RC (
                 .CLK(CLK),
                 .clear(clear),
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
                        .UMUL(UMUL),
                        .UDIV(UDIV),
                        .HLT(HLT),
                        .OUTPUT(OUTPUT)
                      );

  assign ALU_MEM_OP = ADD | SUB | MUL | DIV | UMUL | UDIV;

  assign Cp   = T[2];
  assign Ep   = T[1];

  assign Lm   = ~((T[4] & LDA) | (T[4] & ALU_MEM_OP) | T[1]);
  assign CE   = ~((T[5] & LDA) | (T[5] & ALU_MEM_OP) | T[3]);
  assign Li   = ~T[3];
  assign Ei   = ~((T[4] & LDA) | (T[4] & ALU_MEM_OP));

  assign La   = ~((T[5] & LDA) | (T[6] & ALU_MEM_OP));
  assign Ea   = T[4] & OUTPUT;
  assign Su   = T[6] & SUB;
  assign Eu   = T[6] & ALU_MEM_OP;
  assign Lb   = ~(T[5] & ALU_MEM_OP);
  assign Lo   = ~(T[4] & OUTPUT);   // NAND
  assign Mul  = T[6] & MUL;
  assign Div  = T[6] & DIV;
  assign UMul = T[6] & UMUL;
  assign UDiv = T[6] & UDIV;

  assign HALT = HLT;

endmodule
