module SAP1 #(
    parameter CLOCK_DIVIDER_BIT = 22
  )(
    input  wire [15:0] SW,
    input  wire [4:0]  BTN,
    input  wire        CLK,
    output reg  [15:0] LED,
    output wire [6:0]  SSEG_CA,
    output wire [3:0]  SSEG_AN
  );

  // Internal signals
  wire clockline;

  wire [3:0] MAR_output;

  wire Cp, Ep, Lm, CE, Li, Ei, La, Ea, Su, Eu, Lb, Lo, Mul, Div, UMul, UDiv, HALT;
  wire [7:4] I;

  wire [3:0] RAM_address;
  wire RAM_clock, RAM_clear, RAM_load, RAM_store;
  wire [7:0] RAM_output;
  wire [7:0] W_out_RAM;

  wire [7:0] AS_accumulator, AS_b_register;
  wire cout;

  wire [7:0] out_reg_output;

  reg  [29:0] countD = 30'd0;
  wire selector;

  wire clock_activator;

  // Bus signals
  reg  [7:0] W_bus;
  reg  [3:0] W_in_MAR;
  reg  [7:0] W_in_IR, W_in_ACC, W_in_BR, W_in_OR;

  wire [3:0] W_out_PC;
  wire [3:0] W_out_IR;
  wire [7:0] W_out_ACC;
  wire [7:0] W_out_AS;

  // ================= BUS LOGIC =================
  always @(*)
  begin
    W_bus = 8'b00000000;
    W_in_MAR = 4'b0000;
    W_in_IR  = 8'b00000000;
    W_in_ACC = 8'b00000000;
    W_in_BR  = 8'b00000000;
    W_in_OR  = 8'b00000000;

    if (Ep)
      W_bus[3:0] = W_out_PC;
    else if (RAM_load)
      W_bus = W_out_RAM;
    else if (!Ei)
      W_bus[3:0] = W_out_IR;
    else if (Ea)
      W_bus = W_out_ACC;
    else if (Eu)
      W_bus = W_out_AS;

    if (!Lm)
      W_in_MAR = W_bus[3:0];
    if (!Li)
      W_in_IR  = W_bus;
    if (!La)
      W_in_ACC = W_bus;
    if (!Lb)
      W_in_BR  = W_bus;
    if (!Lo)
      W_in_OR  = W_bus;

    if (!SW[11])
    begin
      LED = SW;
    end
    else
    begin
      LED[15:8] = W_bus;
      LED[7:0]  = out_reg_output;
    end
  end

  // ================= COMPONENTS =================

  Mux_4bit MUX (
             .input_1(SW[15:12]),
             .input_2(MAR_output),
             .sel(SW[11]),
             .output_(RAM_address)
           );

  Program_counter PC0 (
                    .clock(clockline),
                    .Ep(Ep),
                    .clear(BTN[4]),
                    .count(Cp),
                    .Q(W_out_PC)
                  );

  MAR MAR1 (
        .I(W_in_MAR),
        .clock(clockline),
        .Lm(Lm),
        .clear(BTN[4]),
        .Q(MAR_output)
      );

  instruction_register IR3 (
                         .I(W_in_IR),
                         .clock(clockline),
                         .Li(Li),
                         .Ei(Ei),
                         .clear(BTN[4]),
                         .Qc(I),
                         .Qb(W_out_IR)
                       );

  assign RAM_clock = (~SW[11]) & BTN[1];
  assign RAM_clear = (~SW[11]) & BTN[2];
  assign RAM_load  = ~CE;
  assign RAM_store = ~SW[11];

  RAM RAM4 (
        .Clock(RAM_clock),
        .Clear(RAM_clear),
        .Enable(1'b1),
        .Read(RAM_load),
        .Write(RAM_store),
        .Read_Addr(RAM_address),
        .Write_Addr(RAM_address),
        .Data_in(SW[7:0]),
        .Data_out(W_out_RAM)
      );

  RAM RAM4_DUP (
        .Clock(RAM_clock),
        .Clear(RAM_clear),
        .Enable(1'b1),
        .Read(1'b1),
        .Write(RAM_store),
        .Read_Addr(SW[15:12]),
        .Write_Addr(RAM_address),
        .Data_in(SW[7:0]),
        .Data_out(RAM_output)
      );

  controller_sequencer CS5 (
                         .CLK(clockline),
                         .clear(BTN[4]),
                         .I(I),
                         .Cp(Cp), .Ep(Ep), .Lm(Lm), .CE(CE),
                         .Li(Li), .Ei(Ei), .La(La), .Ea(Ea),
                         .Su(Su), .Eu(Eu), .Lb(Lb), .Lo(Lo),
                         .Mul(Mul), .Div(Div),
                         .UMul(UMul), .UDiv(UDiv),
                         .HALT(HALT)
                       );

  accumulator ACC6 (
                .I(W_in_ACC),
                .clock(clockline),
                .La(La),
                .Ea(Ea),
                .clear(BTN[4]),
                .Qas(AS_accumulator),
                .Qb(W_out_ACC)
              );

  adder_subtractor AS7 (
                     .A(AS_accumulator),
                     .B(AS_b_register),
                     .Su(Su),
                     .Mul(Mul),
                     .Div(Div),
                     .UMul(UMul),
                     .UDiv(UDiv),
                     .Eu(Eu),
                     .Result(W_out_AS),
                     .Cout(cout)
                   );

  b_register BR8 (
               .I(W_in_BR),
               .clock(clockline),
               .Lb(Lb),
               .clear(BTN[4]),
               .Q(AS_b_register)
             );

  output_register OR9 (
                    .I(W_in_OR),
                    .clock(clockline),
                    .Lo(Lo),
                    .clear(BTN[4]),
                    .Q(out_reg_output)
                  );

  seven_segment_display SCREEN (
                          .SSEG_CA(SSEG_CA),
                          .SSEG_AN(SSEG_AN),
                          .CLK(CLK),
                          .address(SW[15:12]),
                          .data(SW[7:0]),
                          .write_to_RAM(BTN[1]),
                          .run(SW[11]),
                          .out_reg_output(out_reg_output),
                          .RAM_output(RAM_output),
                          .show_RAM_output(SW[10])
                        );

  // ================= CLOCK CONTROL =================

  assign clock_activator = (~HALT) & SW[11];

  assign clockline = (clock_activator) ? selector : 1'b0;

  always @(posedge CLK)
  begin
    countD <= countD + 1'b1;
  end

  assign selector = countD[CLOCK_DIVIDER_BIT];

endmodule
