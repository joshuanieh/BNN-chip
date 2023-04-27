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
module PE_18 (
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
input      [27-1:0]    activation_in;
input      [27-1:0]    weight_in;
input      [WIDTH-1:0] psum_in;
output reg [WIDTH-1:0] psum_out;
output reg [27-1:0]    activation_out;

reg                    partial_product [9:27-1];
reg        [5-1:0]     population_count;
reg        [WIDTH-1:0] sum;

integer i;
always @(*) begin
    for (i = 9; i < 27; i = i + 1) begin
        partial_product[i] = activation_in[i] ~^ weight_in[i];
    end
end

always @(*) begin
    population_count = partial_product[9] +
                       partial_product[10] +
                       partial_product[11] +
                       partial_product[12] +
                       partial_product[13] +
                       partial_product[14] +
                       partial_product[15] +
                       partial_product[16] +
                       partial_product[17] +
                       partial_product[18] +
                       partial_product[19] +
                       partial_product[20] +
                       partial_product[21] +
                       partial_product[22] +
                       partial_product[23] +
                       partial_product[24] +
                       partial_product[25] +
                       partial_product[26];    
end

always @(*) begin
    sum = (2 * population_count - 5'd18) + psum_in;
end

always @(posedge clk_in) begin
    if (rst_in == 1'b0) begin
        psum_out <= {WIDTH{1'b0}};
        activation_out <= 27'd0;
    end
    else begin
        psum_out <= sum;
        activation_out <= activation_in;
    end
end

endmodule