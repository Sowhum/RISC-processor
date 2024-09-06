# RISC Processor

## Overview

A simple 16-bit pipelined RISC Processor designed in Verilog following Harvard architecture

## Details
- **16-bit**: The processor supports a 16-bit instruction set and data path.
- **Harvard Architecture**: Separate instruction and data memory for improved performance.
- **5-Stage Pipeline**: 
  - **Fetch**: Instruction fetch from memory
  - **Decode**: Instruction decoding
  - **Execute**: Execution of the instruction
  - **Memory Access**: Data memory read/write operations
  - **Write Back**: Writing back to the register
- **Branch and Stall Logic**: Handling hazards for branch instructions by detecting in IF and stalling
- **Jump and Flush Logic**: Handling hazards for jump instruction by flushing unwanted instructions
- **Verification**: Verified through simulation in Vivado with various instructions in memory files.
