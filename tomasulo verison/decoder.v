`include "define.v"
module decoder(
    input wire clk,
    input wire rst,
    //if_stage
    input wire[31:0] inst_i,
    input wire[31:0] pc_i,
 
    // alu state
    input wire alu_busy,
    input wire mul_busy, 
    input wire ls_busy,
    input wire branch_busy,
    output wire stallreq,
    input wire stall,
    //reg
    output wire[4:0] reg_rs1,
    output wire[4:0] reg_rs2,
    output reg[4:0] reg_rd,
    output wire[7:0] reg_tag,
    output reg reg_write,
    input wire[31:0] reg1_data_i,reg2_data_i,
    input wire[7:0] reg1_tag_i,reg2_tag_i,
    //rob read
    output wire rob_check_rs1,
    output wire rob_check_rs2,
    output wire[7:0] rob_tag1,rob_tag2,
    input wire rob_value1_enable,rob_value2_enable,
    input wire[31:0] rob_rs1,
    input wire[31:0] rob_rs2, 
    //rob write
    input wire[7:0] rob_tag,
    output reg rob_write,
    output reg[`ROB_BUS-1:0] rob_bus,
    //function units
    output reg alu_write,
    output reg[1:0] alu_sel, // choose which reservation station to issue : 00-alu , 01-mul , 10-ls , 11-branch
    output reg[31:0] pc_o,
    output reg[`ALU_BUS-1:0] alu_bus,
    output wire[7:0] alu_tag,
    input wire br    
);
    wire[6:0] opcode = inst_i[6:0];
    wire[2:0] fun3 = inst_i[14:12];
    wire[6:0] fun7 = inst_i[31:25];
    wire[4:0] rd = inst_i[11:7];
    wire[4:0] rs1 = inst_i[19:15];
    wire[4:0] rs2 = inst_i[24:20];
    wire[31:0] imm = {{20{inst_i[31]}}, inst_i[31:20]};
    wire[31:0] smm = {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
    wire[31:0] bmm = {{20{inst_i[31]}},inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
    wire[31:0] umm = {inst_i[31:12], 12'b0};
    wire[31:0] jmm = {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
    wire[7:0] lock1,lock2;
    wire[31:0] data1,data2;
    
    assign alu_tag = rob_tag;
    assign reg_rs1 = rs1;
    assign reg_rs2 = rs2;
    
    assign reg_tag = rob_tag;
    assign rob_check_rs1 = (reg1_tag_i == 0) ? 0:1;
    assign rob_check_rs2 = (reg2_tag_i == 0) ? 0:1;
    assign rob_tag1 = reg1_tag_i;
    assign rob_tag2 = reg2_tag_i;
    assign stallreq = (alu_busy == 0 && mul_busy == 0 && ls_busy == 0 && branch_busy == 0)? 0:1;
    assign lock1 = (reg1_tag_i == 0 || reg1_tag_i != 0 && rob_value1_enable) ? 0 : reg1_tag_i;
    assign data1 = (reg1_tag_i == 0) ? reg1_data_i : (reg1_tag_i != 0 && rob_value1_enable) ? rob_rs1 : 0;
    assign lock2 = (reg2_tag_i == 0 || reg2_tag_i != 0 && rob_value2_enable) ? 0 : reg2_tag_i;
    assign data2 = (reg2_tag_i == 0) ? reg2_data_i : (reg2_tag_i != 0 && rob_value2_enable) ? rob_rs2 : 0;
   
    always @(posedge clk)begin
            
        //$display("check,%b,%b",reg1_tag_i,lock1);
        if(rst || br)begin
            pc_o <= 0;
            reg_write <= 0;
            rob_write <= 0;
            alu_write <= 0;
          //  stallreq <= 0;
        end else begin
           // $display("busy:",alu_busy,mul_busy,ls_busy,branch_busy);
            reg_write <= 0;
            rob_write <= 0;
            alu_write <= 0;
            pc_o <= pc_i;
            reg_rd <= rd;
            if(!stall)begin;
          
            case(opcode)
                `INST_TYPE_R_M:begin
                    alu_write <= 1;
                    reg_write <= 1;
                    rob_write <= 1;
                    alu_bus <= {
                        opcode,
                        fun3,
                        fun7,
                        lock1,lock2,
                        data1,data2,
                        32'b0
                    };
                    rob_bus <= {
                        opcode,
                        pc_i,
                        rd
                    };
                if(fun7 == 7'b0 || fun7 == 7'b0100000)begin
                    alu_sel = 2'b00;
                end else begin
                    alu_sel = 2'b01;
                end
                end
                `INST_TYPE_I_M,`INST_TYPE_I_L:begin

                    alu_write <= 1;
                    reg_write <= 1;
                    rob_write <= 1;
                    alu_bus <= {
                        opcode,
                        fun3,
                        fun7,
                        lock1,8'b0,
                        data1,data2,
                        imm
                    };
                    rob_bus <= {
                        opcode,
                        pc_i,
                        rd
                    };

                if(opcode == `INST_TYPE_I_M)begin
                    alu_sel = 2'b00;
                end else if(opcode == `INST_TYPE_I_L)begin
                    alu_sel = 2'b10;
                end
                end
                `INST_TYPE_I_J:begin
                    alu_write <= 1;
                    reg_write <= 1;
                    rob_write <= 1;
                    alu_bus <= {
                        opcode,
                        fun3,
                        fun7,
                        lock1,8'b0,
                        data1,pc_i,
                        imm
                    };
                    rob_bus <= {
                        opcode,
                        pc_i,
                        rd
                    };
                    alu_sel <= 2'b11;
                end
                `INST_TYPE_S:begin
                    alu_write <= 1;
                    reg_write <= 0;
                    rob_write <= 1;
                    //$display("lock1:%d,lock2:%d",lock1,lock2);
                    alu_bus <= {
                        opcode,
                        fun3,
                        fun7,
                        lock1,lock2,
                        data1,data2,
                        smm
                    };
                    rob_bus <= {
                        opcode,
                        pc_i,
                        rd
                    };
                alu_sel = 2'b10;
                // $display("reg_tag,lock,data,rs1,imm %h,%h,%h,%h,",inst_i,reg1_tag_i,lock1,data1,rs1,imm);
                end
                `INST_TYPE_B:begin
                    alu_write <= 1;
                    reg_write <= 0;
                    rob_write <= 1;
                    alu_bus <= {
                        opcode,
                        fun3,
                        fun7,
                        lock1,lock2,
                        data1,data2,
                        bmm
                    };
                    rob_bus <= {
                        opcode,
                        pc_i,
                        rd
                    };
                alu_sel = 2'b11;

                end
                `INST_TYPE_AUIPC,`INST_TYPE_LUI:begin
                    alu_write <= 1;
                    reg_write <= 1;
                    rob_write <= 1;
                    alu_bus <= {
                        opcode,
                        fun3,
                        fun7,
                        lock1,8'b0,
                        pc_i,data2,
                        umm
                    };
                    rob_bus <= {
                        opcode,
                        pc_i,
                        rd
                    };
                alu_sel = 2'b00;
                end
                `INST_TYPE_J:begin
       
                    alu_write <= 1;
                    reg_write <= 1;
                    rob_write <= 1;
                    alu_bus <= {
                        opcode,
                        fun3,
                        fun7,
                        lock1,8'b0,
                        data1,pc_i,
                        jmm
                    };
                    rob_bus <= {
                        opcode,
                        jmm,
                        rd
                    };
                alu_sel = 2'b11;
                end
            endcase
            end
        end
    end
    
    always @(negedge clk)begin
        alu_write <= 0;
        rob_write <= 0;
        reg_write <= 0;
    end
endmodule