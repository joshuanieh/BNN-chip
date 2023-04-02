`timescale 1ns/10ps
`define CYCLE    10           	              // Modify your clock period here
`define SDFFILE    "./systolic_array_tb.sdf"  // Modify your sdf file name
`define DATA       "./data.dat"               // Modify your test image file
`define WEIGHT     "./weight.dat"             // Modify your test image file
`define EXPECT     "./golden.dat"             // Modify your output golden file

module systolic_array_tb;

reg           clk;
reg           rst;
reg           load_weight;
reg   [8:0]   activation_in[0:3];
reg   [12:0]  psum_in[0:3];
reg   [8:0]   weight_in;
wire  [8:0]   activation_out[0:3];
wire  [12:0]  psum_out[0:3];

reg   [12:0]  out_mem     [0:4-1];
reg   [8:0]   data_mem    [0:4-1];
reg   [8:0]   weight_mem  [0:16-1];

reg           stop;
integer       i, out_file, err;

systolic_array systolic_array( 
    .clk_in(clk), .rst_in(rst), .load_weight_in(load_weight),
    .activation_column_0_in(activation_in[0]), .activation_column_1_in(activation_in[1]), .activation_column_2_in(activation_in[2]), .activation_column_3_in(activation_in[3]),
    .psum_row_0_in(psum_in[0]), .psum_row_1_in(psum_in[1]), .psum_row_2_in(psum_in[2]), .psum_row_3_in(psum_in[3]),
    .weight_in(weight_in),
    .psum_row_0_out(psum_out[0]), .psum_row_1_out(psum_out[1]), .psum_row_2_out(psum_out[2]), .psum_row_3_out(psum_out[3]),
    .activation_column_0_out(activation_out[0]), .activation_column_1_out(activation_out[1]), .activation_column_2_out(activation_out[2]), .activation_column_3_out(activation_out[3])
);       

`ifdef SDF
initial $sdf_annotate(`SDFFILE, systolic_array);
`endif   

initial	$readmemb (`DATA,    data_mem);
initial	$readmemb (`WEIGHT,  weight_mem);
// initial	$readmemb (`SKIP,    skip_mem);
initial	$readmemb (`EXPECT,  out_mem);

initial begin
    clk         = 1'b1;
    rst         = 1'b1;
    stop        = 1'b0;
    err         = 0;
    i           = 0;   
    
    #2.5 rst = 1'b0;                            // system rst
    #2.5 rst = 1'b1;

    @(negedge clk);
    load_weight = 1'b1;
    for(i=0;i<16;i=i+1) begin
        weight_in = weight_mem[i];
        @(negedge clk);
    end
    load_weight = 1'b0;
    
    activation_in[0] = data_mem[0];
    
    @(negedge clk);
    activation_in[1] = data_mem[1];
    
    @(negedge clk);
    activation_in[2] = data_mem[2];
    
    @(negedge clk);
    activation_in[3] = data_mem[3];
    
    @(negedge clk);
    psum_in[0] = 13'd0;
    
    @(negedge clk);
    psum_in[1] = 13'd0;
    $fdisplay(out_file,"%b", psum_out[0]);
    if(psum_out[0] !== out_mem[0]) begin
        $display("ERROR at %d:output %b !=expect %b ",0, psum_out[0], out_mem[0]);
        err = err + 1;
    end
    
    @(negedge clk);
    psum_in[2] = 13'd0;
    $fdisplay(out_file,"%b", psum_out[1]);
    if(psum_out[1] !== out_mem[1]) begin
        $display("ERROR at %d:output %b !=expect %b ",1, psum_out[1], out_mem[1]);
        err = err + 1;
    end

    @(negedge clk);
    psum_in[3] = 13'd0;
    $fdisplay(out_file,"%b", psum_out[2]);
    if(psum_out[2] !== out_mem[2]) begin
        $display("ERROR at %d:output %b !=expect %b ",2, psum_out[2], out_mem[2]);
        err = err + 1;
    end

    @(negedge clk);
    $fdisplay(out_file,"%b", psum_out[3]);
    if(psum_out[3] !== out_mem[3]) begin
        $display("ERROR at %d:output %b !=expect %b ",3, psum_out[3], out_mem[3]);
        err = err + 1;
    end

    #10
    stop = 1'b1;
end

always begin #(`CYCLE/2) clk = ~clk; end

initial begin
	$dumpfile("systolic_array.vcd");
	$dumpvars;

   out_file = $fopen("out.dat");
   if (out_file == 0) begin
        $display("Output file open error !");
        $finish;
   end
end


// always @(negedge clk)begin
//     if(i < DATA_LENGTH) begin
//         // skip_in   = skip_mem[i];
//         activation_in   = data_mem[i];
//         weight_in = weight_mem[i];
//     end
// 	i = i+1;
// end

// always @(posedge clk)begin
//     if (i == DATA_LENGTH + 1) begin
//         stop = 1'b1;
//     end
//     #(0.2*`CYCLE);
//     if (i > 0) begin
//         $fdisplay(out_file,"%b", psum_out);
//         if(psum_out !== out_mem[i-1]) begin
//             $display("ERROR at %d:output %h !=expect %h ",i-1, psum_out, out_mem[i-1]);
//             err = err + 1;
//         end
//     end
// end

initial begin
    @(posedge stop)
    $display("---------------------------------------------\n");
    if (err == 0)  begin
    $display("Your DUT pass the test!\n");
    $display("-------------------GOOD-------------------\n");
    end
    else begin
    $display("There are %d errors!\n", err);
    $display("-------------------BAD--------------------\n");
    end
    $fclose(out_file);
    $finish;
end
endmodule