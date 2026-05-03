`timescale 1ns / 1ps

module SAP1_tb;

    reg  [15:0] SW;
    reg  [4:0]  BTN;
    reg         CLK;

    wire [15:0] LED;
    wire [6:0]  SSEG_CA;
    wire [3:0]  SSEG_AN;
    reg         div_zero_flag_seen;

    // Instantiate SAP1 top module
    SAP1 #(
        .CLOCK_DIVIDER_BIT(0)
    ) uut (
        .SW(SW),
        .BTN(BTN),
        .LED(LED),
        .SSEG_CA(SSEG_CA),
        .SSEG_AN(SSEG_AN),
        .CLK(CLK)
    );

    // 100 MHz clock, same as Basys3
    initial begin
        CLK = 1'b0;
        forever #5 CLK = ~CLK;
    end

    // Task: reset SAP1
    task reset_sap1;
    begin
        BTN[4] = 1'b1;   // Clear / Reset
        #100;
        BTN[4] = 1'b0;
        #100;
    end
    endtask

    // Task: clear RAM in programming mode
    task clear_ram;
    begin
        SW[11] = 1'b0;
        BTN[2] = 1'b1;
        #100;
        BTN[2] = 1'b0;
        #100;
    end
    endtask

    // Task: write one byte into RAM
    task write_ram;
        input [3:0] address;
        input [7:0] data;
    begin
        SW[15:12] = address;   // RAM address
        SW[7:0]   = data;      // RAM data
        SW[11]    = 1'b0;      // run = 0, programming mode

        #50;

        BTN[1] = 1'b1;         // press write button
        #50;
        BTN[1] = 1'b0;         // release write button

        #100;
    end
    endtask

    task start_cpu_and_wait;
    begin
        SW[11] = 1'b1;     // run = 1
        SW[10] = 1'b0;
        #5000;
    end
    endtask

    initial begin
        // Initial values
        SW  = 16'b0;
        BTN = 5'b0;
        div_zero_flag_seen = 1'b0;

        #100;

        // Reset CPU
        reset_sap1();

        // Test 1: MUL
        div_zero_flag_seen = 1'b0;
        clear_ram();
        write_ram(4'h0, 8'hB4);   // LDA 4
        write_ram(4'h1, 8'h85);   // MUL 5
        write_ram(4'h2, 8'h00);   // OUT
        write_ram(4'h3, 8'h40);   // HLT
        write_ram(4'h4, 8'd3);    // Data 3
        write_ram(4'h5, 8'd4);    // Data 4
        start_cpu_and_wait();

        $display("--------------------------------");
        $display("Test 1: MUL");
        $display("LED output      = %b", LED);
        $display("Output register = %d", uut.out_reg_output);
        $display("Output register = %h", uut.out_reg_output);
        $display("Cout            = %b", uut.cout);
        $display("--------------------------------");

        if (uut.out_reg_output == 8'd12)
            $display("TEST PASSED: 3 * 4 = 12");
        else
            $display("TEST FAILED: expected 12, got %d", uut.out_reg_output);

        reset_sap1();

        // Test 2: DIV
        div_zero_flag_seen = 1'b0;
        clear_ram();
        write_ram(4'h0, 8'hB4);   // LDA 4
        write_ram(4'h1, 8'h95);   // DIV 5
        write_ram(4'h2, 8'h00);   // OUT
        write_ram(4'h3, 8'h40);   // HLT
        write_ram(4'h4, 8'd12);   // Data 12
        write_ram(4'h5, 8'd4);    // Data 4
        start_cpu_and_wait();

        $display("--------------------------------");
        $display("Test 2: DIV");
        $display("LED output      = %b", LED);
        $display("Output register = %d", uut.out_reg_output);
        $display("Output register = %h", uut.out_reg_output);
        $display("Cout            = %b", uut.cout);
        $display("--------------------------------");

        if (uut.out_reg_output == 8'd3)
            $display("TEST PASSED: 12 / 4 = 3");
        else
            $display("TEST FAILED: expected 3, got %d", uut.out_reg_output);

        reset_sap1();

        // Test 3: DIV by zero
        div_zero_flag_seen = 1'b0;
        clear_ram();
        write_ram(4'h0, 8'hB4);   // LDA 4
        write_ram(4'h1, 8'h95);   // DIV 5
        write_ram(4'h2, 8'h00);   // OUT
        write_ram(4'h3, 8'h40);   // HLT
        write_ram(4'h4, 8'd12);   // Data 12
        write_ram(4'h5, 8'd0);    // Data 0
        SW[11] = 1'b1;            // run = 1
        SW[10] = 1'b0;

        wait (uut.Div == 1'b1);
        #1;
        if (uut.cout == 1'b1)
            div_zero_flag_seen = 1'b1;

        #5000;

        $display("--------------------------------");
        $display("Test 3: DIV by zero");
        $display("LED output      = %b", LED);
        $display("Output register = %d", uut.out_reg_output);
        $display("Output register = %h", uut.out_reg_output);
        $display("Cout (sampled at DIV execute) = %b", div_zero_flag_seen);
        $display("--------------------------------");

        if ((uut.out_reg_output == 8'hFF) && (div_zero_flag_seen == 1'b1))
            $display("TEST PASSED: 12 / 0 = FF with div-zero flag");
        else
            $display("TEST FAILED: expected FF and sampled div-zero flag=1, got %h and sampled flag=%b", uut.out_reg_output, div_zero_flag_seen);

        $stop;
    end

endmodule
