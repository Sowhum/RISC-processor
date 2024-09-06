`timescale 1ns / 1ps

module processor (
    input clk,reset
);

  wire [1:0] ALU_op;
  wire [3:0] opcode;
  wire [15:0] instr;
  wire jump;
  wire beq;
  wire bne;
  wire mem_read_en;
  wire mem_write_en;
  wire ALU_source;
  wire dp_en;
  wire mem_to_reg;
  wire reg_write_en;
  wire flush;
  wire branch_resolved;

  datapath u_datapath (
      .clk(clk),
      .reset(reset),
      .jump(jump),
      .beq(beq),
      .bne(bne),
      .mem_write_en(mem_write_en),
      .mem_read_en(mem_read_en),
      .alu_source(ALU_source),
      .dp_en(dp_en),
      .reg_write_en(reg_write_en),
      .mem_to_reg(mem_to_reg),
      .flush(flush),
      .ALU_op(ALU_op),
      .opcode(opcode),
      .instruction_IF_ID(instr),
      .branch_resolved_ID(branch_resolved)
  );

  control_unit u_control_unit (
      .clk(clk),
      .reset(reset),
      .branch_resolved(branch_resolved),
      .instr(instr),
      .alu_opcode(opcode),
      .alu_op(ALU_op),
      .jump(jump),
      .beq(beq),
      .bne(bne),
      .flush(flush),
      .mem_read_en(mem_read_en),
      .mem_write_en(mem_write_en),
      .ALU_source(ALU_source),
      .reg_dst(dp_en),
      .mem_to_reg(mem_to_reg),
      .reg_write_en(reg_write_en)
  );

endmodule
