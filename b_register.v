module b_register (
    input  wire [7:0] I,
    input  wire       clock,   // CLK
    input  wire       Lb,      // ~Lb
    input  wire       clear,   // CLR
    output wire [7:0] Q        // To Add Sb
  );

  reg [7:0] Q_tmp = 8'b00000000;

  wire [7:0] I_bo;

  assign I_bo = (Lb == 1'b0) ? I : Q_tmp;

  always @(posedge clock or posedge clear)
  begin
    if (clear)
      Q_tmp <= 8'b00000000;
    else
      Q_tmp <= I_bo;
  end

  assign Q = Q_tmp;

endmodule
