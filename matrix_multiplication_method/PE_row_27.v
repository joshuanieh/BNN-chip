/*
Module: PE_row
Author: Chia-Jen Nieh
Description: 
    clk_in:          clock
    rst_in:          active low reset
    activation_in:   sliding window in input layers
    weight_in:       weight of PE's
    psum_in:         partial sum from previous calculation
    psum_out:        output psum_out of the last PE
    activation_out:  pass to the PE's below
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
parameter ROW_LENGTH = 7;

input                          clk_in, rst_in;
input      [27*ROW_LENGTH-1:0] activation_in;
input      [27*ROW_LENGTH-1:0] weight_in;
input      [WIDTH-1:0]         psum_in;
output     [WIDTH-1:0]         psum_out;
output     [27*ROW_LENGTH-1:0] activation_out;

wire       [WIDTH-1:0] psum_intermediate[0:ROW_LENGTH-2];

PE PE_1 (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .activation_in(activation_in[27*ROW_LENGTH-1:27*(ROW_LENGTH-1)]),
    .weight_in(weight_in[27*ROW_LENGTH-1:27*(ROW_LENGTH-1)]),
    .psum_in(psum_in),
    .activation_out(activation_out[27*ROW_LENGTH-1:27*(ROW_LENGTH-1)]),
    .psum_out(psum_intermediate[0])
);

generate
    genvar i;
    for (i = 1; i < ROW_LENGTH - 1; i = i + 1) begin : PE_intermediate
        PE PE_2 (
            .clk_in(clk_in),
            .rst_in(rst_in),
            .activation_in(activation_in[27*(ROW_LENGTH-i)-1:27*(ROW_LENGTH-1-i)]),
            .weight_in(weight_in[27*(ROW_LENGTH-i)-1:27*(ROW_LENGTH-1-i)]),
            .psum_in(psum_intermediate[i-1]),
            .activation_out(activation_out[27*(ROW_LENGTH-i)-1:27*(ROW_LENGTH-1-i)]),
            .psum_out(psum_intermediate[i])
        );
    end
endgenerate


PE PE_3 (
    .clk_in(clk_in),
    .rst_in(rst_in),
    .activation_in(activation_in[27*1-1:27*0]),
    .weight_in(weight_in[27*1-1:27*0]),
    .psum_in(psum_intermediate[ROW_LENGTH-2]),
    .activation_out(activation_out[27*1-1:27*0]),
    .psum_out(psum_out)
);

endmodule