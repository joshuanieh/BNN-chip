module BCNN (
    clk_in,
    reset_in,
    data_in,
    weight_in,
    bias_in,
    data_out
);
input              clk_in, reset_in;
input        [8:0] data_in;
input        [8:0] weight_in;
input        [3:0] bias_in; // -8 <= bias_in <= 7
output reg         data_out;

reg                binarized_out;
reg                partial_product  [0:8];
reg          [3:0] population_count;
reg          [4:0] true_sum;

integer i;
always @(*) begin
    for (i = 0; i < 9; i = i + 1) begin
        partial_product[i] = data_in[i] ~^ weight_in[i];
    end
end

always @(*) begin
    population_count = partial_product[0] +
                       partial_product[1] +
                       partial_product[2] +
                       partial_product[3] +
                       partial_product[4] +
                       partial_product[5] +
                       partial_product[6] +
                       partial_product[7] +
                       partial_product[8];    
end

//如果bias在這直接做，加速器跟CPU之間要傳輸的bit直接變1/5
always @(*) begin
    true_sum = 2 * population_count - 5'd9 + {bias_in[3], bias_in};
    if (true_sum[4] == 1'b1) begin
        binarized_out = 0;
    end
    else begin
        binarized_out = 1;
    end
end

always @(posedge clk_in or negedge reset_in) begin
    if (reset_in == 1'b0) begin
        data_out <= 1'b0;
    end
    else begin
        data_out <= binarized_out;
    end
end
endmodule