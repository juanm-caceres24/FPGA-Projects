module top #(
    parameter DATA_WIDTH = 8,
    parameter OP_WIDTH   = 6
)(
    input  wire                  clk,
    input  wire [DATA_WIDTH-1:0] sw,
    input  wire [3:0]            btn,
    output wire [DATA_WIDTH-1:0] led,
    output wire [1:0]            led_aux
);

    wire [DATA_WIDTH-1:0] sw_active_high = ~sw;

    reg [DATA_WIDTH-1:0] reg_a  = {DATA_WIDTH{1'b0}};
    reg [DATA_WIDTH-1:0] reg_b  = {DATA_WIDTH{1'b0}};
    reg [OP_WIDTH-1:0]   reg_op = {OP_WIDTH{1'b0}};

    always @(posedge clk) begin
        if (!btn[0]) begin
            reg_a <= sw_active_high;
        end
        if (!btn[1]) begin
            reg_b <= sw_active_high;
        end
        if (!btn[2]) begin
            reg_op <= sw_active_high[OP_WIDTH-1:0];
        end
    end

    wire [DATA_WIDTH-1:0] alu_result;
    wire                  alu_zero;

    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_alu (
        .a(reg_a),
        .b(reg_b),
        .alu_op(reg_op),
        .result(alu_result),
        .zero(alu_zero)
    );

    assign led     = alu_result;
    assign led_aux = {alu_zero, 1'b0};

endmodule
