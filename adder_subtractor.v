module adder_subtractor (
    input  wire [7:0] A,       // From accumulator
    input  wire [7:0] B,       // From B register
    input  wire       Su,
    input  wire       Mul,
    input  wire       Div,
    input  wire       Eu,
    output wire [7:0] Result,  // To bus
    output wire       Cout
  );

  reg [7:0] result_reg;
  reg       cout_reg;
  reg [8:0] addsub_reg;
  reg [15:0] product_reg;
  reg [7:0] quotient_reg;
  reg [7:0] dividend_reg;
  reg [7:0] divisor_reg;
  integer i;

  always @(*)
  begin
    result_reg = 8'b00000000;
    cout_reg = 1'b0;
    addsub_reg = 9'b000000000;
    product_reg = 16'b0000000000000000;
    quotient_reg = 8'b00000000;
    dividend_reg = A;
    divisor_reg = B;

    if (Mul)
    begin
      for (i = 0; i < 8; i = i + 1)
      begin
        if (B[i])
          product_reg = product_reg + ({8'b00000000, A} << i);
      end

      result_reg = product_reg[7:0];
      cout_reg = |product_reg[15:8];
    end
    else if (Div)
    begin
      if (B == 8'b00000000)
      begin
        result_reg = 8'hFF;
        cout_reg = 1'b1;
      end
      else
      begin
        quotient_reg = 8'b00000000;
        dividend_reg = A;

        for (i = 0; i < 256; i = i + 1)
        begin
          if (dividend_reg >= divisor_reg)
          begin
            dividend_reg = dividend_reg - divisor_reg;
            quotient_reg = quotient_reg + 8'b00000001;
          end
        end

        result_reg = quotient_reg;
        cout_reg = 1'b0;
      end
    end
    else
    begin
      if (Su)
        addsub_reg = {1'b0, A} + {1'b0, (~B)} + 9'b000000001;
      else
        addsub_reg = {1'b0, A} + {1'b0, B};

      result_reg = addsub_reg[7:0];
      cout_reg = addsub_reg[8];
    end
  end

  assign Cout = cout_reg;
  assign Result = Eu ? result_reg : 8'bzzzzzzzz;

endmodule
