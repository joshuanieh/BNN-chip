`include "PE_column.v"
module top (
    clk_in,
    rst_in,         //When needing to compute new rows, reset all the psum_r to zero. My system use active low reset.
    data_in,        //Can serve as weight or activation
    load_weight_in, //If true, count weight index, fill the weight with corresponding index with data_in
    in_valid_in,    //If true, rotate the psum shifter
    pop_in,         //If true, count pop index, pop the psum_r with corresponding index to sum_out
    sum_out
);

parameter WIDTH = 14;
parameter OUT_ROW_LENGTH = 4;
parameter O_CH = 64;

input                            clk_in, rst_in;
input      [9-1:0]               data_in; //9 input pins
input                            load_weight_in; //load at most O_CH weight
input                            in_valid_in;
input                            pop_in;
output reg [OUT_ROW_LENGTH-1:0]  sum_out; //sign bit, first in last out(first in weight last output out, a determinable output channel can be used)

reg        [6-1:0]               weight_count_w; //Because 64 out layers, use 6 bits to count
reg        [6-1:0]               weight_count_r; //Because 64 out layers, use 6 bits to count
reg        [9-1:0]               weight_w[0:O_CH-1];
reg        [9-1:0]               weight_r[0:O_CH-1];
reg                              in_valid_r[0:O_CH-2];
reg        [WIDTH-1:0]           psum_w[0:O_CH-1][0:OUT_ROW_LENGTH-1]; //Because the beginning and the end are not all rotating, seperate them
reg        [WIDTH-1:0]           psum_r[0:O_CH-1][0:OUT_ROW_LENGTH-1];
reg        [9-1:0]               PE_column_activation_input; //turn to constant zero when in_valid_in is not valid, to reduce the activity factor
reg        [9*O_CH-1:0]          PE_column_weight_input; //Concate weight_r[:]
reg        [WIDTH*O_CH-1:0]      PE_column_psum_input; //take from psum_r[:][OUT_ROW_LENGTH-1]
wire       [WIDTH*O_CH-1:0]      PE_column_psum_output; //sotre into psum_r[*][0] if in_valid_r[*] is true

reg        [6-1:0]               pop_count_w; //Because 64 out layers, use 6 bits to count
reg        [6-1:0]               pop_count_r; //Because 64 out layers, use 6 bits to count

integer i, j, m, n, p, q, r, s, t, u, v, w, x, y, z;

/*Begin handling weights*/
//Handle weight_count_r, add by 1 when load_weight_in is true
always @(*) begin
    if (load_weight_in == 1'b1) begin
        weight_count_w = weight_count_r + 1;
    end
    else begin
        weight_count_w = 6'd0;
    end
end

always @(posedge clk_in) begin
    weight_count_r <= weight_count_w;
end

//Handle weight_r, store data_in to weight_r[weight_count_r] when load_weight_in is true
always @(*) begin
    for (i = 0; i < O_CH; i = i + 1) begin
        weight_w[i] = weight_r[i];
    end
    if (load_weight_in == 1'b1) begin
        weight_w[weight_count_r] = data_in;
    end
end

always @(posedge clk_in) begin
    for (j = 0; j < O_CH; j = j + 1) begin
        weight_r[j] <= weight_w[j];
    end
end

/*Begin handling storage elements*/
//Handle in_valid_r, propagate to larger o_ch row to know if input arrive and the shifter starts rotating
always @(posedge clk_in) begin
    in_valid_r[0] <= in_valid_in;
    for (m = 1; m <= O_CH-2; m = m + 1) begin
        in_valid_r[m] <= in_valid_r[m-1];
    end
end

//Handle psum_r, store new values to them and rotate when in_valid_r is true
always @(*) begin
    //Default values
    for (n = 0; n <= O_CH-1; n = n + 1) begin
        for (p = 0; p <= OUT_ROW_LENGTH-1; p = p + 1) begin
            psum_w[n][p] = psum_r[n][p];
        end
    end
    
    //Handle first row
    if (in_valid_in == 1'b1) begin
        psum_w[0][0] = PE_column_psum_output[WIDTH*O_CH-1-:WIDTH];
        for (q = 1; q <= OUT_ROW_LENGTH-1; q = q + 1) begin
            psum_w[0][q] = psum_r[0][q-1];
        end
    end
    
    //Handle remaining rows
    for (r = 1; r <= O_CH-1; r = r + 1) begin
        if (in_valid_r[r-1] == 1'b1) begin
            psum_w[r][0] = PE_column_psum_output[WIDTH*(O_CH-r)-1-:WIDTH];
            for (s = 1; s <= OUT_ROW_LENGTH-1; s = s + 1) begin
                psum_w[r][s] = psum_r[r][s-1];
            end    
        end
    end
end

always @(posedge clk_in) begin
    if (rst_in == 1'b0) begin
        for (t = 0; t <= O_CH-1; t = t + 1) begin
            for (u = 0; u <= OUT_ROW_LENGTH-1; u = u + 1) begin
                psum_r[t][u] <= {WIDTH{1'b0}};
            end
        end
    end
    else begin
        for (v = 0; v <= O_CH-1; v = v + 1) begin
            for (w = 0; w <= OUT_ROW_LENGTH-1; w = w + 1) begin
                psum_r[v][w] <= psum_w[v][w];
            end
        end
    end
end

//Begin handling computational elements
//Handle PE_column_activation_input, if the input is not valid, pass 0 to the PE to reduce activity factor
always @(*) begin
    if (in_valid_in == 1'b1) begin
        PE_column_activation_input = data_in;
    end
    else begin
        PE_column_activation_input = 9'd0;
    end
end

//Handle PE_column_weight_input, concate weight_r to the input of PE_column. The reason for doing this is because verilog is not supporting input an array
always @(*) begin
    for (x = 0; x < O_CH; x = x + 1) begin
        PE_column_weight_input[9*(O_CH-x)-1-:9] = weight_r[x];
    end
end

//Handle PE_column_psum_input
always @(*) begin
    for (y = 0; y <= O_CH-1; y = y + 1) begin
        PE_column_psum_input[WIDTH*(O_CH-y)-1-:WIDTH] = psum_r[y][OUT_ROW_LENGTH-1];
    end
end

//Instantiate PE_column
PE_column PE_column (
    .clk_in(clk_in),
    .activation_in(PE_column_activation_input),
    .weight_in(PE_column_weight_input),
    .psum_in(PE_column_psum_input),
    .psum_out(PE_column_psum_output)
);

/*Begin handling outputs*/
//Handle pop_count_r, add by 1 when pop_in is true
always @(*) begin
    if (pop_in == 1'b1) begin
        pop_count_w = pop_count_r + 1;
    end
    else begin
        pop_count_w = 6'd0;
    end
end

always @(posedge clk_in) begin
    pop_count_r <= pop_count_w;
end

//Handling the output sum_out, collecting the sign bit of the psum_r with corresponding row index pop_count_r
always @(*) begin
    for (z = 0; z <= OUT_ROW_LENGTH-1; z = z + 1) begin
        sum_out[OUT_ROW_LENGTH-z-1] = psum_r[pop_count_r][z][WIDTH-1]; //Sign bit
    end
end

endmodule

//Todo, TB