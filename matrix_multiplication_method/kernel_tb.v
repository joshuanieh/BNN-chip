`timescale 1ns/10ps
`define CYCLE    10           	      // Modify your clock period here
`define SDFFILE    "./kernel_tb.sdf"    // Modify your sdf file name
`define DATA       "./data.dat"       // Modify your test image file
`define WEIGHT     "./weight.dat"     // Modify your test image file
`define SKIP       "./skip.dat"       // Modify your test skip file
`define EXPECT     "./output.dat"     // Modify your output golden file

module kernel_tb;

parameter DATA_LENGTH   = 100;

reg           clk;
reg           reset;
reg   [8:0]   activation_in,weight_in;
reg   [3:0]   skip_in;
wire  [4:0]   psum_out;

reg   [3:0]   skip_mem    [0:DATA_LENGTH-1];
reg   [4:0]   out_mem     [0:DATA_LENGTH-1];
reg   [8:0]   data_mem    [0:DATA_LENGTH-1];
reg   [8:0]   weight_mem  [0:DATA_LENGTH-1];

reg           stop;
integer       i, out_file, err;

kernel kernel( .clk_in(clk),
           .reset_in(reset),
           .activation_in(activation_in),
           .weight_in(weight_in),
           .skip_in(skip_in),
           .psum_out(psum_out) );       

`ifdef SDF
initial $sdf_annotate(`SDFFILE, kernel);
`endif   

initial	$readmemb (`DATA,    data_mem);
initial	$readmemb (`WEIGHT,  weight_mem);
initial	$readmemb (`SKIP,    skip_mem);
initial	$readmemb (`EXPECT,  out_mem);

initial begin
    clk         = 1'b1;
    reset       = 1'b1;
    stop        = 1'b0;
    err         = 0;
    i           = 0;   
    
    #2.5 reset=1'b0;                            // system reset
    #2.5 reset=1'b1;
end

always begin #(`CYCLE/2) clk = ~clk; end

initial begin
	$dumpfile("kernel.vcd");
	$dumpvars;

   out_file = $fopen("out.dat");
   if (out_file == 0) begin
        $display("Output file open error !");
        $finish;
   end
end


always @(negedge clk)begin
    if(i < DATA_LENGTH) begin
        skip_in   = skip_mem[i];
        activation_in   = data_mem[i];
        weight_in = weight_mem[i];
    end
	i = i+1;
end

always @(posedge clk)begin
    if (i == DATA_LENGTH + 1) begin
        stop = 1'b1;
    end
    #(0.2*`CYCLE);
    if (i > 0) begin
        $fdisplay(out_file,"%b", psum_out);
        if(psum_out !== out_mem[i-1]) begin
            $display("ERROR at %d:output %h !=expect %h ",i-1, psum_out, out_mem[i-1]);
            err = err + 1;
        end
    end
end

initial begin
    @(posedge stop)
    $display("---------------------------------------------\n");
    if (err == 0)  begin
    $display("All data have been generated successfully!\n");
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









