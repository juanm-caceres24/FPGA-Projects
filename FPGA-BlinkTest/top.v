module top (
    input  wire       clk,
    output wire [5:0] leds
);
    reg [23:0] counter = 24'd0;

    always @(posedge clk) begin
        counter <= counter + 1'b1;
    end

    assign leds = ~counter[23:18];
endmodule
