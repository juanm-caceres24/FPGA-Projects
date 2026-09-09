module top #(
    parameter DATA_WIDTH = 8,
    parameter OP_WIDTH   = 6
)(
    input  wire                  clk,
    input  wire [DATA_WIDTH-1:0] sw,
    input  wire [3:0]            btn,
    output wire [DATA_WIDTH-1:0] led,
    output wire [3:0]            led_aux,
    
    // UART physical pins
    input  wire                  uart_rx,
    output wire                  uart_tx
);

    // INPUT SIGNALS (ACTIVE LOW)
    wire [DATA_WIDTH-1:0] sw_active_high = ~sw;
    
    wire rst   = ~btn[3]; // we will also use btn[3] to trigger TX
    wire en_a  = ~btn[0]; // enable for Register A from physical button
    wire en_b  = ~btn[1]; // enable for Register B
    wire en_op = ~btn[2]; // enable for Register OP

    // INTERNAL WIRES
    wire [DATA_WIDTH-1:0] val_a;
    wire [DATA_WIDTH-1:0] val_b;
    wire [OP_WIDTH-1:0]   val_op;

    wire [DATA_WIDTH-1:0] alu_result;
    wire                  alu_zero;
    wire                  alu_carry;
    wire                  alu_overflow;

    // UART INTERFACE WIRES
    wire [7:0] uart_r_data;
    wire       uart_rx_empty;
    wire       uart_tx_full;
    wire       uart_rd_trigger;
    
    // edge detection for physical button to send UART data
    reg rst_prev;
    always @(posedge clk) rst_prev <= rst;
    wire tx_start_pulse = rst & ~rst_prev; // Pulse only on button press

    // UART top module instantiation
    uart_top uart_inst (
        .clk(clk),
        .reset(1'b0), // avoid resetting UART to keep lines stable
        .rx(uart_rx),
        .tx(uart_tx),
        .rd_uart(uart_rd_trigger),
        .wr_uart(tx_start_pulse),
        .w_data(alu_result),
        .r_data(uart_r_data),
        .rx_empty(uart_rx_empty),
        .tx_full(uart_tx_full)
    );

    // if UART receives data, trigger a read automatically
    assign uart_rd_trigger = ~uart_rx_empty;

    // multiplexer for register A: loads from UART if data arrived, else from switches
    wire [DATA_WIDTH-1:0] reg_a_input = uart_rd_trigger ? uart_r_data : sw_active_high;
    wire                  reg_a_en    = uart_rd_trigger | en_a;

    // MODULE INSTANTIATIONS
    
    // register A (accepts both switch data and UART data)
    register #(
        .WIDTH(DATA_WIDTH)
    ) reg_a_inst (
        .clk(clk),
        .rst(1'b0), // disabled physical reset to preserve data
        .en(reg_a_en),
        .d(reg_a_input),
        .q(val_a)
    );

    // register B
    register #(
        .WIDTH(DATA_WIDTH)
    ) reg_b_inst (
        .clk(clk),
        .rst(1'b0),
        .en(en_b),
        .d(sw_active_high),
        .q(val_b)
    );

    // register OP
    register #(
        .WIDTH(OP_WIDTH)
    ) reg_op_inst (
        .clk(clk),
        .rst(1'b0),
        .en(en_op),
        .d(sw_active_high[OP_WIDTH-1:0]),
        .q(val_op)
    );

    // ALU
    alu #(
        .DATA_WIDTH(DATA_WIDTH)
    ) alu_inst (
        .a(val_a),
        .b(val_b),
        .alu_op(val_op),
        .result(alu_result),
        .zero(alu_zero),
        .carry(alu_carry),
        .overflow(alu_overflow)
    );

    // OUTPUT SIGNALS
    assign led = alu_result;
    
    // added tx_full to the unused LED to monitor transmission status
    assign led_aux = {uart_tx_full, alu_overflow, alu_zero, alu_carry};

endmodule