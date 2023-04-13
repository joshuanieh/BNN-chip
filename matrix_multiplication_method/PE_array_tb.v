`timescale 1ns/10ps
`define CYCLE    10           	              // Modify your clock period here
`define SDFFILE    "./PE_array_tb.sdf"        // Modify your sdf file name
`define DATA       "./data.dat"               // Modify your test image file
`define WEIGHT     "./weight.dat"             // Modify your test image file
`define EXPECT     "./golden.dat"             // Modify your output golden file

module PE_array_tb;

initial begin
    #(100*`CYCLE);
    $display("Time too long.");
    $finish;
end

parameter k = 1;//runs, say PE row length*3*k i_CH
parameter ROW_LENGTH = 7;//PE row length
parameter O_CH = 3;//how many PE rows
parameter WIDTH = 14;//psum bit width

reg           clk;
reg           rst;//right after reset, pass weight and data interleavedly
reg   [27-1:0]  data_in;
wire  [WIDTH-1:0]  psum_out;
reg   [WIDTH-1:0]  out_mem     [0:O_CH-1];
reg   [27-1:0]   data_mem    [0:(O_CH+1)*ROW_LENGTH*k-1];//O_CH represents weights, 1 represents activation

reg           stop;
integer       i, out_file, err;

PE_array PE_array( 
    .data_in(data_in),
    .psum_out(psum_out),
    .clk_in(clk), .rst_in(rst)
);       

`ifdef SDF
initial $sdf_annotate(`SDFFILE, PE_array);
`endif   

initial	$readmemb (`DATA,    data_mem);
initial	$readmemb (`EXPECT,  out_mem);

initial begin
    clk         = 1'b1;
    rst         = 1'b0;
    stop        = 1'b0;
    err         = 0;
    i           = 0;   
    
    #(2.4*`CYCLE) rst = 1'b1;                            // system rst

    for(i=0;i<(O_CH+1)*ROW_LENGTH*k;i=i+1) begin
        @(negedge clk);
        data_in = data_mem[i];
    end
    
    #(3*`CYCLE)
    for (i = 0; i<O_CH; i=i+1) begin
        $fdisplay(out_file,"%b", psum_out);
        if(psum_out !== out_mem[i]) begin
            $display("ERROR at %d:output %b !=expect %b ",i, psum_out, out_mem[i]);
            err = err + 1;
        end
        #(`CYCLE);
    end
    
    #10
    stop = 1'b1;
end

always begin #(`CYCLE/2) clk = ~clk; end

initial begin
	$dumpfile("PE_array.vcd");
	$dumpvars;

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