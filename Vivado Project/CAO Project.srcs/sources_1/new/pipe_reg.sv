module pipe_reg #(parameter n = 32)(
    input  clk, rst, stall,
    input  [n-1:0] data_in,
    output reg [n-1:0] data_out
);
    always @(posedge clk or negedge rst) begin
        if(!rst)
            data_out <= 0; 
        else if(!stall)
            data_out <= data_in;
    end
endmodule