`timescale 1ns/10ps
`define CYCLE    10           	              // Modify your clock period here
`define SDFFILE    "./top_syn.sdf"        // Modify your sdf file name
`define DATA       "./data.dat"               // Modify your test image file
`define EXPECT     "./golden.dat"             // Modify your output golden file
// `include "top.v"
module PE_array_tb;

initial begin
    #(1000000*`CYCLE);
    $display("Time too long.");
    $finish;
end

parameter k = 1;//runs, say PE row length*3*k i_CH
parameter WIDTH = 14;//psum bit width
parameter OUT_ROW_LENGTH = 4;//PE row length
parameter O_CH = 64;//how many PE rows
parameter I_CH = 3;//how many PE rows

reg           clk;
reg           rst;//right after reset, pass weight and data interleavedly
reg   [9-1:0]  data_in;
reg   load_weight, pop, in_valid;
wire  [WIDTH-1:0]  sum_out;
reg   [WIDTH-1:0]  out_mem     [0:O_CH*OUT_ROW_LENGTH-1];
reg   [9-1:0]   data_mem    [0:O_CH*I_CH+OUT_ROW_LENGTH*I_CH-1];//O_CH represents weights, 1 represents activation

reg           stop;
integer       i, out_file, err, line_count, now_pos, j;

top top (
    .clk_in(clk),
    .rst_in(rst),         //When needing to compute new rows, reset all the psum_r to zero. My system use active low reset.
    .data_in(data_in),        //Can serve as weight or activation
    .load_weight_in(load_weight), //If true, count weight index, fill the weight with corresponding index with data_in
    .in_valid_in(in_valid),    //If true, rotate the psum shifter
    .pop_in(pop),         //If true, count pop index, pop the psum_r with corresponding index to sum_out
    .sum_out(sum_out)
);   

`ifdef SDF
initial $sdf_annotate(`SDFFILE, top);
`endif   

initial	$readmemb (`DATA,    data_mem);
initial	$readmemb (`EXPECT,  out_mem);

initial begin
    clk         = 1'b0;
    rst         = 1'b0;
    stop        = 1'b0;
    load_weight = 1'b0;
    in_valid = 1'b0;
    pop = 1'b0;

    err         = 0;
    i           = 0;   
    line_count = 0;
    now_pos = line_count;

    #(0.9*`CYCLE) rst = 1'b1;                            // system rst

    for(i=line_count;i<now_pos + O_CH;i=i+1) begin
        // $display("Loading weight");
        @(posedge clk);
        #(0.001*`CYCLE);
        load_weight = 1'b1;
        data_in = data_mem[i];
        line_count = line_count + 1;
    end

    now_pos = line_count;
    
    for(i=line_count;i<now_pos+OUT_ROW_LENGTH;i=i+1) begin
        @(posedge clk);
        #(0.001*`CYCLE);
        // $display("Loading input");
        load_weight = 1'b0;
        in_valid = 1'b1;
        data_in = data_mem[i];
        line_count = line_count + 1;
    end
    now_pos = line_count;
    
    for(i=line_count;i<now_pos + O_CH;i=i+1) begin
        @(posedge clk);
        #(0.001*`CYCLE);
        in_valid = 1'b0;
        load_weight = 1'b1;
        data_in = data_mem[i];
        line_count = line_count + 1;
    end

    now_pos = line_count;
    
    for(i=line_count;i<now_pos+OUT_ROW_LENGTH;i=i+1) begin
        @(posedge clk);
        #(0.001*`CYCLE);
        load_weight = 1'b0;
        in_valid = 1'b1;
        data_in = data_mem[i];
        line_count = line_count + 1;
    end
    now_pos = line_count;
    
    for(i=line_count;i<now_pos + O_CH;i=i+1) begin
        @(posedge clk);
        #(0.001*`CYCLE);
        in_valid = 1'b0;
        load_weight = 1'b1;
        data_in = data_mem[i];
        line_count = line_count + 1;
    end

    now_pos = line_count;
    
    for(i=line_count;i<now_pos+OUT_ROW_LENGTH;i=i+1) begin
        @(posedge clk);
        #(0.001*`CYCLE);
        load_weight = 1'b0;
        in_valid = 1'b1;
        data_in = data_mem[i];
        line_count = line_count + 1;
    end
    // #(`CYCLE);
    @(posedge clk);
    #(0.00001*`CYCLE);
    in_valid = 1'b0;
    pop = 1'b1;
    for(i=0;i<O_CH*OUT_ROW_LENGTH;i=i+1) begin
        // $display("Poping output");
            #(0.99998*`CYCLE);
            $fwrite(out_file,"%b ", $signed(sum_out));
            if(i%OUT_ROW_LENGTH == 3) $fdisplay(out_file);
            if(sum_out !== out_mem[i]) begin
                $display("ERROR at %d:output %b != expect %b ",i, sum_out, out_mem[i]);
                err = err + 1;
            end
            @(posedge clk);
            #(0.00001*`CYCLE);
    end
    @(negedge clk);
    pop = 1'b0;
    // #(3*`CYCLE)
    // for (i = 0; i<O_CH; i=i+1) begin
    //     $fdisplay(out_file,"%b", sum_out);
    //     if(sum_out !== out_mem[i]) begin
    //         $display("ERROR at %d:output %b !=expect %b ",i, sum_out, out_mem[i]);
    //         err = err + 1;
    //     end
    //     #(`CYCLE);
    // end
    
    #10
    stop = 1'b1;
end

always begin #(`CYCLE/2) clk = ~clk; end

initial begin
    $fsdbDumpfile("top.fsdb");            
    $fsdbDumpvars(0,PE_array_tb,"+mda");

	// $dumpfile("PE_array.vcd");
	// $dumpvars;

   out_file = $fopen("out.dat");
   if (out_file == 0) begin
        $display("Output file open error!");
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
//         $fdisplay(out_file,"%b", sum_out);
//         if(sum_out !== out_mem[i-1]) begin
//             $display("ERROR at %d:output %h !=expect %h ",i-1, sum_out, out_mem[i-1]);
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
