/*
Module: systolic_array
Author: Chia-Jen Nieh
Description: 
    clk_in:          clock
    rst_in:          active low reset
    activation_column_*_in: different input layers in the same sliding window, should be fed in staggered fashion time = 1 2 3 4
    load_weight_in:  active high control signal when loading weight, maintain the cycles you need, example: maintain 8 cycle to load weight to first 8 weight, while I suggest maintain 16 cycle
    weight_in:       the weight going to be written in
    psum_row_*_in:   partial sum from previous systolic array, should be fed at time = 5
    psum_*_out:      partial sum of an output layer
*/
`include "kernel.v"
module systolic_array (
    clk_in, rst_in, load_weight_in,
    activation_column_0_in, activation_column_1_in, activation_column_2_in, activation_column_3_in,
    psum_row_0_in, psum_row_1_in, psum_row_2_in, psum_row_3_in,
    weight_in,
    // weight_0_in, weight_1_in, weight_2_in, weight_3_in,
    // weight_4_in, weight_5_in, weight_6_in, weight_7_in,
    // weight_8_in, weight_9_in, weight_10_in, weight_11_in,
    // weight_12_in, weight_13_in, weight_14_in, weight_15_in,
    psum_row_0_out, psum_row_1_out, psum_row_2_out, psum_row_3_out,
    activation_column_0_out, activation_column_1_out, activation_column_2_out, activation_column_3_out
);

input         clk_in, rst_in, load_weight_in;
input  [8:0]  activation_column_0_in, activation_column_1_in, activation_column_2_in, activation_column_3_in, weight_in;
            //  weight_0_in, weight_1_in, weight_2_in, weight_3_in,
            //  weight_4_in, weight_5_in, weight_6_in, weight_7_in,
            //  weight_8_in, weight_9_in, weight_10_in, weight_11_in,
            //  weight_12_in, weight_13_in, weight_14_in, weight_15_in;
input  [12:0] psum_row_0_in, psum_row_1_in, psum_row_2_in, psum_row_3_in; //2**13-1=8191, larger than 9*512=4608
output [12:0] psum_row_0_out, psum_row_1_out, psum_row_2_out, psum_row_3_out;
output [8:0]  activation_column_0_out, activation_column_1_out, activation_column_2_out, activation_column_3_out;

wire   [6:0]  psum_0_out_w, psum_1_out_w, psum_2_out_w, psum_3_out_w,
              psum_4_out_w, psum_5_out_w, psum_6_out_w, psum_7_out_w,
              psum_8_out_w, psum_9_out_w, psum_10_out_w, psum_11_out_w,
              psum_12_out_w, psum_13_out_w, psum_14_out_w, psum_15_out_w;
wire   [8:0]  activation_0_out_w, activation_1_out_w, activation_2_out_w, activation_3_out_w,
              activation_4_out_w, activation_5_out_w, activation_6_out_w, activation_7_out_w,
              activation_8_out_w, activation_9_out_w, activation_10_out_w, activation_11_out_w,
              activation_12_out_w, activation_13_out_w, activation_14_out_w, activation_15_out_w;

reg    [12:0] psum_row_0_in_r, psum_row_1_in_r, psum_row_2_in_r, psum_row_3_in_r; //2**13-1=8191, larger than 9*512=4608
reg    [3:0]  load_weight_count_r;
reg    [8:0]  activation_column_0_r, activation_column_1_r, activation_column_2_r, activation_column_3_r;
// Don't stagger here because it won't support scale up
// reg    [8:0]  activation_column_0_r,
//               activation_column_1_r, activation_11_r,
//               activation_column_2_r, activation_22_r, activation_222_r,
//               activation_column_3_r, activation_33_r, activation_333_r, activation_3333_r; //For staggered inputs
reg    [8:0]  weight_0_r, weight_1_r, weight_2_r, weight_3_r,
              weight_4_r, weight_5_r, weight_6_r, weight_7_r,
              weight_8_r, weight_9_r, weight_10_r, weight_11_r,
              weight_12_r, weight_13_r, weight_14_r, weight_15_r;

assign psum_row_0_out = {{6{psum_3_out_w[6]}}, psum_3_out_w} + psum_row_0_in_r;
assign psum_row_1_out = {{6{psum_7_out_w[6]}}, psum_7_out_w} + psum_row_1_in_r;
assign psum_row_2_out = {{6{psum_11_out_w[6]}}, psum_11_out_w} + psum_row_2_in_r;
assign psum_row_3_out = {{6{psum_15_out_w[6]}}, psum_15_out_w} + psum_row_3_in_r;
assign activation_column_0_out = activation_12_out_w;
assign activation_column_1_out = activation_13_out_w;
assign activation_column_2_out = activation_14_out_w;
assign activation_column_3_out = activation_15_out_w;

kernel kernel_0(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .activation_in(activation_column_0_r),
    .weight_in(weight_0_r),
    .psum_in(7'd0),
    .activation_out(activation_0_out_w),
    .psum_out(psum_0_out_w)
);

kernel kernel_1(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .activation_in(activation_column_1_r),
    .weight_in(weight_1_r),
    .psum_in(psum_0_out_w),
    .activation_out(activation_1_out_w),
    .psum_out(psum_1_out_w)
);

kernel kernel_2(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .activation_in(activation_column_2_r),
    .weight_in(weight_2_r),
    .psum_in(psum_1_out_w),
    .activation_out(activation_2_out_w),
    .psum_out(psum_2_out_w)
);

kernel kernel_3(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .activation_in(activation_column_3_r),
    .weight_in(weight_3_r),
    .psum_in(psum_2_out_w),
    .activation_out(activation_3_out_w),
    .psum_out(psum_3_out_w)
);

kernel kernel_4(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .activation_in(activation_0_out_w),
    .weight_in(weight_4_r),
    .psum_in(7'd0),
    .activation_out(activation_4_out_w),
    .psum_out(psum_4_out_w)
);

kernel kernel_5(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .activation_in(activation_1_out_w),
    .weight_in(weight_5_r),
    .psum_in(psum_4_out_w),
    .activation_out(activation_5_out_w),
    .psum_out(psum_5_out_w)
);

kernel kernel_6(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .activation_in(activation_2_out_w),
    .weight_in(weight_6_r),
    .psum_in(psum_5_out_w),
    .activation_out(activation_6_out_w),
    .psum_out(psum_6_out_w)
);

kernel kernel_7(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .activation_in(activation_3_out_w),
    .weight_in(weight_7_r),
    .psum_in(psum_6_out_w),
    .activation_out(activation_7_out_w),
    .psum_out(psum_7_out_w)
);

kernel kernel_8(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .activation_in(activation_4_out_w),
    .weight_in(weight_8_r),
    .psum_in(7'd0),
    .activation_out(activation_8_out_w),
    .psum_out(psum_8_out_w)
);

kernel kernel_9(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .activation_in(activation_5_out_w),
    .weight_in(weight_9_r),
    .psum_in(psum_8_out_w),
    .activation_out(activation_9_out_w),
    .psum_out(psum_9_out_w)
);

kernel kernel_10(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .activation_in(activation_6_out_w),
    .weight_in(weight_10_r),
    .psum_in(psum_9_out_w),
    .activation_out(activation_10_out_w),
    .psum_out(psum_10_out_w)
);

kernel kernel_11(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .activation_in(activation_7_out_w),
    .weight_in(weight_11_r),
    .psum_in(psum_10_out_w),
    .activation_out(activation_11_out_w),
    .psum_out(psum_11_out_w)
);

kernel kernel_12(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .activation_in(activation_8_out_w),
    .weight_in(weight_12_r),
    .psum_in(7'd0),
    .activation_out(activation_12_out_w),
    .psum_out(psum_12_out_w)
);

kernel kernel_13(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .activation_in(activation_9_out_w),
    .weight_in(weight_13_r),
    .psum_in(psum_12_out_w),
    .activation_out(activation_13_out_w),
    .psum_out(psum_13_out_w)
);

kernel kernel_14(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .activation_in(activation_10_out_w),
    .weight_in(weight_14_r),
    .psum_in(psum_13_out_w),
    .activation_out(activation_14_out_w),
    .psum_out(psum_14_out_w)
);

kernel kernel_15(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .activation_in(activation_11_out_w),
    .weight_in(weight_15_r),
    .psum_in(psum_14_out_w),
    .activation_out(activation_15_out_w),
    .psum_out(psum_15_out_w)
);

always @(posedge clk_in or negedge rst_in) begin
    if(rst_in == 1'b0) begin
        activation_column_0_r <= 9'd0;
        activation_column_1_r <= 9'd0;
        activation_column_2_r <= 9'd0;
        activation_column_3_r <= 9'd0;

        // activation_11_r <= 9'd0;
        // activation_22_r <= 9'd0;
        // activation_33_r <= 9'd0;

        // activation_222_r <= 9'd0;
        // activation_333_r <= 9'd0;

        // activation_3333_r <= 9'd0;

        weight_0_r <= 9'd0;
        weight_1_r <= 9'd0;
        weight_2_r <= 9'd0;
        weight_3_r <= 9'd0;
        weight_4_r <= 9'd0;
        weight_5_r <= 9'd0;
        weight_6_r <= 9'd0;
        weight_7_r <= 9'd0;
        weight_8_r <= 9'd0;
        weight_9_r <= 9'd0;
        weight_10_r <= 9'd0;
        weight_11_r <= 9'd0;
        weight_12_r <= 9'd0;
        weight_13_r <= 9'd0;
        weight_14_r <= 9'd0;
        weight_15_r <= 9'd0;

        load_weight_count_r <= 4'd0;

        psum_row_0_in_r <= 13'd0;
        psum_row_1_in_r <= 13'd0;
        psum_row_2_in_r <= 13'd0;
        psum_row_3_in_r <= 13'd0;
    end
    else begin
        activation_column_0_r <= activation_column_0_in;
        activation_column_1_r <= activation_column_1_in;
        activation_column_2_r <= activation_column_2_in;
        activation_column_3_r <= activation_column_3_in;
        psum_row_0_in_r <= psum_row_0_in;
        psum_row_1_in_r <= psum_row_1_in;
        psum_row_2_in_r <= psum_row_2_in;
        psum_row_3_in_r <= psum_row_3_in;

        // activation_column_0_r <= activation_column_0_in;
        // activation_11_r <= activation_column_1_in;
        // activation_222_r <= activation_column_2_in;
        // activation_3333_r <= activation_column_3_in;
        
        // activation_column_1_r <= activation_11_r;
        // activation_22_r <= activation_222_r;
        // activation_333_r <= activation_3333_r;

        // activation_column_2_r <= activation_22_r;
        // activation_33_r <= activation_333_r;
        
        // activation_column_3_r <= activation_33_r;

        if(load_weight_in == 1'b1) begin
            if(load_weight_count_r != 4'd15)
                load_weight_count_r <= load_weight_count_r + 1;
            else
                load_weight_count_r <= 4'd0;
            case (load_weight_count_r)
                4'd0: begin
                    weight_0_r <= weight_in;
                    weight_1_r <= weight_1_r;
                    weight_2_r <= weight_2_r;
                    weight_3_r <= weight_3_r;
                    weight_4_r <= weight_4_r;
                    weight_5_r <= weight_5_r;
                    weight_6_r <= weight_6_r;
                    weight_7_r <= weight_7_r;
                    weight_8_r <= weight_8_r;
                    weight_9_r <= weight_9_r;
                    weight_10_r <= weight_10_r;
                    weight_11_r <= weight_11_r;
                    weight_12_r <= weight_12_r;
                    weight_13_r <= weight_13_r;
                    weight_14_r <= weight_14_r;
                    weight_15_r <= weight_15_r;
                end
                4'd1: begin
                    weight_0_r <= weight_0_r;
                    weight_1_r <= weight_in;
                    weight_2_r <= weight_2_r;
                    weight_3_r <= weight_3_r;
                    weight_4_r <= weight_4_r;
                    weight_5_r <= weight_5_r;
                    weight_6_r <= weight_6_r;
                    weight_7_r <= weight_7_r;
                    weight_8_r <= weight_8_r;
                    weight_9_r <= weight_9_r;
                    weight_10_r <= weight_10_r;
                    weight_11_r <= weight_11_r;
                    weight_12_r <= weight_12_r;
                    weight_13_r <= weight_13_r;
                    weight_14_r <= weight_14_r;
                    weight_15_r <= weight_15_r;
                end
                4'd2: begin
                    weight_0_r <= weight_0_r;
                    weight_1_r <= weight_1_r;
                    weight_2_r <= weight_in;
                    weight_3_r <= weight_3_r;
                    weight_4_r <= weight_4_r;
                    weight_5_r <= weight_5_r;
                    weight_6_r <= weight_6_r;
                    weight_7_r <= weight_7_r;
                    weight_8_r <= weight_8_r;
                    weight_9_r <= weight_9_r;
                    weight_10_r <= weight_10_r;
                    weight_11_r <= weight_11_r;
                    weight_12_r <= weight_12_r;
                    weight_13_r <= weight_13_r;
                    weight_14_r <= weight_14_r;
                    weight_15_r <= weight_15_r;
                end
                4'd3: begin
                    weight_0_r <= weight_0_r;
                    weight_1_r <= weight_1_r;
                    weight_2_r <= weight_2_r;
                    weight_3_r <= weight_in;
                    weight_4_r <= weight_4_r;
                    weight_5_r <= weight_5_r;
                    weight_6_r <= weight_6_r;
                    weight_7_r <= weight_7_r;
                    weight_8_r <= weight_8_r;
                    weight_9_r <= weight_9_r;
                    weight_10_r <= weight_10_r;
                    weight_11_r <= weight_11_r;
                    weight_12_r <= weight_12_r;
                    weight_13_r <= weight_13_r;
                    weight_14_r <= weight_14_r;
                    weight_15_r <= weight_15_r;
                end
                4'd4: begin
                    weight_0_r <= weight_0_r;
                    weight_1_r <= weight_1_r;
                    weight_2_r <= weight_2_r;
                    weight_3_r <= weight_3_r;
                    weight_4_r <= weight_in;
                    weight_5_r <= weight_5_r;
                    weight_6_r <= weight_6_r;
                    weight_7_r <= weight_7_r;
                    weight_8_r <= weight_8_r;
                    weight_9_r <= weight_9_r;
                    weight_10_r <= weight_10_r;
                    weight_11_r <= weight_11_r;
                    weight_12_r <= weight_12_r;
                    weight_13_r <= weight_13_r;
                    weight_14_r <= weight_14_r;
                    weight_15_r <= weight_15_r;
                end
                4'd5: begin
                    weight_0_r <= weight_0_r;
                    weight_1_r <= weight_1_r;
                    weight_2_r <= weight_2_r;
                    weight_3_r <= weight_3_r;
                    weight_4_r <= weight_4_r;
                    weight_5_r <= weight_in;
                    weight_6_r <= weight_6_r;
                    weight_7_r <= weight_7_r;
                    weight_8_r <= weight_8_r;
                    weight_9_r <= weight_9_r;
                    weight_10_r <= weight_10_r;
                    weight_11_r <= weight_11_r;
                    weight_12_r <= weight_12_r;
                    weight_13_r <= weight_13_r;
                    weight_14_r <= weight_14_r;
                    weight_15_r <= weight_15_r;
                end
                4'd6: begin
                    weight_0_r <= weight_0_r;
                    weight_1_r <= weight_1_r;
                    weight_2_r <= weight_2_r;
                    weight_3_r <= weight_3_r;
                    weight_4_r <= weight_4_r;
                    weight_5_r <= weight_5_r;
                    weight_6_r <= weight_in;
                    weight_7_r <= weight_7_r;
                    weight_8_r <= weight_8_r;
                    weight_9_r <= weight_9_r;
                    weight_10_r <= weight_10_r;
                    weight_11_r <= weight_11_r;
                    weight_12_r <= weight_12_r;
                    weight_13_r <= weight_13_r;
                    weight_14_r <= weight_14_r;
                    weight_15_r <= weight_15_r;
                end
                4'd7: begin
                    weight_0_r <= weight_0_r;
                    weight_1_r <= weight_1_r;
                    weight_2_r <= weight_2_r;
                    weight_3_r <= weight_3_r;
                    weight_4_r <= weight_4_r;
                    weight_5_r <= weight_5_r;
                    weight_6_r <= weight_6_r;
                    weight_7_r <= weight_in;
                    weight_8_r <= weight_8_r;
                    weight_9_r <= weight_9_r;
                    weight_10_r <= weight_10_r;
                    weight_11_r <= weight_11_r;
                    weight_12_r <= weight_12_r;
                    weight_13_r <= weight_13_r;
                    weight_14_r <= weight_14_r;
                    weight_15_r <= weight_15_r;
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
                    weight_8_r <= weight_in;
                    weight_9_r <= weight_9_r;
                    weight_10_r <= weight_10_r;
                    weight_11_r <= weight_11_r;
                    weight_12_r <= weight_12_r;
                    weight_13_r <= weight_13_r;
                    weight_14_r <= weight_14_r;
                    weight_15_r <= weight_15_r;
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
                    weight_9_r <= weight_in;
                    weight_10_r <= weight_10_r;
                    weight_11_r <= weight_11_r;
                    weight_12_r <= weight_12_r;
                    weight_13_r <= weight_13_r;
                    weight_14_r <= weight_14_r;
                    weight_15_r <= weight_15_r;
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
                    weight_9_r <= weight_9_r;
                    weight_10_r <= weight_in;
                    weight_11_r <= weight_11_r;
                    weight_12_r <= weight_12_r;
                    weight_13_r <= weight_13_r;
                    weight_14_r <= weight_14_r;
                    weight_15_r <= weight_15_r;
                end
                4'd11: begin
                    weight_0_r <= weight_0_r;
                    weight_1_r <= weight_1_r;
                    weight_2_r <= weight_2_r;
                    weight_3_r <= weight_3_r;
                    weight_4_r <= weight_4_r;
                    weight_5_r <= weight_5_r;
                    weight_6_r <= weight_6_r;
                    weight_7_r <= weight_7_r;
                    weight_8_r <= weight_8_r;
                    weight_9_r <= weight_9_r;
                    weight_10_r <= weight_10_r;
                    weight_11_r <= weight_in;
                    weight_12_r <= weight_12_r;
                    weight_13_r <= weight_13_r;
                    weight_14_r <= weight_14_r;
                    weight_15_r <= weight_15_r;
                end
                4'd12: begin
                    weight_0_r <= weight_0_r;
                    weight_1_r <= weight_1_r;
                    weight_2_r <= weight_2_r;
                    weight_3_r <= weight_3_r;
                    weight_4_r <= weight_4_r;
                    weight_5_r <= weight_5_r;
                    weight_6_r <= weight_6_r;
                    weight_7_r <= weight_7_r;
                    weight_8_r <= weight_8_r;
                    weight_9_r <= weight_9_r;
                    weight_10_r <= weight_10_r;
                    weight_11_r <= weight_11_r;
                    weight_12_r <= weight_in;
                    weight_13_r <= weight_13_r;
                    weight_14_r <= weight_14_r;
                    weight_15_r <= weight_15_r;
                end
                4'd13: begin
                    weight_0_r <= weight_0_r;
                    weight_1_r <= weight_1_r;
                    weight_2_r <= weight_2_r;
                    weight_3_r <= weight_3_r;
                    weight_4_r <= weight_4_r;
                    weight_5_r <= weight_5_r;
                    weight_6_r <= weight_6_r;
                    weight_7_r <= weight_7_r;
                    weight_8_r <= weight_8_r;
                    weight_9_r <= weight_9_r;
                    weight_10_r <= weight_10_r;
                    weight_11_r <= weight_11_r;
                    weight_12_r <= weight_12_r;
                    weight_13_r <= weight_in;
                    weight_14_r <= weight_14_r;
                    weight_15_r <= weight_15_r;
                end
                4'd14: begin
                    weight_0_r <= weight_0_r;
                    weight_1_r <= weight_1_r;
                    weight_2_r <= weight_2_r;
                    weight_3_r <= weight_3_r;
                    weight_4_r <= weight_4_r;
                    weight_5_r <= weight_5_r;
                    weight_6_r <= weight_6_r;
                    weight_7_r <= weight_7_r;
                    weight_8_r <= weight_8_r;
                    weight_9_r <= weight_9_r;
                    weight_10_r <= weight_10_r;
                    weight_11_r <= weight_11_r;
                    weight_12_r <= weight_12_r;
                    weight_13_r <= weight_13_r;
                    weight_14_r <= weight_in;
                    weight_15_r <= weight_15_r;
                end
                4'd15: begin
                    weight_0_r <= weight_0_r;
                    weight_1_r <= weight_1_r;
                    weight_2_r <= weight_2_r;
                    weight_3_r <= weight_3_r;
                    weight_4_r <= weight_4_r;
                    weight_5_r <= weight_5_r;
                    weight_6_r <= weight_6_r;
                    weight_7_r <= weight_7_r;
                    weight_8_r <= weight_8_r;
                    weight_9_r <= weight_9_r;
                    weight_10_r <= weight_10_r;
                    weight_11_r <= weight_11_r;
                    weight_12_r <= weight_12_r;
                    weight_13_r <= weight_13_r;
                    weight_14_r <= weight_14_r;
                    weight_15_r <= weight_in;
                end
            endcase
        end
        else begin
            weight_0_r <= weight_0_r;
            weight_1_r <= weight_1_r;
            weight_2_r <= weight_2_r;
            weight_3_r <= weight_3_r;
            weight_4_r <= weight_4_r;
            weight_5_r <= weight_5_r;
            weight_6_r <= weight_6_r;
            weight_7_r <= weight_7_r;
            weight_8_r <= weight_8_r;
            weight_9_r <= weight_9_r;
            weight_10_r <= weight_10_r;
            weight_11_r <= weight_11_r;
            weight_12_r <= weight_12_r;
            weight_13_r <= weight_13_r;
            weight_14_r <= weight_14_r;
            weight_15_r <= weight_15_r;
            load_weight_count_r <= 4'd0;
        end
    end
end
endmodule