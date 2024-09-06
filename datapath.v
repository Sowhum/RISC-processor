`timescale 1ns / 1ps

module datapath (
    input clk,
    input reset,
    input jump,
    input beq,
    input bne,
    input mem_write_en,
    input mem_read_en,
    input alu_source,
    input dp_en,
    input reg_write_en,
    input mem_to_reg,
    input flush,
    input [1:0] ALU_op,
    input [3:0] opcode,
    output [15:0] instruction_IF_ID,
    output reg branch_resolved_ID
);
  reg  [15:0] pc_current;
  reg [15:0] pc_next;
  wire [15:0] pc2;
  wire [15:0] instr;
  wire [ 2:0] reg_write_addr;
  wire [15:0] reg_write_data;
  wire [ 2:0] reg_read_addr_1;
  wire [15:0] reg_read_data_1;
  wire [ 2:0] reg_read_addr_2;
  wire [15:0] reg_read_data_2;
  wire [15:0] ext_im;
  wire [15:0] read_data;
  wire [15:0] ALU_input1;
  wire [15:0] ALU_input2;
  wire [ 2:0] ALU_control;
  wire [15:0] ALU_out;
  wire [15:0] PC_j;
  wire [15:0] PC_beq;
  wire [15:0] PC_2beq;
  wire [15:0] PC_bne;
  wire [15:0] PC_2bne;
  wire [12:0] offset;
  wire [15:0] mem_read_data;
  wire        beq_control;
  wire        bne_control;
  wire        zero_flag;

  //piepline freezing
  reg         stall;
  reg         branch_resolved;

  //pipeline registers
  reg [1:0] forward_1, forward_2;
  reg [15:0] IF_ID_instr;
  reg [15:0] IF_ID_pc;
  reg [ 2:0] ID_EX_reg_read_addr_1;
  reg [ 2:0] ID_EX_reg_read_addr_2;
  reg [15:0] ID_EX_reg_read_data_1;
  reg [15:0] ID_EX_reg_read_data_2;
  reg [15:0] ID_EX_ext_im;
  reg [ 2:0] ID_EX_reg_write_addr;
  reg [ 2:0] ID_EX_ALU_control;
  reg [15:0] ID_EX_ALU_out;
  reg        ID_EX_reg_write_en;
  reg        ID_EX_mem_read_en;
  reg        ID_EX_mem_write_en;
  reg        ID_EX_mem_to_reg;
  reg [15:0] EX_MEM_ALU_out;
  reg [ 2:0] EX_MEM_reg_write_addr;
  reg        EX_MEM_reg_write_en;
  reg        EX_MEM_mem_read_en;
  reg        EX_MEM_mem_write_en;
  reg        EX_MEM_mem_to_reg;
  reg [15:0] EX_MEM_reg_read_data_2;
  reg [15:0] MEM_WB_mem_read_data;
  reg [15:0] MEM_WB_ALU_out;
  reg        MEM_WB_reg_write_en;
  reg [ 2:0] MEM_WB_reg_write_addr;
  reg        MEM_WB_mem_to_reg;

  initial begin
    pc_current = 16'd0;
    IF_ID_pc   = 16'd0;
  end

  memory_instructions u_memory_instructions (
      .pc(pc_current),
      .instruction(instr)
  );


  always @(*) begin
    // Load-use hazard stall
    if (ID_EX_mem_read_en &&
        (ID_EX_reg_write_addr == reg_read_addr_1 || ID_EX_reg_write_addr == reg_read_addr_2)) begin
      stall = 1'b1;
    end  // Branch instruction stall
    else if ((instr[15:12] == 4'b1011 || instr[15:12] == 4'b1100) && !branch_resolved) begin
      stall = 1'b1;
    end else begin
      stall = 1'b0;
    end
  end

  always @(posedge clk) begin
    if (!stall) begin  //pipeline stalling
      pc_current <= pc_next;
    end
    if (flush) begin
      IF_ID_instr <= 16'd0;
    end else begin
      IF_ID_instr <= instr;
    end
    IF_ID_pc   <= pc_current;

    ID_EX_reg_read_addr_1 <= reg_read_addr_1;
    ID_EX_reg_read_addr_2 <= reg_read_addr_2;
    ID_EX_reg_read_data_1 <= reg_read_data_1;
    ID_EX_reg_read_data_2 <= reg_read_data_2;
    ID_EX_ext_im <= ext_im;
    ID_EX_reg_write_addr <= reg_write_addr;
    ID_EX_reg_write_en <= reg_write_en;
    ID_EX_ALU_control <= ALU_control;
    ID_EX_mem_read_en <= mem_read_en;
    ID_EX_mem_write_en <= mem_write_en;
    ID_EX_mem_to_reg <= mem_to_reg;

    EX_MEM_reg_write_addr <= ID_EX_reg_write_addr;
    EX_MEM_reg_write_en <= ID_EX_reg_write_en;
    EX_MEM_mem_read_en <= ID_EX_mem_read_en;
    EX_MEM_mem_write_en <= ID_EX_mem_write_en;
    EX_MEM_ALU_out <= ALU_out;
    EX_MEM_reg_read_data_2 <= ID_EX_reg_read_data_2;
    EX_MEM_mem_to_reg <= ID_EX_mem_to_reg;

    MEM_WB_reg_write_en <= EX_MEM_reg_write_en;
    MEM_WB_reg_write_addr <= EX_MEM_reg_write_addr;
    MEM_WB_mem_read_data <= mem_read_data;
    MEM_WB_ALU_out <= EX_MEM_ALU_out;
    MEM_WB_mem_to_reg <= EX_MEM_mem_to_reg;
  end

  always @(*) begin
    //Forwarding from EX/MEM
    if (EX_MEM_reg_write_en && (EX_MEM_reg_write_addr == ID_EX_reg_read_addr_1)) begin
      forward_1 = 2'b01;
    end else if (MEM_WB_reg_write_en && (MEM_WB_reg_write_addr == ID_EX_reg_read_addr_1)) begin
      forward_1 = 2'b10;
    end else begin
      forward_1 = 2'b00;
    end
    //Forwarding from MEM/WB
    if (EX_MEM_reg_write_en && (EX_MEM_reg_write_addr == ID_EX_reg_read_addr_2)) begin
      forward_2 = 2'b01;
    end else if (MEM_WB_reg_write_en && (MEM_WB_reg_write_addr == ID_EX_reg_read_addr_2)) begin
      forward_2 = 2'b10;
    end else begin
      forward_2 = 2'b00;
    end
  end

  assign pc2 = pc_current + 16'd2;

  assign offset = {IF_ID_instr[11:0], 1'b0};  //lower 12 bits of opcode << 1
  assign PC_j = {pc2[15:13], offset};
  //NOTE: dp as in data processing
  assign reg_write_addr = (dp_en == 1'b1) ? IF_ID_instr[5:3] : IF_ID_instr[8:6];  //mux write adddr
  assign reg_read_addr_1 = IF_ID_instr[11:9];
  assign reg_read_addr_2 = IF_ID_instr[8:6];
  assign ext_im = {
    {10{IF_ID_instr[5]}}, IF_ID_instr[5:0]
  };  // immediate value embedded in instruction
  assign read_data = (alu_source == 1'b1) ? ID_EX_ext_im : ID_EX_reg_read_data_2;  // mux data2 ALU

  register u_register (
      .clk(clk),
      .write_en(MEM_WB_reg_write_en),
      .write_dest(MEM_WB_reg_write_addr),
      .read_dest_1(reg_read_addr_1),
      .read_dest_2(reg_read_addr_2),
      .read_data_1(reg_read_data_1),
      .read_data_2(reg_read_data_2),
      .write_data(reg_write_data)
  );

  //Master mux for ALU
  assign ALU_input1=(forward_1==2'b01)?EX_MEM_ALU_out :
                    (forward_1==2'b10) ? MEM_WB_ALU_out : ID_EX_reg_read_data_1;

  assign ALU_input2=(forward_2==2'b01)?EX_MEM_ALU_out :
                    (forward_2==2'b10) ? MEM_WB_ALU_out : read_data;

  ALU_control u_ALU_control (
      .alu_op(ALU_op),//NOTE: Values for ID stage after receiving ALU OP & control from control unit
      .opcode(opcode),
      .alu_count(ALU_control)
  );

  ALU u_ALU (  //NOTE: Values for EX stage
      .data1(ALU_input1),  //ID_EX_reg_read_data_1),
      .data2(ALU_input2),  //read_data),
      .control(ID_EX_ALU_control),
      .result(ALU_out),
      .zero(zero_flag)
  );

  assign PC_beq = pc2 + {ext_im[14:0], 1'b0};
  assign PC_bne = pc2 + {ext_im[14:0], 1'b0};

  assign beq_control = beq & zero_flag;
  assign bne_control = bne & (~zero_flag);
  
  always @(posedge clk) begin
    if (beq_control || bne_control) begin
      branch_resolved <= 1'b1;
      branch_resolved_ID <= 1'b1;
    end 
    else if (pc_current != IF_ID_pc)begin
    branch_resolved_ID <= 1'b0;
    end else branch_resolved <= 1'b0;
  end

  assign PC_2beq = (beq_control == 1'b1) ? PC_beq : pc2;
  assign PC_2bne = (bne_control == 1'b1) ? PC_bne : PC_2beq;
  
always @(*) begin
if(stall || branch_resolved) begin
if(beq_control || bne_control) pc_next = PC_2bne;
end
else begin 
pc_next = (jump == 1'b1) ? PC_j : PC_2bne;
end

end

  data_memory u_data_memory (
      .clk(clk),
      .write_en(EX_MEM_mem_write_en),
      .read_en(EX_MEM_mem_read_en),
      .addr(EX_MEM_ALU_out),
      .write_data(EX_MEM_reg_read_data_2),
      .read_data(mem_read_data)
  );
  assign reg_write_data = (MEM_WB_mem_to_reg == 1) ? MEM_WB_mem_read_data : MEM_WB_ALU_out;  // WB
  assign instruction_IF_ID = IF_ID_instr;
endmodule
