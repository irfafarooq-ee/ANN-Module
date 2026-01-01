module ANN #(parameter m = 3, n = 32)(
    input         clk, rst,
    input  [4:0]  x1_addr, x2_addr, x3_addr, //feature values
    input  [4:0]  rs1, //address from where weights are to be fetched
    output [31:0] result,
    output        invalid, 
    output reg    done
);
    //Controller signals
    wire flush;
    wire [4:0] x_addr, w_addr;
    wire [$clog2(m+1)-1:0] count;
    
    //Weight file signals
    wire [n-1:0] w, x;
    
    //Stage 1 pipeline signals
    wire [n-1:0] w_1, x_1;
    wire [$clog2(m+1)-1:0] count_1;
    
    //MAC Signals
    wire             mac_en;
    wire [(2*n)-1:0] result_mac, feed_in; //feed_in is pipelined
    
    //Stage 2 Pipeline
    wire [$clog2(m+1)-1:0] count_2;
    
    //ReLU signals
    wire [(2*n)-1:0] result_relu;
        
    //Stage 3 pipeline signals
    wire [(2*n)-1:0] result_relu_3;
    wire [$clog2(m+1)-1:0] count_3;
    
    controller #(m, n) cntrl(
        .clk(clk), .rst(rst),
        .x1_addr(x1_addr), .x2_addr(x2_addr), .x3_addr(x3_addr), .rs1(rs1),
        .x_addr(x_addr), .w_addr(w_addr),
        .invalid(invalid),
        .num(count)
    );
    
    assign flush = (count_3 == (m - 1)) ? 1 : 0;
    
    always_comb begin
        if (!rst) begin
            done <= 1'b0;
        end
        else begin
            if (!done && (count_3 == (m - 1)))
                done <= 1'b1;
        end
    end

    weight_file WF(
        .rst(rst || !flush), .invalid(invalid),
        .x_addr(x_addr), .rs1(w_addr),
        .w(w), .x(x)
    );
    
    pipe_reg P11(
        .clk(clk), .rst(!flush), .stall(done),
        .data_in(w),
        .data_out(w_1)
    );

    pipe_reg P12(
        .clk(clk), .rst(!flush), .stall(done),
        .data_in(x),
        .data_out(x_1)
    );
    
    pipe_reg P13(
        .clk(clk), .rst(rst), .stall(done),
        .data_in(count),
        .data_out(count_1)
    );
    
    assign mac_en = (count_2 < (m-1));
    
    MAC mac(
        .rst(rst), .mac_en(mac_en),
        .x(x_1), .w(w_1), 
        .feed_in(feed_in),
        .result(result_mac)
    );
    
    pipe_reg #(2*n) P21(
        .clk(clk), .rst(rst || !flush), .stall(done),
        .data_in(result_mac),
        .data_out(feed_in)
    );

    pipe_reg P22(
        .clk(clk), .rst(rst), .stall(done),
        .data_in(count_1),
        .data_out(count_2)
    );
    
    ReLU #(n) relu(
        .rst(rst),
        .result_in(feed_in),   
        .result_out(result_relu)
    );
        
    pipe_reg #(2*n) P31(
        .clk(clk), .rst(rst), .stall(done),
        .data_in(result_relu),
        .data_out(result_relu_3)
    );
    
    pipe_reg P32(
        .clk(clk), .rst(rst), .stall(done),
        .data_in(count_2),
        .data_out(count_3)
    );
    
    Quantizer #(n) quan(
        .rst(rst),
        .in(result_relu_3),
        .out(result)
    );
    
endmodule
