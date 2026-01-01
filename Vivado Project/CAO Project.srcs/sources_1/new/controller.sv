module controller #(parameter m = 3, MEM_DEPTH = 32)(
    input            clk, rst,
    input      [4:0] x1_addr, x2_addr, x3_addr, rs1,
    output reg [4:0] x_addr, w_addr,
    output reg       invalid,
    output reg [$clog2(m+1)-1:0] num
);
    reg stop;
    reg [$clog2(m+1)-1:0] count;
    reg start;
    assign num = m - count - 1;
    
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        count <= m - 1;
        stop  <= 0;
        
    end 
    else if (!stop) begin
            if (count != 0)
                count <= count - 1;
            else
                stop <= 1;
    end
end
    
    always_comb begin
        x_addr  = '0;
        w_addr  = '0;
        invalid = 0;
        
        if (!stop) begin
            case (count)
                2: begin x_addr = x1_addr; w_addr = rs1;     end
                1: begin x_addr = x2_addr; w_addr = rs1 + 1; end
                0: begin x_addr = x3_addr; w_addr = rs1 + 2; end
            endcase

            if (x_addr >= MEM_DEPTH || w_addr >= MEM_DEPTH)
                invalid = 1;
        end
    end
endmodule
