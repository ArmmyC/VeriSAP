module seven_segment_display (
    output reg [6:0] SSEG_CA,
    output reg [3:0] SSEG_AN,
    input  wire      CLK,
    input  wire [3:0] address,
    input  wire [7:0] data,
    input  wire       write_to_RAM,
    input  wire       run,
    input  wire [7:0] out_reg_output,
    input  wire [7:0] RAM_output,
    input  wire       show_RAM_output
  );

  reg [19:0] count = 20'd0;
  wire [1:0] selector;
  reg [3:0] seven_seg_in;
  reg       decode_enable;

  // Counter
  always @(posedge CLK)
  begin
    count <= count + 1'b1;
  end

  assign selector = count[19:18];

  // Main logic
  always @(*)
  begin

    // Default (avoid inferred latches)
    SSEG_CA = 7'b1111111;
    SSEG_AN = 4'b1111;
    seven_seg_in = 4'b0000;
    decode_enable = 1'b0;

    if (run == 1'b0)
    begin

      if (show_RAM_output || write_to_RAM)
      begin

        // Digit select
        case (selector)
          2'b00:
          begin
            SSEG_AN = 4'b0111;
            seven_seg_in = address;
            decode_enable = 1'b1;
          end
          2'b01:
          begin
            SSEG_AN = 4'b1011;
            SSEG_CA = 7'b1111111;
          end
          2'b10:
          begin
            SSEG_AN = 4'b1101;
            seven_seg_in = RAM_output[7:4];
            decode_enable = 1'b1;
          end
          2'b11:
          begin
            SSEG_AN = 4'b1110;
            seven_seg_in = RAM_output[3:0];
            decode_enable = 1'b1;
          end
        endcase

      end
      else
      begin
        // Display "SAP1"
        case (selector)
          2'b00:
          begin
            SSEG_CA = 7'b0010010;
            SSEG_AN = 4'b0111;
          end // S
          2'b01:
          begin
            SSEG_CA = 7'b0001000;
            SSEG_AN = 4'b1011;
          end // A
          2'b10:
          begin
            SSEG_CA = 7'b0001100;
            SSEG_AN = 4'b1101;
          end // P
          2'b11:
          begin
            SSEG_CA = 7'b1111001;
            SSEG_AN = 4'b1110;
          end // 1
        endcase
      end

    end
    else
    begin
      // run = 1
      case (selector)
        2'b00:
        begin
          SSEG_AN = 4'b0111;
          SSEG_CA = 7'b1111111;
        end
        2'b01:
        begin
          SSEG_AN = 4'b1011;
          SSEG_CA = 7'b1111111;
        end
        2'b10:
        begin
          SSEG_AN = 4'b1101;
          seven_seg_in = out_reg_output[7:4];
          decode_enable = 1'b1;
        end
        2'b11:
        begin
          SSEG_AN = 4'b1110;
          seven_seg_in = out_reg_output[3:0];
          decode_enable = 1'b1;
        end
      endcase
    end

    // 7-seg decode (applies whenever seven_seg_in is used)
    if (decode_enable)
    begin
      case (seven_seg_in)
        4'h0:
          SSEG_CA = 7'b1000000;
        4'h1:
          SSEG_CA = 7'b1111001;
        4'h2:
          SSEG_CA = 7'b0100100;
        4'h3:
          SSEG_CA = 7'b0110000;
        4'h4:
          SSEG_CA = 7'b0011001;
        4'h5:
          SSEG_CA = 7'b0010010;
        4'h6:
          SSEG_CA = 7'b0000010;
        4'h7:
          SSEG_CA = 7'b1111000;
        4'h8:
          SSEG_CA = 7'b0000000;
        4'h9:
          SSEG_CA = 7'b0010000;
        4'hA:
          SSEG_CA = 7'b0100000;
        4'hB:
          SSEG_CA = 7'b0000011;
        4'hC:
          SSEG_CA = 7'b1000110;
        4'hD:
          SSEG_CA = 7'b0100001;
        4'hE:
          SSEG_CA = 7'b0000110;
        4'hF:
          SSEG_CA = 7'b0001110;
      endcase
    end

  end

endmodule
