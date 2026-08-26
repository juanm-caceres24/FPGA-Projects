module top #(
    parameter DATA_WIDTH = 8,
    parameter OP_WIDTH   = 6
)(
    input  wire                  clk,
    input  wire [DATA_WIDTH-1:0] sw_data,
    input  wire                  btn_load_a,
    input  wire                  btn_load_b,
    input  wire                  btn_load_op,
    output wire [DATA_WIDTH-1:0] led_res,
    output wire                  led_zero
);

    reg [DATA_WIDTH-1:0] reg_a  = {DATA_WIDTH{1'b0}};
    reg [DATA_WIDTH-1:0] reg_b  = {DATA_WIDTH{1'b0}};
    reg [OP_WIDTH-1:0]   reg_op = {OP_WIDTH{1'b0}};

    always @(posedge clk) begin
        if (!btn_load_a) begin
            reg_a <= sw_data;
        end

        if (!btn_load_b) begin
            reg_b <= sw_data;
        end

        if (!btn_load_op) begin
            reg_op <= sw_data[OP_WIDTH-1:0];
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

    assign led_res  = alu_result;
    assign led_zero = alu_zero;

endmodule
