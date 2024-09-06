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
**0010000001010000** // Add R2 <- R0 + R1 (2050 in HEX) <br>
**0010010101011000** // Add R3 <- R5 + R2 (2558 in HEX) <br>
**1011011110000001** // BEQ branch to jump if R3=R6 (b781 in HEX), PCnew= PC+2+offset<<1 => offset is 1, skips next instruction <br>
**0010000001010000** // gets skipped <br>
**1101000000000001** // J jump to the second address (d001 in HEX) <br>

You can observe the instruction_IF_ID flushing after JMP where it is assigned to 16'b0 as well as the stall taking place till branch is resolved after BEQ

![image](https://github.com/user-attachments/assets/f605ae3c-e3dd-49db-9fd9-e3bcd6150a03) <br>

- **Data Processing ADD with Forwarding**
![image](https://github.com/user-attachments/assets/247de4fc-879c-46a4-91e1-164fbcfdebe0)
<br>
Here the path of data can be traced (highlighted in yellow) in an ADD instruction, both reg data adds to get 0+1=1<br>
This is then written to addr 2 of the register which can be seen highlighted in blue

**Note:** the instruction right next to it involves taking value at addr2, here data forwarding is done to the ALU so when it **ALU_out** is calculated it yields 6 (5+1) instead of 7 (5+2) 
<br>
- **Branch and stalling**
  ![image](https://github.com/user-attachments/assets/e33227aa-ffdd-48bf-b93a-2dba8429bb7f)
In this case instruction 6 is skipped and 8 is used

Here stalling of **pc_current** and **pc_next** can be seen at value **4** <br>
This is trigerred by the **stall signal** , and resumes function when **branch_resolved** pulses <br>
The value of **PC_2beq** (8) is stored in **pc_next** when **beq_control** goes high <br>
**Note: ** The value for branch_resolved is also given to control unit via ID in order to not make **beq** go up again (as instruction is still in pipeline)
<br>
- **Jump and stalling**
![image](https://github.com/user-attachments/assets/6c13ab6a-d098-4cc5-97b9-55ab9462684e)
<br>
Incorrect instruction is flsuh from the pipeline after JUMP(d001) and is replaced with 16'b0 <br>
This is based on the **jump** and **flush** signals, the correct instruction can been seen moving through pipeline later as 2558
