module alu #(
    parameter DATA_WIDTH = 8
)(
    input  wire [DATA_WIDTH-1:0] a,
    input  wire [DATA_WIDTH-1:0] b,
    input  wire [5:0]            alu_op,
    output reg  [DATA_WIDTH-1:0] result,
    output wire                  zero
);

    localparam OP_ADD = 6'b100000;
    localparam OP_SUB = 6'b100010;
    localparam OP_AND = 6'b100100;
    localparam OP_OR  = 6'b100101;
    localparam OP_XOR = 6'b100110;
    localparam OP_NOR = 6'b100111;
    localparam OP_SRL = 6'b000010;
    localparam OP_SRA = 6'b000011;

    localparam SHIFT_WIDTH = (DATA_WIDTH <= 2) ? 1 : $clog2(DATA_WIDTH);

    always @(*) begin
        case (alu_op)
            OP_ADD:  result = a + b;
            OP_SUB:  result = a - b;
            OP_AND:  result = a & b;
            OP_OR:   result = a | b;
            OP_XOR:  result = a ^ b;
            OP_NOR:  result = ~(a | b);
            OP_SRL:  result = a >> b[SHIFT_WIDTH-1:0];
            OP_SRA:  result = $signed(a) >>> b[SHIFT_WIDTH-1:0];
            default: result = {DATA_WIDTH{1'b0}};
        endcase
    end

    assign zero = (result == {DATA_WIDTH{1'b0}}) ? 1'b1 : 1'b0;

endmodule
