/*
Module: PE(processing element)
Author: Chia-Jen Nieh
Description: 
    clk_in:          clock
    activation_in:   sliding window in input layers
    weight_in:       weight of kernels
    psum_in:         partial sum from previous calculation
    activation_out:  pass to the kernel below
    psum_out:        output the sum of psum_in and the sum in this kernel
*/
module PE (
    clk_in,
    // rst_in,
    activation_in,
    weight_in,
    psum_in,
    activation_out,
    psum_out
);

parameter WIDTH = 14;

input                  clk_in;
input      [9-1:0]     activation_in;
input      [9-1:0]     weight_in;
input      [WIDTH-1:0] psum_in;
output reg [WIDTH-1:0] psum_out;
output reg [9-1:0]     activation_out;

reg                    partial_product [0:9-1];
reg        [4-1:0]     population_count;
reg        [WIDTH-1:0] psum_out_w;

integer i;

always @(*) begin
    for (i = 0; i < 9; i = i + 1) begin
        partial_product[i] = activation_in[i] ~^ weight_in[i];
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

always @(*) begin
    psum_out_w = (2 * population_count - 4'd9) + psum_in;
end

always @(posedge clk_in) begin
    psum_out <= psum_out_w;
    activation_out <= activation_in;
end

endmodule