`timescale 1ns / 1ps

module Out_tb;

    reg  [15:0] SW;
    reg  [4:0]  BTN;
    reg         CLK;

    wire [15:0] LED;
    wire [6:0]  SSEG_CA;
    wire [3:0]  SSEG_AN;

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

    task reset_sap1;
    begin
        SW[11] = 1'b0;
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
        reset_sap1();
        clear_ram();

        // Program:
        // LDA 4
        // OUT
        // HLT
        // RAM[4] = 8'hA5
        write_ram(4'h0, 8'hB4);
        write_ram(4'h1, 8'h00);
        write_ram(4'h2, 8'h40);
        write_ram(4'h4, 8'hA5);

        SW[11] = 1'b1;
        SW[10] = 1'b0;

        #5000;

        $display("--------------------------------");
        $display("Out_tb: OUT instruction");
        $display("Expected output register = a5");
        $display("Actual output register   = %h", uut.out_reg_output);
        $display("LED low byte             = %h", LED[7:0]);
        $display("--------------------------------");

        if ((uut.out_reg_output == 8'hA5) && (LED[7:0] == 8'hA5))
            $display("TEST PASSED: OUT copied accumulator to output register");
        else
            $display("TEST FAILED: expected a5, got output=%h LED=%h", uut.out_reg_output, LED[7:0]);

        $stop;
    end

endmodule
