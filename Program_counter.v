module Program_counter (
    input  wire       clock,
    input  wire       Ep,
    input  wire       clear,
    input  wire       count,
    output wire [3:0] Q
);

    reg [3:0] Pre_Q = 4'b0000;

    always @(negedge clock or posedge clear) begin
        if (clear)
            Pre_Q <= 4'b0000;
        else if (count)
            Pre_Q <= Pre_Q + 4'b0001;
    end

    assign Q = Ep ? Pre_Q : 4'bzzzz;

endmodule