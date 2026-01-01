module Quantizer #(parameter n = 32)(
    input                         rst,
    input  signed     [(2*n)-1:0] in,
    output reg signed [n-1:0]     out
);

    localparam integer SHIFT = 30;
    localparam signed [n-1:0] MAX_Q1_30 = 32'sd1073741823;
    localparam signed [n-1:0] MIN_Q1_30 = 32'sd0;

    wire signed [63:0] rounded;
    wire signed [63:0] shifted;

    assign rounded = in + (64'sd1 << (SHIFT - 1));
    assign shifted = rounded >>> SHIFT;

    always_comb begin
        if(!rst)
            out <= '0;
        else begin
            out <=  (shifted > MAX_Q1_30) ? MAX_Q1_30 :
                    (shifted < MIN_Q1_30) ? MIN_Q1_30 :
                                                       shifted[n-1:0];
        end
    end
endmodule
