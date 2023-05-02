/*
Module: PE_array
Author: Chia-Jen Nieh
Description: load weight and activation, weight and acctivation of another channel...... right after reset, until readout output
    clk_in:          clock
    rst_in:          active low reset
    data_in:         the weight or activation going to be written in
    psum_out:        partial sum of an output layer, latter been changed to one sign bit represent whole sum, when count = 2 output first layer
*/

`include "PE_column.v"
module top (
    clk_in,
    rst_in,
    data_in,
    load_weight_in,
    pop_in,
    conv_in, //To determine the input data
    psum_out
);

parameter WIDTH = 14;
parameter IN_ROW_LENGTH = 2;
parameter OUT_ROW_LENGTH = 10;
parameter O_CH = 64;

input                            clk_in, rst_in;
input      [9*2-1:0]             data_in; //18 input pins, use 12 of that when doing convoultion
input                            load_weight_in, pop_in;
output reg [OUT_ROW_LENGTH-1:0]  psum_out; //sign bit, first in last out(first in weight last output out)

reg        [WIDTH-1:0]           psum_r[0:O_CH-1][0:OUT_ROW_LENGTH-1];
reg        [9-1:0]               weight_r[0:O_CH-1][0:IN_ROW_LENGTH];
wire       [WIDTH-1:0]           psum_from_PE[0:O_CH-1];
wire       [9*IN_ROW_LENGTH-1:0] activation_intermediate[0:O_CH-1];

integer i, j;

generate
    genvar k;
    for (k = 0; k < O_CH; k = k + 1) begin
        PE_row PE_row (
            .clk_in(clk_in),
            // .rst_in,
            .activation_in(),
            .weight_in,
            .psum_in,
            .activation_out,
            .psum_out(psum_from_PE[k])
        );
    end
endgenerate

always @(*) begin
    for (i = 0; i < OUT_ROW_LENGTH; i = i + 1) begin
        psum_out[i] = psum_r[0][i];
    end
end

always @(posedge clk_in) begin
    if (rst_in == 1'b0) begin
        for (i = 0; i < O_CH; i = i + 1) begin
            for (j = 0; j < OUT_ROW_LENGTH; j = j + 1) begin
                psum_r[i][j] <= {WIDTH{1'b0}};
            end
        end
    end
    else if (load_weight_in == 1'b1) begin
        for (i = 0; i < O_CH; i = i + 1) begin
            for (j = 0; j < OUT_ROW_LENGTH; j = j + 1) begin
                psum_r[i][j] <= psum_r[i][j];
            end
        end
    end
    else if (pop_in == 1'b1) begin
        for (j = 0; j < OUT_ROW_LENGTH; j = j + 1) begin
            psum_r[O_CH-1][j] <= {WIDTH{1'b0}};
            for (i = 0; i < O_CH-1; i = i + 1) begin
                psum_r[i][j] <= psum_r[i+1][j];
            end
        end
    end
    else begin
        for (i = 0; i < O_CH; i = i + 1) begin
            psum_r[i][OUT_ROW_LENGTH-1] <= psum_from_PE[i];
            for (j = 0; j < OUT_ROW_LENGTH-1; j = j + 1) begin
                psum_r[i][j] <= psum_r[i][j+1];
            end
        end
    end
end


always @(posedge clk_in) begin
    if (load_weight_in == 1'b1) begin
        weight_r[0] <= data_in;
        for (i = 0; i < O_CH-1; i = i + 1) begin
            weight_r[i+1] <= weight_r[i];
        end
    end
    else begin
        for (i = 0; i < O_CH; i = i + 1) begin
            weight_r[i] <= weight_r[i];
        end
    end
end

endmodule