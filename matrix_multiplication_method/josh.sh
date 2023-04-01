#!/bin/bash
python3 testbench_data_generator.py
iverilog -o kernel.o kernel_tb.v kernel.v
./kernel.o
