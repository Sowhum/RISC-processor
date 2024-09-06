`timescale 1ns / 1ps

module control_unit (
    input      [15:0] instr,
    input             clk,
    input             reset,
    input             branch_resolved,
    output reg [ 1:0] alu_op,
    output reg        jump,
    output reg        beq,
    output reg        bne,
    output reg        mem_read_en,
    output reg        mem_write_en,
    output reg        ALU_source,
    output reg        reg_dst,
    output reg        mem_to_reg,
    output reg        reg_write_en,
    output reg        flush,
    output reg [ 3:0] alu_opcode
);

  //FIX: store the pcbe in somethng thre is  aone clock difference, also, make
  //beq in controlunit go down as soon as branch is resolved in order to not
  //make more beq_control
  wire [3:0] opcode;
  assign opcode = instr[15:12];
  always @(*) begin
    jump  = 1'b0;
    flush = 1'b0;
    beq   = 1'b0;
    bne   = 1'b0;
    if (opcode == 4'b1101) begin  // jump
      jump  = 1'b1;
      flush = 1'b1;  // trigger flush for jump immediately
    end else if (opcode == 4'b1011 && !branch_resolved) begin
      beq = 1'b1;
    end else if (opcode == 4'b1100 && !branch_resolved) begin
      bne = 1'b1;
    end
  end
  initial begin
    beq   = 1'b0;
    bne   = 1'b0;
    jump  = 1'b0;
    flush = 1'b0;
  end
  always @(posedge reset) begin
    alu_op <= 2'b00;
    mem_read_en <= 1'b0;
    mem_write_en <= 1'b0;
    ALU_source <= 1'b0;
    reg_dst <= 1'b0;
    mem_to_reg <= 1'b0;
    reg_write_en <= 1'b0;
  end
  always @(posedge clk) begin
    alu_opcode <= instr[15:12];
    if (instr == 16'd0) begin
      alu_op <= 2'b00;
      // <= 1'b0;
      // 1'b0;
      // 1'b0;
      mem_read_en <= 1'b0;
      mem_write_en <= 1'b0;
      ALU_source <= 1'b0;
      reg_dst <= 1'b0;
      mem_to_reg <= 1'b0;
      reg_write_en <= 1'b0;
      // <= 1'b0;
    end else begin
      case (opcode)
        4'b0000: begin  // load word (in reg)
          alu_op <= 2'b10;  //opcode for ALU
          // <= 1'b0;  // flag for jump
          // 1'b0;  // flag for beq_control
          // 1'b0;  // flag for bne_control
          mem_read_en <= 1'b1;  // memory read enable
          mem_write_en <= 1'b0;  // memory write enable
          ALU_source <= 1'b1;  // multiplexer select for read_data2 (ALU b)
          reg_dst <= 1'b0;  // multiplexer select for reg_write_dest
          mem_to_reg <= 1'b1;  // multiplexer select for reg_write_data
          reg_write_en <= 1'b1;  // register write enable
          // <= 1'b0;  //flush for //
        end
        4'b0001: begin  //store word (in mem)
          alu_op <= 2'b10;
          // <= 1'b0;
          // 1'b0;
          // 1'b0;
          mem_read_en <= 1'b0;
          mem_write_en <= 1'b1;
          ALU_source <= 1'b1;
          reg_dst <= 1'b0;
          mem_to_reg <= 1'b0;
          reg_write_en <= 1'b0;
          // <= 1'b0;
        end
        4'b0010: begin  // add
          alu_op <= 2'b00;
          // <= 1'b0;
          // 1'b0;
          // 1'b0;
          mem_read_en <= 1'b0;
          mem_write_en <= 1'b0;
          ALU_source <= 1'b0;
          reg_dst <= 1'b1;
          mem_to_reg <= 1'b0;
          reg_write_en <= 1'b1;
          // <= 1'b0;
        end
        4'b0011: begin  //sub
          alu_op <= 2'b00;
          // <= 1'b0;
          // 1'b0;
          // 1'b0;
          mem_read_en <= 1'b0;
          mem_write_en <= 1'b0;
          ALU_source <= 1'b0;
          reg_dst <= 1'b1;
          mem_to_reg <= 1'b0;
          reg_write_en <= 1'b1;
          // <= 1'b0;
        end
        4'b0100: begin  // invert
          alu_op <= 2'b00;
          // <= 1'b0;
          // 1'b0;
          // 1'b0;
          mem_read_en <= 1'b0;
          mem_write_en <= 1'b0;
          ALU_source <= 1'b0;
          reg_dst <= 1'b1;
          mem_to_reg <= 1'b0;
          reg_write_en <= 1'b1;
          // <= 1'b0;
        end
        4'b0101: begin  //shift left
          alu_op <= 2'b00;
          // <= 1'b0;
          // 1'b0;
          // 1'b0;
          mem_read_en <= 1'b0;
          mem_write_en <= 1'b0;
          ALU_source <= 1'b0;
          reg_dst <= 1'b1;
          mem_to_reg <= 1'b0;
          reg_write_en <= 1'b1;
          // <= 1'b0;
        end
        4'b0110: begin  // shift right
          alu_op <= 2'b00;
          // <= 1'b0;
          // 1'b0;
          // 1'b0;
          mem_read_en <= 1'b0;
          mem_write_en <= 1'b0;
          ALU_source <= 1'b0;
          reg_dst <= 1'b1;
          mem_to_reg <= 1'b0;
          reg_write_en <= 1'b1;
          // <= 1'b0;
        end
        4'b0111: begin  //AND
          alu_op <= 2'b00;
          // <= 1'b0;
          // 1'b0;
          // 1'b0;
          mem_read_en <= 1'b0;
          mem_write_en <= 1'b0;
          ALU_source <= 1'b0;
          reg_dst <= 1'b1;
          mem_to_reg <= 1'b0;
          reg_write_en <= 1'b1;
          // <= 1'b0;
        end
        4'b1000: begin  //OR
          alu_op <= 2'b00;
          // <= 1'b0;
          // 1'b0;
          // 1'b0;
          mem_read_en <= 1'b0;
          mem_write_en <= 1'b0;
          ALU_source <= 1'b0;
          reg_dst <= 1'b1;
          mem_to_reg <= 1'b0;
          reg_write_en <= 1'b1;
          // <= 1'b0;
        end
        4'b1001: begin  //STL
          alu_op <= 2'b00;
          // <= 1'b0;
          // 1'b0;
          // 1'b0;
          mem_read_en <= 1'b0;
          mem_write_en <= 1'b0;
          ALU_source <= 1'b0;
          reg_dst <= 1'b1;
          mem_to_reg <= 1'b0;
          reg_write_en <= 1'b1;
          // <= 1'b0;
        end
        4'b1011: begin  //beq
          alu_op <= 2'b01;
          // <= 1'b0;
          // 1'b1;
          // 1'b0;
          mem_read_en <= 1'b0;
          mem_write_en <= 1'b0;
          ALU_source <= 1'b0;
          reg_dst <= 1'b0;
          mem_to_reg <= 1'b0;
          reg_write_en <= 1'b0;
          // <= 1'b0;
        end
        4'b1100: begin  //bne
          alu_op <= 2'b01;
          // <= 1'b0;
          // 1'b0;
          // 1'b1;
          mem_read_en <= 1'b0;
          mem_write_en <= 1'b0;
          ALU_source <= 1'b0;
          reg_dst <= 1'b0;
          mem_to_reg <= 1'b0;
          reg_write_en <= 1'b0;
          // <= 1'b0;
        end
        4'b1101: begin  ////
          alu_op <= 2'b00;
          // <= 1'b1;
          // 1'b0;
          // 1'b0;
          mem_read_en <= 1'b0;
          mem_write_en <= 1'b0;
          ALU_source <= 1'b0;
          reg_dst <= 1'b0;
          mem_to_reg <= 1'b0;
          reg_write_en <= 1'b0;
          // <= 1'b1;
        end
        default: begin
          alu_op <= 2'b00;
          // <= 1'b0;
          // 1'b0;
          // 1'b0;
          mem_read_en <= 1'b0;
          mem_write_en <= 1'b0;
          ALU_source <= 1'b0;
          reg_dst <= 1'b1;
          mem_to_reg <= 1'b0;
          reg_write_en <= 1'b1;
          // <= 1'b0;
        end
      endcase
    end
  end
endmodule



