module weight_file(
    input             rst, invalid,
    input      [4:0]  x_addr, rs1,
    output reg [31:0] w, x
);
    
    reg [31:0] weights [31:0]; //Depth of 32 weight memory
    reg [31:0] features [31:0]; //Depth of 32 for 32 bit features
    
    // Initialize memories from external files
    initial begin
        $readmemh("weights.mem", weights);   // Load weights from hex file
        $readmemh("features.mem", features); // Load features from hex file
    end
    
    always_comb begin
        if(!rst) begin
            w = 32'd0;
            x = 32'd0;
        end
        else if(!invalid) begin
            w = weights[rs1];
            x = features[x_addr];
        end
        else begin
            w = 32'd0;
            x = 32'd0;
        end
    end
endmodule
