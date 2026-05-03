module instruction_register (
    input  wire [7:0] I,       // From bus
    input  wire       clock,   // CLK
    input  wire       Li,      // ~Li
    input  wire       Ei,      // ~Ei
    input  wire       clear,   // CLR
    output wire [3:0] Qc,      // To controller
    output wire [3:0] Qb       // To bus
  );

  reg [7:0] Q_tmp = 8'b00000000;

  wire [7:0] I_bo;

  assign I_bo = (Li == 1'b0) ? I : Q_tmp;

  always @(posedge clock or posedge clear)
  begin
    if (clear)
      Q_tmp <= 8'b00000000;
    else
      Q_tmp <= I_bo;
  end

  assign Qc = Q_tmp[7:4];
  assign Qb = (Ei == 1'b0) ? Q_tmp[3:0] : 4'bzzzz;

endmodule
