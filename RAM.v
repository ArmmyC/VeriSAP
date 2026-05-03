module RAM #(
    parameter width = 8,
    parameter depth = 16,
    parameter addr  = 4
  )(
    input  wire              Clock,
    input  wire              Clear,
    input  wire              Enable,
    input  wire              Read,
    input  wire              Write,
    input  wire [addr-1:0]   Read_Addr,
    input  wire [addr-1:0]   Write_Addr,
    input  wire [width-1:0]  Data_in,
    output wire [width-1:0]  Data_out
  );

  reg [width-1:0] tmp_ram [0:depth-1];
  reg [width-1:0] data_out_reg;

  integer i;

  assign Data_out = (Enable && Read) ? data_out_reg : {width{1'bz}};

  // Asynchronous read behavior
  always @(*)
  begin
    if (Enable && Read)
      data_out_reg = tmp_ram[Read_Addr];
    else
      data_out_reg = {width{1'bz}};
  end

  // Clear and write behavior
  always @(posedge Clock or posedge Clear)
  begin
    if (Clear)
    begin
      for (i = 0; i < depth; i = i + 1)
        tmp_ram[i] <= {width{1'b0}};
    end
    else
    begin
      if (Enable && Write)
        tmp_ram[Write_Addr] <= Data_in;
    end
  end

endmodule
