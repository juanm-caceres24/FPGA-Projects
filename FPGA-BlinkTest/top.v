module top (
    input  wire       clk,
    input  wire       btn1,
    input  wire       btn2,
    output wire [5:0] leds
);

    reg [31:0] counter = 32'd0;

    always @(posedge clk) begin
        counter <= counter + 1'b1;
    end

    reg [5:0] current_speed;

    always @(*) begin
        
        case ({btn1, btn2})
            2'b00: current_speed = counter[28:23];
            2'b10: current_speed = counter[27:22];
            2'b01: current_speed = counter[26:21];
            2'b11: current_speed = counter[25:20];
        endcase
    end

    assign leds = ~current_speed;

endmodule
