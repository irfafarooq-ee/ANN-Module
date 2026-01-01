module MAC #(parameter n = 32, parameter m = 3)(
    input                  rst, mac_en,
    input      [n-1:0]     x, w, 
    input      [2*n - 1:0] feed_in,
    output reg [2*n - 1:0] result
);

    always_comb begin
        if (!rst)
            result <= '0;
        else if (mac_en)
            result <= ($signed(x) * $signed(w)) + $signed(feed_in);
        else
            result <= '0;   // HOLD, do not accumulate
    end
endmodule
