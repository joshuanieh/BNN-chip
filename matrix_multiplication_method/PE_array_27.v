/*
Module: PE_array
Author: Chia-Jen Nieh
Description: 3*3 weight stationary systolic array supporting kernel_27, After reset, the weight and data are fed in interleavedly, never stop until reset again
    clk_in:          clock
    rst_in:          active low reset
    data_in:         the weight or activation going to be written in
    psum_row_*_out:  partial sum of an output layer, latter been changed to one sign bit represent whole sum
*/
`include "PE_row_27.v"
module PE_array (
    clk_in,
    rst_in,
    // load_in,
    data_in,
    // psum_row_0_in, psum_row_1_in, psum_row_2_in,
    psum_row_0_out, psum_row_1_out, psum_row_2_out
);

parameter WIDTH = 14;

input            clk_in, rst_in;
input  [27-1:0]  data_in;

// input  [WIDTH-1:0] psum_row_0_in, psum_row_1_in, psum_row_2_in; //2**13-1=8191, larger than 9*512=4608
output [WIDTH-1:0] psum_row_0_out, psum_row_1_out, psum_row_2_out;//sign bit, can be reduce to psum_row_out in time sequence

wire   [27*3-1:0]  activation_row_0_out_w, activation_row_1_out_w, activation_row_end;//activation_row_end of no use

reg    [WIDTH-1:0] psum_row_0_r, psum_row_1_r, psum_row_2_r;//For saving temporary row sum, 2**13-1=8191, larger than 9*512=4608
wire    [WIDTH-1:0] psum_row_0_w, psum_row_1_w, psum_row_2_w;
reg    [3:0]  load_count_r;//0~9-1
wire   [3:0] load_count_w;
reg    [27*3-1:0]  activation_in_r;
reg    [27-1:0]  weight_0_r, weight_1_r, weight_2_r, weight_3_r,
              weight_4_r, weight_5_r, weight_6_r, weight_7_r,
              weight_8_r;
reg      psum_row_0_lock_r, psum_row_1_lock_r, psum_row_2_lock_r;//Lock the value of psum_row_0_r, psum_row_1_r, psum_row_2_r
wire [27*3-1:0] activation_row_0_to_1, activation_row_1_to_2;
reg first_r;
wire first_w;

assign load_count_w = (load_count_r == 4'd11) ? 4'd0 : load_count_r + 1;
assign first_w = (load_count_r == 4'd11) ? 1'b0 : first_r;

// assign psum_row_0_out = psum_row_0_r[WIDTH-1];
// assign psum_row_1_out = psum_row_1_r[WIDTH-1];
// assign psum_row_2_out = psum_row_2_r[WIDTH-1];

//For test
assign psum_row_0_out = psum_row_0_r;
assign psum_row_1_out = psum_row_1_r;
assign psum_row_2_out = psum_row_2_r;

PE_row PE_row_0(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .activation_in(activation_in_r),
    .weight_in({weight_0_r, weight_1_r, weight_2_r}),
    .psum_in(psum_row_0_r),
    .activation_out(activation_row_0_to_1),
    .psum_out(psum_row_0_w)
);

PE_row PE_row_1(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .activation_in(activation_row_0_to_1),
    .weight_in({weight_3_r, weight_4_r, weight_5_r}),
    .psum_in(psum_row_1_r),
    .activation_out(activation_row_1_to_2),
    .psum_out(psum_row_1_w)
);

PE_row PE_row_2(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .activation_in(activation_row_1_to_2),
    .weight_in({weight_6_r, weight_7_r, weight_8_r}),
    .psum_in(psum_row_2_r),
    .activation_out(activation_row_end),
    .psum_out(psum_row_2_w)
);


always @(posedge clk_in or negedge rst_in) begin
    if(rst_in == 1'b0) begin
        first_r = 1'b1;
        activation_in_r <= 27'd0;

        weight_0_r <= 27'd0;
        weight_1_r <= 27'd0;
        weight_2_r <= 27'd0;
        weight_3_r <= 27'd0;
        weight_4_r <= 27'd0;
        weight_5_r <= 27'd0;
        weight_6_r <= 27'd0;
        weight_7_r <= 27'd0;
        weight_8_r <= 27'd0;
        load_count_r <= 4'd0;

        psum_row_0_r <= {WIDTH{1'b0}};
        psum_row_1_r <= {WIDTH{1'b0}};
        psum_row_2_r <= {WIDTH{1'b0}};

        psum_row_0_lock_r <= 1'b1;
        psum_row_1_lock_r <= 1'b1;
        psum_row_2_lock_r <= 1'b1;
    end
    else begin
        load_count_r <= load_count_w;
        first_r <= first_w;
        case (load_count_r)
            4'd0: begin
                weight_0_r <= data_in;
                weight_1_r <= weight_1_r;
                weight_2_r <= weight_2_r;
                weight_3_r <= weight_3_r;
                weight_4_r <= weight_4_r;
                weight_5_r <= weight_5_r;
                weight_6_r <= weight_6_r;
                weight_7_r <= weight_7_r;
                weight_8_r <= weight_8_r;
                activation_in_r <= activation_in_r;
                if (first_r != 1'b1)
                    psum_row_0_lock_r <= 1'b0;
                else
                    psum_row_0_lock_r <= 1'b1;
                psum_row_1_lock_r <= 1'b1;
                psum_row_2_lock_r <= 1'b1;
            end
            4'd1: begin
                weight_0_r <= weight_0_r;
                weight_1_r <= data_in;
                weight_2_r <= weight_2_r;
                weight_3_r <= weight_3_r;
                weight_4_r <= weight_4_r;
                weight_5_r <= weight_5_r;
                weight_6_r <= weight_6_r;
                weight_7_r <= weight_7_r;
                weight_8_r <= weight_8_r;
                activation_in_r <= activation_in_r;
                psum_row_0_lock_r <= 1'b1;
                if (first_r != 1'b1)
                    psum_row_1_lock_r <= 1'b0;
                else
                    psum_row_1_lock_r <= 1'b1;
                psum_row_2_lock_r <= 1'b1;
            end
            4'd2: begin
                weight_0_r <= weight_0_r;
                weight_1_r <= weight_1_r;
                weight_2_r <= data_in;
                weight_3_r <= weight_3_r;
                weight_4_r <= weight_4_r;
                weight_5_r <= weight_5_r;
                weight_6_r <= weight_6_r;
                weight_7_r <= weight_7_r;
                weight_8_r <= weight_8_r;
                activation_in_r <= activation_in_r;
                psum_row_0_lock_r <= 1'b1;
                psum_row_1_lock_r <= 1'b1;
                if (first_r != 1'b1)
                    psum_row_2_lock_r <= 1'b0;
                else
                    psum_row_2_lock_r <= 1'b1;
            end
            4'd3: begin
                weight_0_r <= weight_0_r;
                weight_1_r <= weight_1_r;
                weight_2_r <= weight_2_r;
                weight_3_r <= data_in;
                weight_4_r <= weight_4_r;
                weight_5_r <= weight_5_r;
                weight_6_r <= weight_6_r;
                weight_7_r <= weight_7_r;
                weight_8_r <= weight_8_r;
                activation_in_r <= activation_in_r;
                psum_row_0_lock_r <= 1'b1;
                psum_row_1_lock_r <= 1'b1;
                psum_row_2_lock_r <= 1'b1;
            end
            4'd4: begin
                weight_0_r <= weight_0_r;
                weight_1_r <= weight_1_r;
                weight_2_r <= weight_2_r;
                weight_3_r <= weight_3_r;
                weight_4_r <= data_in;
                weight_5_r <= weight_5_r;
                weight_6_r <= weight_6_r;
                weight_7_r <= weight_7_r;
                weight_8_r <= weight_8_r;
                activation_in_r <= activation_in_r;
                psum_row_0_lock_r <= 1'b1;
                psum_row_1_lock_r <= 1'b1;
                psum_row_2_lock_r <= 1'b1;
            end
            4'd5: begin
                weight_0_r <= weight_0_r;
                weight_1_r <= weight_1_r;
                weight_2_r <= weight_2_r;
                weight_3_r <= weight_3_r;
                weight_4_r <= weight_4_r;
                weight_5_r <= data_in;
                weight_6_r <= weight_6_r;
                weight_7_r <= weight_7_r;
                weight_8_r <= weight_8_r;
                activation_in_r <= activation_in_r;
                psum_row_0_lock_r <= 1'b1;
                psum_row_1_lock_r <= 1'b1;
                psum_row_2_lock_r <= 1'b1;
            end
            4'd6: begin
                weight_0_r <= weight_0_r;
                weight_1_r <= weight_1_r;
                weight_2_r <= weight_2_r;
                weight_3_r <= weight_3_r;
                weight_4_r <= weight_4_r;
                weight_5_r <= weight_5_r;
                weight_6_r <= data_in;
                weight_7_r <= weight_7_r;
                weight_8_r <= weight_8_r;
                activation_in_r <= activation_in_r;
                psum_row_0_lock_r <= 1'b1;
                psum_row_1_lock_r <= 1'b1;
                psum_row_2_lock_r <= 1'b1;
            end
            4'd7: begin
                weight_0_r <= weight_0_r;
                weight_1_r <= weight_1_r;
                weight_2_r <= weight_2_r;
                weight_3_r <= weight_3_r;
                weight_4_r <= weight_4_r;
                weight_5_r <= weight_5_r;
                weight_6_r <= weight_6_r;
                weight_7_r <= data_in;
                weight_8_r <= weight_8_r;
                activation_in_r <= activation_in_r;
                psum_row_0_lock_r <= 1'b1;
                psum_row_1_lock_r <= 1'b1;
                psum_row_2_lock_r <= 1'b1;
            end
            4'd8: begin
                weight_0_r <= weight_0_r;
                weight_1_r <= weight_1_r;
                weight_2_r <= weight_2_r;
                weight_3_r <= weight_3_r;
                weight_4_r <= weight_4_r;
                weight_5_r <= weight_5_r;
                weight_6_r <= weight_6_r;
                weight_7_r <= weight_7_r;
                weight_8_r <= data_in;
                activation_in_r <= activation_in_r;
                psum_row_0_lock_r <= 1'b1;
                psum_row_1_lock_r <= 1'b1;
                psum_row_2_lock_r <= 1'b1;
            end
            4'd9: begin
                weight_0_r <= weight_0_r;
                weight_1_r <= weight_1_r;
                weight_2_r <= weight_2_r;
                weight_3_r <= weight_3_r;
                weight_4_r <= weight_4_r;
                weight_5_r <= weight_5_r;
                weight_6_r <= weight_6_r;
                weight_7_r <= weight_7_r;
                weight_8_r <= weight_8_r;
                activation_in_r <= {data_in, activation_in_r[27*2-1:27*0]};
                psum_row_0_lock_r <= 1'b1;
                psum_row_1_lock_r <= 1'b1;
                psum_row_2_lock_r <= 1'b1;
            end
            4'd10: begin
                weight_0_r <= weight_0_r;
                weight_1_r <= weight_1_r;
                weight_2_r <= weight_2_r;
                weight_3_r <= weight_3_r;
                weight_4_r <= weight_4_r;
                weight_5_r <= weight_5_r;
                weight_6_r <= weight_6_r;
                weight_7_r <= weight_7_r;
                weight_8_r <= weight_8_r;
                activation_in_r <= {activation_in_r[27*3-1:27*2], data_in, activation_in_r[27*1-1:27*0]};
                psum_row_0_lock_r <= 1'b1;
                psum_row_1_lock_r <= 1'b1;
                psum_row_2_lock_r <= 1'b1;
            end
            default: begin //load_count_r == 4'd11
                weight_0_r <= weight_0_r;
                weight_1_r <= weight_1_r;
                weight_2_r <= weight_2_r;
                weight_3_r <= weight_3_r;
                weight_4_r <= weight_4_r;
                weight_5_r <= weight_5_r;
                weight_6_r <= weight_6_r;
                weight_7_r <= weight_7_r;
                weight_8_r <= weight_8_r;
                activation_in_r <= {activation_in_r[27*3-1:27*1], data_in};
                psum_row_0_lock_r <= 1'b1;
                psum_row_1_lock_r <= 1'b1;
                psum_row_2_lock_r <= 1'b1;
            end
        endcase
        if (psum_row_0_lock_r == 1'b1)
            psum_row_0_r <= psum_row_0_r;
        else
            psum_row_0_r <= psum_row_0_w;

        if (psum_row_1_lock_r == 1'b1)
            psum_row_1_r <= psum_row_1_r;
        else
            psum_row_1_r <= psum_row_1_w;

        if (psum_row_2_lock_r == 1'b1)
            psum_row_2_r <= psum_row_2_r;
        else
            psum_row_2_r <= psum_row_2_w;
    end
end
endmodule