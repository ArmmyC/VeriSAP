`timescale 1ns / 1ps

module AddSub_tb;

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

    task run_cpu;
    begin
        SW[11] = 1'b1;
        SW[10] = 1'b0;
        #5000;
    end
    endtask

    initial begin
        SW  = 16'b0;
        BTN = 5'b0;

        #100;

        // ADD test: 7 + 5 = 12
        reset_sap1();
        clear_ram();
        write_ram(4'h0, 8'hB4);   // LDA 4
        write_ram(4'h1, 8'h55);   // ADD 5
        write_ram(4'h2, 8'h00);   // OUT
        write_ram(4'h3, 8'h40);   // HLT
        write_ram(4'h4, 8'd7);
        write_ram(4'h5, 8'd5);
        run_cpu();

        $display("--------------------------------");
        $display("AddSub_tb: ADD instruction");
        $display("Expected output register = 12");
        $display("Actual output register   = %0d", uut.out_reg_output);
        $display("Actual output register   = %h", uut.out_reg_output);
        $display("--------------------------------");

        if (uut.out_reg_output == 8'd12)
            $display("TEST PASSED: 7 + 5 = 12");
        else
            $display("TEST FAILED: expected 12, got %0d", uut.out_reg_output);

        // SUB test: 9 - 4 = 5
        reset_sap1();
        clear_ram();
        write_ram(4'h0, 8'hB4);   // LDA 4
        write_ram(4'h1, 8'h75);   // SUB 5
        write_ram(4'h2, 8'h00);   // OUT
        write_ram(4'h3, 8'h40);   // HLT
        write_ram(4'h4, 8'd9);
        write_ram(4'h5, 8'd4);
        run_cpu();

        $display("--------------------------------");
        $display("AddSub_tb: SUB instruction");
        $display("Expected output register = 5");
        $display("Actual output register   = %0d", uut.out_reg_output);
        $display("Actual output register   = %h", uut.out_reg_output);
        $display("--------------------------------");

        if (uut.out_reg_output == 8'd5)
            $display("TEST PASSED: 9 - 4 = 5");
        else
            $display("TEST FAILED: expected 5, got %0d", uut.out_reg_output);

        $stop;
    end

endmodule
