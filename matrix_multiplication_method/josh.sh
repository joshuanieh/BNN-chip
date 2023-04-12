#!/bin/bash

# python3 testbench_data_generator.py
# iverilog -o kernel.out kernel_tb.v kernel.v
# ./kernel.out

python3 testbench_data_generator.py
iverilog -o PE_array.out PE_array_tb.v PE_array_27.v
./PE_array.out