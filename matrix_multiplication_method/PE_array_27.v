/*
Module: PE_array
Author: Chia-Jen Nieh            end
        end
    end
endgenerate

PE_row PE_row_0(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .activation_in(activation_in_r),
    .weight_in(weight_row_in[0]),
    .psum_in(psum_row_r[0]),
    .activation_out(activation_row_w[0]),
    .psum_out(psum_row_tmp[0])
);

generate
    genvar m;
    for (m = 0; m < O_CH - 1; m = m+1) begin : PE_rows
        PE_row PE_row_1(
            .clk_in(clk_in),
            .rst_in(rst_in),
            .activation_in(activation_row_w[m]),
            .weight_in(weight_row_in[m+1]),
            .psum_in(psum_row_r[m+1]),
            .activation_out(activation_row_w[m+1]),
            .psum_out(psum_row_tmp[m+1])
        );
    end
endgenerate



//Handle first input run, lock the psum
always @(*) begin
    first_w = first_r;
    if (load_count_r == LOAD_COUNT_LIMIT) 
        first_w = 1'b0;
end

always @(posedge clk_in) begin
    if(rst_in == 1'b0) begin
        first_r <= 1'b1;
    end
    else begin
        first_r <= first_w;
    end
end

//Handle weight, O_CH*ROW_LENGTH = 63
always @(*) begin
    for (i = 0; i < O_CH * ROW_LENGTH; i = i + 1) begin
        weight_w[i] = weight_r[i];
    end
    case (load_count_r)
        7'd0: begin
            weight_w[0] = data_in;
        end
        7'd1: begin
            weight_w[1] = data_in;
        end
        7'd2: begin
            weight_w[2] = data_in;
        end
        7'd3: begin
            weight_w[3] = data_in;
        end
        7'd4: begin
            weight_w[4] = data_in;
        end
        7'd5: begin
            weight_w[5] = data_in;
        end
        7'd6: begin
            weight_w[6] = data_in;
        end
        7'd7: begin
            weight_w[7] = data_in;
        end
        7'd8: begin
            weight_w[8] = data_in;
        end
        7'd9: begin
            weight_w[9] = data_in;
        end
Description: 3*3 weight stationary systolic array supporting kernel_27, After reset, the weight and data are fed in interleavedly, never stop until reset again
    clk_in:          clock
    rst_in:          active low reset
    data_in:         the weight or activation going to be written in
    psum_out:        partial sum of an output layer, latter been changed to one sign bit represent whole sum, when count = 2 output first layer
*/
`include "PE_row_27.v"
module PE_array (
    clk_in,
    rst_in,
    data_in,
    psum_out
);

parameter WIDTH = 14;
parameter ROW_LENGTH = 11;
parameter O_CH = 8;
parameter LOAD_COUNT_LIMIT = O_CH * ROW_LENGTH + ROW_LENGTH - 1;

input                  clk_in, rst_in;
input      [27-1:0]    data_in;
output reg [WIDTH-1:0] psum_out;//sign bit, can be reduce to psum_row_out in time sequence

wire [27*ROW_LENGTH-1:0] activation_row_w[0:O_CH-1];//activation_row_end of no use
reg  [WIDTH-1:0]         psum_row_r[0:O_CH-1];//For saving temporary row sum, 2**13-1=8191, larger than 9*512=4608
reg  [WIDTH-1:0]         psum_row_w[0:O_CH-1];//For saving temporary row sum, 2**13-1=8191, larger than 9*512=4608
wire [WIDTH-1:0]         psum_row_tmp[0:O_CH-1];
reg  [7-1:0]             load_count_r;
reg  [7-1:0]             load_count_w;
reg  [27*ROW_LENGTH-1:0] activation_in_r;
reg  [27*ROW_LENGTH-1:0] activation_in_w;
reg  [27-1:0]            weight_r[0:O_CH*ROW_LENGTH-1];
reg  [27-1:0]            weight_w[0:O_CH*ROW_LENGTH-1];
reg  [27*ROW_LENGTH-1:0] weight_row_in[0:O_CH-1];
reg                      psum_row_lock_r[0:O_CH-1];
reg                      psum_row_lock_w[0:O_CH-1];//Lock the value of psum_row_0_r, psum_row_1_r, psum_row_2_r
reg                      first_r, first_w;

integer i;

always @(*) begin
    psum_out = 14'd0;
    case (load_count_r)
        7'd2: begin
            psum_out = psum_row_r[0];
        end
        7'd3: begin
            psum_out = psum_row_r[1];
        end
        7'd4: begin
            psum_out = psum_row_r[2];
        end
        7'd5: begin
            psum_out = psum_row_r[3];
        end
        7'd6: begin
            psum_out = psum_row_r[4];
        end
        7'd7: begin
            psum_out = psum_row_r[5];
        end
        7'd8: begin
            psum_out = psum_row_r[6];
        end
        7'd9: begin
            psum_out = psum_row_r[7];
        end
    endcase
end


generate
    genvar j,k;
    for (j = 0; j < O_CH; j = j + 1) begin : a
        for (k = 0; k < ROW_LENGTH; k = k + 1) begin : b
            always @(*) begin
                weight_row_in[j][27*(ROW_LENGTH-k)-1:27*(ROW_LENGTH-k-1)] = weight_r[ROW_LENGTH*j+k];
            end
        end
    end
endgenerate

PE_row PE_row_0(
    .clk_in(clk_in),
    .rst_in(rst_in),
    .activation_in(activation_in_r),
    .weight_in(weight_row_in[0]),
    .psum_in(psum_row_r[0]),
    .activation_out(activation_row_w[0]),
    .psum_out(psum_row_tmp[0])
);

generate
    genvar m;
    for (m = 0; m < O_CH - 1; m = m+1) begin : PE_rows
        PE_row PE_row_1(
            .clk_in(clk_in),
            .rst_in(rst_in),
            .activation_in(activation_row_w[m]),
            .weight_in(weight_row_in[m+1]),
            .psum_in(psum_row_r[m+1]),
            .activation_out(activation_row_w[m+1]),
            .psum_out(psum_row_tmp[m+1])
        );
    end
endgenerate



//Handle first input run, lock the psum
always @(*) begin
    first_w = first_r;
    if (load_count_r == LOAD_COUNT_LIMIT) 
        first_w = 1'b0;
end

always @(posedge clk_in) begin
    if(rst_in == 1'b0) begin
        first_r <= 1'b1;
    end
    else begin
        first_r <= first_w;
    end
end

//Handle weight, O_CH*ROW_LENGTH = 63
always @(*) begin
    for (i = 0; i < O_CH * ROW_LENGTH; i = i + 1) begin
        weight_w[i] = weight_r[i];
    end
    case (load_count_r)
        7'd0: begin
            weight_w[0] = data_in;
        end
        7'd1: begin
            weight_w[1] = data_in;
        end
        7'd2: begin
            weight_w[2] = data_in;
        end
        7'd3: begin
            weight_w[3] = data_in;
        end
        7'd4: begin
            weight_w[4] = data_in;
        end
        7'd5: begin
            weight_w[5] = data_in;
        end
        7'd6: begin
            weight_w[6] = data_in;
        end
        7'd7: begin
            weight_w[7] = data_in;
        end
        7'd8: begin
            weight_w[8] = data_in;
        end
        7'd9: begin
            weight_w[9] = data_in;
        end
        7'd10: begin
            weight_w[10] = data_in;
        end
        7'd11: begin
            weight_w[11] = data_in;
        end
        7'd12: begin
            weight_w[12] = data_in;
        end
        7'd13: begin
            weight_w[13] = data_in;
        end
        7'd14: begin
            weight_w[14] = data_in;
        end
        7'd15: begin
            weight_w[15] = data_in;
        end
        7'd16: begin
            weight_w[16] = data_in;
        end
        7'd17: begin
            weight_w[17] = data_in;
        end
        7'd18: begin
            weight_w[18] = data_in;
        end
        7'd19: begin
            weight_w[19] = data_in;
        end
        7'd20: begin
            weight_w[20] = data_in;
        end
        7'd21: begin
            weight_w[21] = data_in;
        end
        7'd22: begin
            weight_w[22] = data_in;
        end
        7'd23: begin
            weight_w[23] = data_in;
        end
        7'd24: begin
            weight_w[24] = data_in;
        end
        7'd25: begin
            weight_w[25] = data_in;
        end
        7'd26: begin
            weight_w[26] = data_in;
        end
        7'd27: begin
            weight_w[27] = data_in;
        end
        7'd28: begin
            weight_w[28] = data_in;
        end
        7'd29: begin
            weight_w[29] = data_in;
        end
        7'd30: begin
            weight_w[30] = data_in;
        end
        7'd31: begin
            weight_w[31] = data_in;
        end
        7'd32: begin
            weight_w[32] = data_in;
        end
        7'd33: begin
            weight_w[33] = data_in;
        end
        7'd34: begin
            weight_w[34] = data_in;
        end
        7'd35: begin
            weight_w[35] = data_in;
        end
        7'd36: begin
            weight_w[36] = data_in;
        end
        7'd37: begin
            weight_w[37] = data_in;
        end
        7'd38: begin
            weight_w[38] = data_in;
        end
        7'd39: begin
            weight_w[39] = data_in;
        end
        7'd40: begin
            weight_w[40] = data_in;
        end
        7'd41: begin
            weight_w[41] = data_in;
        end
        7'd42: begin
            weight_w[42] = data_in;
        end
        7'd43: begin
            weight_w[43] = data_in;
        end
        7'd44: begin
            weight_w[44] = data_in;
        end
        7'd45: begin
            weight_w[45] = data_in;
        end
        7'd46: begin
            weight_w[46] = data_in;
        end
        7'd47: begin
            weight_w[47] = data_in;
        end
        7'd48: begin
            weight_w[48] = data_in;
        end
        7'd49: begin
            weight_w[49] = data_in;
        end
        7'd50: begin
            weight_w[50] = data_in;
        end
        7'd51: begin
            weight_w[51] = data_in;
        end
        7'd52: begin
            weight_w[52] = data_in;
        end
        7'd53: begin
            weight_w[53] = data_in;
        end
        7'd54: begin
            weight_w[54] = data_in;
        end
        7'd55: begin
            weight_w[55] = data_in;
        end
        7'd56: begin
            weight_w[56] = data_in;
        end
        7'd57: begin
            weight_w[57] = data_in;
        end
        7'd58: begin
            weight_w[58] = data_in;
        end
        7'd59: begin
            weight_w[59] = data_in;
        end
        7'd60: begin
            weight_w[60] = data_in;
        end
        7'd61: begin
            weight_w[61] = data_in;
        end
        7'd62: begin
            weight_w[62] = data_in;
        end
        7'd63: begin
            weight_w[63] = data_in;
        end
        7'd64: begin
            weight_w[64] = data_in;
        end
        7'd65: begin
            weight_w[65] = data_in;
        end
        7'd66: begin
            weight_w[66] = data_in;
        end
        7'd67: begin
            weight_w[67] = data_in;
        end
        7'd68: begin
            weight_w[68] = data_in;
        end
        7'd69: begin
            weight_w[69] = data_in;
        end
        7'd70: begin
            weight_w[70] = data_in;
        end
        7'd71: begin
            weight_w[71] = data_in;
        end
        7'd72: begin
            weight_w[72] = data_in;
        end
        7'd73: begin
            weight_w[73] = data_in;
        end
        7'd74: begin
            weight_w[74] = data_in;
        end
        7'd75: begin
            weight_w[75] = data_in;
        end
        7'd76: begin
            weight_w[76] = data_in;
        end
        7'd77: begin
            weight_w[77] = data_in;
        end
        7'd78: begin
            weight_w[78] = data_in;
        end
        7'd79: begin
            weight_w[79] = data_in;
        end
        7'd80: begin
            weight_w[80] = data_in;
        end
        7'd81: begin
            weight_w[81] = data_in;
        end
        7'd82: begin
            weight_w[82] = data_in;
        end
        7'd83: begin
            weight_w[83] = data_in;
        end
        7'd84: begin
            weight_w[84] = data_in;
        end
        7'd85: begin
            weight_w[85] = data_in;
        end
        7'd86: begin
            weight_w[86] = data_in;
        end
        7'd87: begin
            weight_w[87] = data_in;
        end
    endcase
end

always @(posedge clk_in) begin
    if(rst_in == 1'b0) begin
        for (i = 0; i < O_CH * ROW_LENGTH; i = i + 1) begin
            weight_r[i] <= 27'd0;
        end
    end
    else begin
        for (i = 0; i < O_CH * ROW_LENGTH; i = i + 1) begin
            weight_r[i] <= weight_w[i];
        end
    end
end

//Handle activation
always @(*) begin
    activation_in_w = activation_in_r;
    case (load_count_r)
        7'd88: begin
            activation_in_w[27*(ROW_LENGTH)-1:27*(ROW_LENGTH-1)] = data_in;
        end
        7'd89: begin
            activation_in_w[27*(ROW_LENGTH-1)-1:27*(ROW_LENGTH-2)] = data_in;
        end
        7'd90: begin
            activation_in_w[27*(ROW_LENGTH-2)-1:27*(ROW_LENGTH-3)] = data_in;
        end
        7'd91: begin
            activation_in_w[27*(ROW_LENGTH-3)-1:27*(ROW_LENGTH-4)] = data_in;
        end
        7'd92: begin
            activation_in_w[27*(ROW_LENGTH-4)-1:27*(ROW_LENGTH-5)] = data_in;
        end
        7'd93: begin
            activation_in_w[27*(ROW_LENGTH-5)-1:27*(ROW_LENGTH-6)] = data_in;
        end
        7'd94: begin
            activation_in_w[27*(ROW_LENGTH-6)-1:27*(ROW_LENGTH-7)] = data_in;
        end
        7'd95: begin
            activation_in_w[27*(ROW_LENGTH-7)-1:27*(ROW_LENGTH-8)] = data_in;
        end
        7'd96: begin
            activation_in_w[27*(ROW_LENGTH-8)-1:27*(ROW_LENGTH-9)] = data_in;
        end
        7'd97: begin
            activation_in_w[27*(ROW_LENGTH-9)-1:27*(ROW_LENGTH-10)] = data_in;
        end
        7'd98: begin
            activation_in_w[27*(ROW_LENGTH-10)-1:27*(ROW_LENGTH-11)] = data_in;
        end
    endcase
end

always @(posedge clk_in) begin
    if(rst_in == 1'b0) begin
        activation_in_r <= {27*ROW_LENGTH{1'b0}};
    end
    else begin
        activation_in_r <= activation_in_w;
    end
end

//Handle load_count
always @(*) begin
    load_count_w = load_count_r + 1;
    if (load_count_r == LOAD_COUNT_LIMIT) begin
        load_count_w = 7'd0;
    end
end

always @(posedge clk_in) begin
    if(rst_in == 1'b0) begin
        load_count_r <= 7'd0;
    end
    else begin
        load_count_r <= load_count_w;
    end
end

//Handle psum_row[*]
always @(*) begin
    psum_row_w[0] = psum_row_r[0];
    psum_row_w[1] = psum_row_r[1];
    psum_row_w[2] = psum_row_r[2];
    psum_row_w[3] = psum_row_r[3];
    psum_row_w[4] = psum_row_r[4];
    psum_row_w[5] = psum_row_r[5];
    psum_row_w[6] = psum_row_r[6];
    psum_row_w[7] = psum_row_r[7];
    if (psum_row_lock_r[0] == 1'b0)
        psum_row_w[0] = psum_row_tmp[0];

    if (psum_row_lock_r[1] == 1'b0)
        psum_row_w[1] = psum_row_tmp[1];

    if (psum_row_lock_r[2] == 1'b0)
        psum_row_w[2] = psum_row_tmp[2];

    if (psum_row_lock_r[3] == 1'b0)
        psum_row_w[3] = psum_row_tmp[3];

    if (psum_row_lock_r[4] == 1'b0)
        psum_row_w[4] = psum_row_tmp[4];

    if (psum_row_lock_r[5] == 1'b0)
        psum_row_w[5] = psum_row_tmp[5];

    if (psum_row_lock_r[6] == 1'b0)
        psum_row_w[6] = psum_row_tmp[6];

    if (psum_row_lock_r[7] == 1'b0)
        psum_row_w[7] = psum_row_tmp[7];
end

always @(posedge clk_in) begin
    if(rst_in == 1'b0) begin
        for (i = 0; i < O_CH; i = i + 1) begin
            psum_row_r[i] <= {WIDTH{1'b0}};
        end
    end
    else begin
        for (i = 0; i < O_CH; i = i + 1) begin
            psum_row_r[i] <= psum_row_w[i];
        end
    end
end

//Handle psum row lock
always @(*) begin
    // for (i = 0; i < O_CH; i = i + 1) begin //->doesn't halt QQ
    //     psum_row_lock_w[i] = 1'b1;
    // end
    psum_row_lock_w[0] = 1'b1;
    psum_row_lock_w[1] = 1'b1;
    psum_row_lock_w[2] = 1'b1;
    psum_row_lock_w[3] = 1'b1;
    psum_row_lock_w[4] = 1'b1;
    psum_row_lock_w[5] = 1'b1;
    psum_row_lock_w[6] = 1'b1;
    psum_row_lock_w[7] = 1'b1;
    case (load_count_r)
        7'd0: begin
            if (first_r != 1'b1)
                psum_row_lock_w[0] = 1'b0;
        end
        7'd1: begin
            if (first_r != 1'b1)
                psum_row_lock_w[1] = 1'b0;
        end
        7'd2: begin
            if (first_r != 1'b1)
                psum_row_lock_w[2] = 1'b0;
        end
        7'd3: begin
            if (first_r != 1'b1)
                psum_row_lock_w[3] = 1'b0;
        end
        7'd4: begin
            if (first_r != 1'b1)
                psum_row_lock_w[4] = 1'b0;
        end
        7'd5: begin
            if (first_r != 1'b1)
                psum_row_lock_w[5] = 1'b0;
        end
        7'd6: begin
            if (first_r != 1'b1)
                psum_row_lock_w[6] = 1'b0;
        end
        7'd7: begin
            if (first_r != 1'b1)
                psum_row_lock_w[7] = 1'b0;
        end
    endcase
end

always @(posedge clk_in) begin
    if(rst_in == 1'b0) begin
        for (i = 0; i < O_CH; i = i + 1) begin
            psum_row_lock_r[i] <= 1'b1;
        end
    end
    else begin
        for (i = 0; i < O_CH; i = i + 1) begin
            psum_row_lock_r[i] <= psum_row_lock_w[i];
        end
    end
end
endmodule