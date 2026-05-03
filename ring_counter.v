module ring_counter (
    input  wire       CLK,
    inout  wire [6:1] T
  );

  reg [6:1] T_reg = 6'b100000;

  assign T = T_reg;

  always @(posedge CLK)
  begin
    case (T_reg)
      6'b000001:
        T_reg <= 6'b000010;
      6'b000010:
        T_reg <= 6'b000100;
      6'b000100:
        T_reg <= 6'b001000;
      6'b001000:
        T_reg <= 6'b010000;
      6'b010000:
        T_reg <= 6'b100000;
      6'b100000:
        T_reg <= 6'b000001;
      default:
        T_reg <= 6'b100000;
    endcase
  end

endmodule
