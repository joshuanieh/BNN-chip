/*
Module: PE_array
Author: Chia-Jen Nieh
Description: load weight and activation, weight and acctivation of another channel...... right after reset, until readout output
    clk_in:          clock
    rst_in:          active low reset
    activation_in:         the weight or activation going to be written in
    psum_out:        partial sum of an output layer, latter been changed to one sign bit represent whole sum, when count = 2 output first layer
*/

`include "PE_row.v"
module PE_array (
    clk_in,
    rst_in,
    activation_in,
    weight_in,
    psum_in,
    psum_out
);

parameter WIDTH         = 14;
parameter O_CH          = 64;
parameter IN_ROW_LENGTH = 2;

input                            clk_in, rst_in;
input      [9*2-1:0]             activation_in; //18 input pins, use 12 of that when doing convoultion
input      [9*IN_ROW_LENGTH*O_CH-1:0] weight_in;
output reg [O_CH*WIDTH-1:0]      psum_in;
output reg [O_CH*WIDTH-1:0]      psum_out;

wire       [9*IN_ROW_LENGTH-1:0] activation[0:O_CH];

integer i, j;

assign activation[0] = activation_in;

generate
    genvar k;
    for (k = 0; k < O_CH; k = k + 1) begin
        PE_row PE_row (
            .clk_in(clk_in),
            // .rst_in,
            .activation_in(activation[k]),
            .weight_in({weight_in[(9*IN_ROW_LENGTH*(O_CH-k)-1)-:9*IN_ROW_LENGTH]}), //IN_ROW_LENGTH = 2
            .psum_in(psum_in[WIDTH*(O_CH-k)-1-:WIDTH]),
            .activation_out(acctivation[k+1]),
            .psum_out(psum_out[WIDTH*(O_CH-k)-1-:WIDTH])
        );
    end
endgenerate

endmodule