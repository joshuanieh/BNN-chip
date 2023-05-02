/*
Module: PE(processing element)
Author: Chia-Jen Nieh
Description: 
    clk_in:          clock
    rst_in:          active low reset
    activation_in:   sliding window in input layers
    weight_in:       weight of kernels
    psum_in:         partial sum from previous calculation
    psum_out:        output the sum of psum_in and the sum in this kernel
    activation_out:  pass to the kernel below
*/

`include "PE.v"
module PE_row (
    clk_in,
    // rst_in,
    activation_in,
    weight_in,
    psum_in,
    activation_out,
    psum_out
);

parameter WIDTH = 14;
parameter IN_ROW_LENGTH = 2;

input                            clk_in;
input      [9*IN_ROW_LENGTH-1:0] activation_in;
input      [9*IN_ROW_LENGTH-1:0] weight_in;
input      [WIDTH-1:0]           psum_in;
output     [WIDTH-1:0]           psum_out;
output reg [9*IN_ROW_LENGTH-1:0] activation_out;

wire       [WIDTH-1:0]           psum_intermediate;

PE PE_first (
    .clk_in(clk_in),
    // .rst_in(rst_in),
    .activation_in(activation_in[(9*IN_ROW_LENGTH-1)-:9]),
    .weight_in(weight_in[(9*IN_ROW_LENGTH-1)-:9]),
    .psum_in(psum_in),
    .activation_out(activation_out[(9*IN_ROW_LENGTH-1)-:9]),
    .psum_out(psum_intermediate)
);

PE PE_second (
    .clk_in(clk_in),
    // .rst_in(rst_in),
    .activation_in(activation_in[(9-1)-:9]),
    .weight_in(weight_in[(9-1)-:9]),
    .psum_in(psum_intermediate),
    .activation_out(activation_out[(9-1)-:9]),
    .psum_out(psum_out)
);

// PE PE_first (
//     .clk_in(clk_in),
//     // .rst_in(rst_in),
//     .activation_in(activation_in[(9*IN_ROW_LENGTH-1)-:9]),
//     .weight_in(weight_in[(9*IN_ROW_LENGTH-1)-:9]),
//     .psum_in(psum_in),
//     .activation_out(activation_out[(9*IN_ROW_LENGTH-1)-:9]),
//     .psum_out(psum_intermediate[0])
// );

// generate
//     genvar z;
//     for (z = 1; z < IN_ROW_LENGTH - 1; z = z + 1) begin 
//         PE PE_intermediate (
//             .clk_in(clk_in),
//             // .rst_in(rst_in),
//             .activation_in(activation_in[(9*(IN_ROW_LENGTH-z)-1)-:9]),
//             .weight_in(weight_in[(9*(IN_ROW_LENGTH-z)-1)-:9]),
//             .psum_in(psum_intermediate[z-1]),
//             .activation_out(activation_out[(9*(IN_ROW_LENGTH-z)-1)-:9]),
//             .psum_out(psum_intermediate[z])
//         );
//     end
// endgenerate

// PE PE_last (
//     .clk_in(clk_in),
//     // .rst_in(rst_in),
//     .activation_in(activation_in[(9-1)-:9]),
//     .weight_in(weight_in[(9-1)-:9]),
//     .psum_in(psum_intermediate[IN_ROW_LENGTH-1]),
//     .activation_out(activation_out[(9-1)-:9]),
//     .psum_out(psum_out)
// );

endmodule