module ReLU #(parameter n = 32)(
    input                         rst,
    input  signed     [(2*n)-1:0] result_in,
    output reg signed [(2*n)-1:0] result_out
);

    always_comb begin
        if(!rst)
            result_out <= '0;
        else
            result_out = result_in[(2*n)-1] ? {2*n{1'b0}} : result_in;
    end
endmodule
