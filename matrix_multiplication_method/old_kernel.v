/*
Module: kernel or called processing element
Author: Chia-Jen Nieh
Description: 
    clk_in:          clock
    rst_in:          active low reset
    activation_in:   sliding window in an input layer
    weight_in:       weight of that kernel
    psum_in:         partial sum from previous kernel
    psum_out:        output the some of psum_in and the sum in this kernel
    activation_out:  pass to the kernel below
*/
module kernel (
    clk_in,
    rst_in,
    activation_in,
    weight_in,
    psum_in,
    // skip_in, //Don't do this here because complex
    activation_out,
    psum_out
);

input              clk_in, rst_in;
input        [8:0] activation_in;
input        [8:0] weight_in;
input        [6:0] psum_in;
// input        [3:0] skip_in; //How many inputs are ignored because the size isn't divisible by 9
output reg   [6:0] psum_out; //support 7 kernel, 9*7=63, with a sign bit
output reg   [8:0] activation_out;

reg                partial_product  [0:8];
reg          [3:0] population_count;
reg          [6:0] sum;

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
    sum = (2 * population_count - 5'd9) + psum_in;
end

always @(posedge clk_in or negedge rst_in) begin
    if (rst_in == 1'b0) begin
        psum_out <= 7'b0;
        activation_out <= 9'd0;
    end
    else begin
        psum_out <= sum;
        activation_out <= activation_in;
    end
end
endmodule