`timescale 1ns/1ps

module tb_ANN();

    parameter n = 32;
    parameter m = 3;

    // Inputs
    reg clk;
    reg rst;
    reg [4:0] x1_addr, x2_addr, x3_addr;
    reg [4:0] rs1;
    reg       ann_en;
    // Outputs
    wire [31:0] result;
    wire invalid, done;

    // Instantiate the ANN
    ANN #(m,n) uut (
        .clk(clk),
        .rst(rst),
        .x1_addr(x1_addr),
        .x2_addr(x2_addr),
        .x3_addr(x3_addr),
        .rs1(rs1),
        .result(result),
        .invalid(invalid),
        .done(done)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 10ns clock period

    // Test vectors
    initial begin
        // Initialize reset
        rst = 0;
        x1_addr = 0; x2_addr = 1; x3_addr = 2;
        rs1 = 0;
        
        // Wait for a few cycles
        @(posedge clk);
        rst = 1;

        // Run simulation for enough cycles to finish MAC, ReLU, Quantizer
        repeat(6) begin
            @(posedge clk);
            $display("Time=%0t ns | x1_addr=%0d x2_addr=%0d x3_addr=%0d | rs1=%0d | invalid=%b | done=%b | result=%h",
                      $time, x1_addr, x2_addr, x3_addr, rs1, invalid, done, result);

            // Mmonitor internal pipeline signals
            $display("Controller: x_addr: %h, w_addr: %h, invalid: %b, flush: %b, count: %d", 
                      uut.x_addr, uut.w_addr, uut.invalid, uut.flush, uut.count);
            $display("Weight File: x: %h, w: %h", 
                      uut.x, uut.w);
            $display("Stage 1 Pipeline: x1: %h, w1: %h, count: %d", 
                      uut.x_1, uut.w_1, uut.count_1);
            $display("MAC Unit: mac result: %h, feed_in: %h", 
                      uut.result_mac, uut.feed_in);
            $display("Stage 2 Pipeline: mac result: %h, count: %d", 
                      uut.feed_in, uut.count_2);
            $display("ReLU Unit: relu result: %h", 
                      uut.result_relu);
            $display("Stage 3 Pipeline: relu result: %h, count: %d", 
                      uut.result_relu_3, uut.count_3);
            $display("Quantizer Unit: quantizer result: %h, done: %b", 
                      uut.result, uut.done);
            $display("-------------------------------------------------------------");
        end

       $stop;
    end

endmodule
