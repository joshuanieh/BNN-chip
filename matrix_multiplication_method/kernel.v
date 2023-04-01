module kernel (
    clk_in,
    reset_in,
    activation_in,
    weight_in,
    skip_in,
    psum_out
);
input              clk_in, reset_in;
input        [8:0] activation_in;
input        [8:0] weight_in;
// input        [31:0] psum_in; //do not add psum in this kernel because it would make a larger adder
input        [3:0] skip_in; //How many inputs are ignored because the size isn't divisible by 9
output reg   [4:0] psum_out; // Max=9, Min=-9

reg                partial_product  [0:8];
reg          [3:0] population_count;
reg          [4:0] sum;

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
    sum = 2 * population_count - 5'd9 - skip_in;
end

always @(posedge clk_in or negedge reset_in) begin
    if (reset_in == 1'b0) begin
        psum_out <= 5'b0;
    end
    else begin
        psum_out <= sum;
    end
end
endmodule