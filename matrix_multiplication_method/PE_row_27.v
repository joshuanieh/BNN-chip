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
`include "PE_27.v"
module PE_row (
    clk_in,
    rst_in,
    activation_in,
    weight_in,
    psum_in,
    activation_out,
    psum_out
);

parameter WIDTH = 14;

input                  clk_in, rst_in;
input      [27*3-1:0]  activation_in;
input      [27*3-1:0]  weight_in;
input      [WIDTH-1:0] psum_in;
output     [WIDTH-1:0] psum_out;
output     [27*3-1:0]  activation_out;

wire       [WIDTH-1:0] psum_1_to_2, psum_2_to_3;

PE PE_1 (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .activation_in(activation_in[27*3-1:27*2]),
    .weight_in(weight_in[27*3-1:27*2]),
    .psum_in(psum_in),
    .activation_out(activation_out[27*3-1:27*2]),
    .psum_out(psum_1_to_2)
);

PE PE_2 (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .activation_in(activation_in[27*2-1:27*1]),
    .weight_in(weight_in[27*2-1:27*1]),
    .psum_in(psum_1_to_2),
    .activation_out(activation_out[27*2-1:27*1]),
    .psum_out(psum_2_to_3)
);

PE PE_3 (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .activation_in(activation_in[27*1-1:27*0]),
    .weight_in(weight_in[27*1-1:27*0]),
    .psum_in(psum_2_to_3),
    .activation_out(activation_out[27*1-1:27*0]),
    .psum_out(psum_out)
);

endmodule