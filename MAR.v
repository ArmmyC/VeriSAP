module MAR (
    input  wire [3:0] I,       // Input จาก Bus
    input  wire       clock,   //
    input  wire       Lm,      // Load MAR
    input  wire       clear,
    output wire [3:0] Q
  );

  reg [3:0] Q_tmp = 4'b0000;

  wire [3:0] I_bo;

  assign I_bo = (Lm == 1'b0) ? I : Q_tmp;

  always @(posedge clock or posedge clear)
  begin
    if (clear)
      Q_tmp <= 4'b0000;
    else
      Q_tmp <= I_bo;
  end

  assign Q = Q_tmp;

endmodule
