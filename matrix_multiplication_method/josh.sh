#!/bin/bash

# python3 testbench_data_generator.py
# iverilog -o kernel.out kernel_tb.v kernel.v
# ./kernel.out

python3 testbench_data_generator.py
iverilog -o systolic_array.out systolic_array_tb.v systolic_array.v
./systolic_array.out