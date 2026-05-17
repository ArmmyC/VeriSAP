module instruction_decoder (
    input  wire I7, I6, I5, I4,
    output wire LDA, ADD, SUB, MUL, DIV, UMUL, UDIV, OUTPUT, HLT
  );

  // 0000 OUTPUT
  // 0100 HLT
  // 0101 ADD
  // 0111 SUB
  // 1011 LDA
  // 1000 MUL  signed
  // 1001 DIV  signed
  // 1010 UMUL unsigned
  // 1100 UDIV unsigned

  assign LDA    =  I7 & ~I6 &  I5 &  I4;
  assign ADD    = ~I7 &  I6 & ~I5 &  I4;
  assign SUB    = ~I7 &  I6 &  I5 &  I4;
  assign OUTPUT = ~I7 & ~I6 & ~I5 & ~I4;
  assign HLT    = ~I7 &  I6 & ~I5 & ~I4;
  assign MUL    =  I7 & ~I6 & ~I5 & ~I4;
  assign DIV    =  I7 & ~I6 & ~I5 &  I4;
  assign UMUL   =  I7 & ~I6 &  I5 & ~I4;
  assign UDIV   =  I7 &  I6 & ~I5 & ~I4;

endmodule
