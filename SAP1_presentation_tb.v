`timescale 1ns / 1ps

module SAP1_presentation_tb;

    reg  [15:0] SW;
    reg  [4:0]  BTN;
    reg         CLK;

    wire [15:0] LED;
    wire [6:0]  SSEG_CA;
    wire [3:0]  SSEG_AN;

    // Simple presentation testbench:
    // load one addition program, run the CPU, and print the final answer.
    SAP1 #(
        .CLOCK_DIVIDER_BIT(0)
    ) uut (
        .SW(SW),
        .BTN(BTN),
        .CLK(CLK),
        .LED(LED),
        .SSEG_CA(SSEG_CA),
        .SSEG_AN(SSEG_AN)
    );

    initial begin
        CLK = 1'b0;
        forever #5 CLK = ~CLK;
    end

    task reset_cpu;
    begin
        BTN[4] = 1'b1;
        #100;
        BTN[4] = 1'b0;
        #100;
    end
    endtask

    task clear_ram;
    begin
        SW[11] = 1'b0;
        BTN[2] = 1'b1;
        #100;
        BTN[2] = 1'b0;
        #100;
    end
    endtask

    task write_ram;
        input [3:0] address;
        input [7:0] data;
    begin
        SW[15:12] = address;
        SW[7:0]   = data;
        SW[11]    = 1'b0;
        #50;
        BTN[1] = 1'b1;
        #50;
        BTN[1] = 1'b0;
        #100;
    end
    endtask

    initial begin
        SW  = 16'b0;
        BTN = 5'b0;

        #100;
        reset_cpu();
        clear_ram();

        // Demo program:
        // RAM[0] = B4 -> LDA 4
        // RAM[1] = 55 -> ADD 5
        // RAM[2] = 00 -> OUT
        // RAM[3] = 40 -> HLT
        // RAM[4] = 03
        // RAM[5] = 04
        write_ram(4'h0, 8'hB4);
        write_ram(4'h1, 8'h55);
        write_ram(4'h2, 8'h00);
        write_ram(4'h3, 8'h40);
        write_ram(4'h4, 8'd3);
        write_ram(4'h5, 8'd4);

        SW[11] = 1'b1;
        SW[10] = 1'b0;

        #5000;

        $display("--------------------------------");
        $display("Presentation demo: ADD");
        $display("Expected output register = 7");
        $display("Actual output register   = %0d", uut.out_reg_output);
        $display("Actual output register   = 0x%0h", uut.out_reg_output);
        $display("--------------------------------");

        if (uut.out_reg_output == 8'd7)
            $display("DEMO PASSED");
        else
            $display("DEMO FAILED");

        $stop;
    end

endmodule
