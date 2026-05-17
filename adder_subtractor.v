module adder_subtractor (
    input  wire [7:0] A,       // From accumulator
    input  wire [7:0] B,       // From B register
    input  wire       Su,
    input  wire       Mul,
    input  wire       Div,
    input  wire       UMul,
    input  wire       UDiv,
    input  wire       Eu,
    output wire [7:0] Result,  // To bus
    output wire       Cout
  );

  reg [7:0] result_reg;
  reg       cout_reg;
  reg [8:0] addsub_reg;
  reg [15:0] product_reg;
  reg [8:0] booth_a_reg;
  reg [7:0] booth_q_reg;
  reg       booth_qm1_reg;
  reg [8:0] booth_m_reg;
  reg [8:0] booth_neg_m_reg;
  reg [8:0] div_remainder_reg;
  reg [7:0] div_quotient_reg;
  reg [7:0] div_dividend_abs_reg;
  reg [7:0] div_divisor_abs_reg;
  reg [7:0] div_signed_result_reg;
  reg [8:0] div_sub_reg;
  reg       result_sign_reg;
  integer i;

  always @(*)
  begin
    result_reg = 8'b00000000;
    cout_reg = 1'b0;
    addsub_reg = 9'b000000000;
    product_reg = 16'b0000000000000000;
    booth_a_reg = 9'b000000000;
    booth_q_reg = B;
    booth_qm1_reg = 1'b0;
    booth_m_reg = {A[7], A};
    booth_neg_m_reg = (~{A[7], A}) + 9'b000000001;
    div_remainder_reg = 9'b000000000;
    div_quotient_reg = 8'b00000000;
    div_dividend_abs_reg = A[7] ? ((~A) + 8'b00000001) : A;
    div_divisor_abs_reg = B[7] ? ((~B) + 8'b00000001) : B;
    div_signed_result_reg = 8'b00000000;
    div_sub_reg = 9'b000000000;
    result_sign_reg = A[7] ^ B[7];

    if (UMul)
    begin
      for (i = 0; i < 8; i = i + 1)
      begin
        if (B[i])
          product_reg = product_reg + ({8'b00000000, A} << i);
      end

      result_reg = product_reg[7:0];
      cout_reg = (product_reg[15:8] != 8'b00000000) ? 1'b1 : 1'b0;
    end
    else if (UDiv)
    begin
      if (B == 8'b00000000)
      begin
        result_reg = 8'hFF;
        cout_reg = 1'b1;
      end
      else
      begin
        div_remainder_reg = 9'b000000000;
        div_quotient_reg = A;

        for (i = 0; i < 8; i = i + 1)
        begin
          div_remainder_reg = {div_remainder_reg[7:0], div_quotient_reg[7]};
          div_quotient_reg = {div_quotient_reg[6:0], 1'b0};
          div_sub_reg = div_remainder_reg - {1'b0, B};

          if (div_sub_reg[8] == 1'b0)
          begin
            div_remainder_reg = div_sub_reg;
            div_quotient_reg[0] = 1'b1;
          end
        end

        result_reg = div_quotient_reg;
        cout_reg = 1'b0;
      end
    end
    else if (Mul)
    begin
      for (i = 0; i < 8; i = i + 1)
      begin
        case ({booth_q_reg[0], booth_qm1_reg})
          2'b01:
            booth_a_reg = booth_a_reg + booth_m_reg;
          2'b10:
            booth_a_reg = booth_a_reg + booth_neg_m_reg;
          default:
            booth_a_reg = booth_a_reg;
        endcase

        booth_qm1_reg = booth_q_reg[0];
        booth_q_reg = {booth_a_reg[0], booth_q_reg[7:1]};
        booth_a_reg = {booth_a_reg[8], booth_a_reg[8:1]};
      end

      product_reg = {booth_a_reg[7:0], booth_q_reg};
      result_reg = product_reg[7:0];
      cout_reg = (product_reg[15:8] != {8{product_reg[7]}}) ? 1'b1 : 1'b0;
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
        div_remainder_reg = 9'b000000000;
        div_quotient_reg = div_dividend_abs_reg;

        for (i = 0; i < 8; i = i + 1)
        begin
          div_remainder_reg = {div_remainder_reg[7:0], div_quotient_reg[7]};
          div_quotient_reg = {div_quotient_reg[6:0], 1'b0};
          div_sub_reg = div_remainder_reg - {1'b0, div_divisor_abs_reg};

          if (div_sub_reg[8] == 1'b0)
          begin
            div_remainder_reg = div_sub_reg;
            div_quotient_reg[0] = 1'b1;
          end
        end

        if (result_sign_reg)
          div_signed_result_reg = (~div_quotient_reg) + 8'b00000001;
        else
          div_signed_result_reg = div_quotient_reg;

        result_reg = div_signed_result_reg;
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
