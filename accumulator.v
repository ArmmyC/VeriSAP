module accumulator (
    input  wire [7:0] I,
    input  wire       clock,
    input  wire       La,     // ~La
    input  wire       Ea,
    input  wire       clear,
    output wire [7:0] Qas,    // To adder/subtractor
    output wire [7:0] Qb      // To bus
  );

  reg [7:0] Q_tmp = 8'b00000000;

  wire [7:0] I_bo;
  wire [7:0] Q_bi;

  assign I_bo = (La == 1'b0) ? I : Q_tmp;

  always @(posedge clock or posedge clear)
  begin
    if (clear)
      Q_tmp <= 8'b00000000;
    else
      Q_tmp <= I_bo;
  end

  assign Q_bi = Q_tmp;

  assign Qas = Q_bi;
  assign Qb  = Ea ? Q_bi : 8'bzzzzzzzz;

endmodule
