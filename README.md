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
- **Data Forwarding**: For register values if needed before WB
- **Branch and Stall Logic**: Handling hazards for branch instructions by detecting in IF and stalling
- **Jump and Flush Logic**: Handling hazards for jump instruction by flushing unwanted instructions
- **Verification**: Verified through simulation in Vivado with various instructions in memory files.

## Simulations
The instruction file is running this set of instructions <br>
0010000001010000 // Add R2 <- R0 + R1 (2050 in HEX) <br>
0010010101011000 // sub R3 <- R0 - R1 (2558 in HEX) <br>
1011011110000001 // BEQ branch to jump if R3=R6 (b781 in HEX), PCnew= PC+2+offset<<1 => offset is 1, skips next instruction <br>
0010000001010000 // gets skipped <br>
1101000000000001 // J jump to the second address (d001 in HEX) <br>

You can observe the instruction_IF_ID flushing after JMP where it is assigned to 16'b0 as well as the stall taking place till branch is resolved after BEQ

![image](https://github.com/user-attachments/assets/f605ae3c-e3dd-49db-9fd9-e3bcd6150a03)
