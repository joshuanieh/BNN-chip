`include "PE.v"
module PE_column (
    clk_in,
    // rst_in,
    activation_in,
    weight_in,
    psum_in,
    psum_out
);

parameter WIDTH = 14;
parameter O_CH  = 64;

input                            clk_in;
input      [9-1:0]               activation_in; //9 input pins
input      [9*O_CH-1:0]          weight_in;
input      [WIDTH*O_CH-1:0]      psum_in;
output     [WIDTH*O_CH-1:0]      psum_out;

wire       [9-1:0] activation[0:O_CH];

integer i, j;

assign activation[0] = activation_in;

generate
    genvar k;
    for (k = 0; k < O_CH; k = k + 1) begin
        PE PE (
            .clk_in(clk_in),
            // .rst_in,
            .activation_in(activation[k]),
            .weight_in(weight_in[9*(O_CH-k)-1-:9]),
            .psum_in(psum_in[WIDTH*(O_CH-k)-1-:WIDTH]),
            .activation_out(activation[k+1]),
            .psum_out(psum_out[WIDTH*(O_CH-k)-1-:WIDTH])
        );
    end
endgenerate

endmodule