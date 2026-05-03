module Mux_4bit (
    input  wire [3:0] input_1,
    input  wire [3:0] input_2,
    input  wire sel,
    output wire [3:0] output_
  );

  assign output_ = sel ? input_2 : input_1;

endmodule
