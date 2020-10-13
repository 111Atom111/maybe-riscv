 `include "define.v"
 
module id_ex(
    input wire clk,
    input wire rst,
    
    input wire[31:0] id_pc,
    input wire[31:0] id_inst,
    input wire[6:0] id_aluop,
    input wire[2:0] id_alusel_1,
    input wire[6:0] id_alusel_2,
    input wire[31:0] id_reg1_data,
    input wire[31:0] id_reg2_data,
    input wire[31:0] id_csr_data,
    input wire id_reg_we,
    input wire id_csr_we,
    input wire[31:0] id_reg_waddr,
    input wire[31:0] id_csr_waddr,
    input wire[31:0] id_imm,
    input wire[5:0] stall,

    
    output reg[31:0] ex_pc,
    output reg[31:0] ex_inst,
    output reg[6:0] ex_aluop,
    output reg[2:0] ex_alusel_1,
    output reg[6:0] ex_alusel_2,
    output reg[31:0] ex_reg1_data,
    output reg[31:0] ex_reg2_data,
    output reg[31:0] ex_csr_data,
    output reg ex_reg_we,
    output reg ex_csr_we,
    output reg[31:0] ex_reg_waddr,
    output reg[31:0] ex_csr_waddr,
    output reg[31:0] ex_imm
 );
 
    always @ (posedge clk)begin
        if(rst  || (stall[2] && !stall[3]))begin
            ex_pc <= 0;
            ex_inst <= 0;
            ex_aluop <= 0;
            ex_alusel_1 <= 0;
            ex_alusel_2 <= 0;
            ex_reg1_data <= 0;
            ex_reg2_data <= 0;
            ex_csr_data <= 0;
            ex_reg_we <= 0;
            ex_csr_we <= 0;
            ex_reg_waddr <= 0;
            ex_csr_waddr <= 0;
            ex_imm <= 0;
            
        end else if(!stall[2])begin
            ex_pc <= id_pc;
            ex_inst <= id_inst;
            ex_aluop <= id_aluop;
            ex_alusel_1 <= id_alusel_1;
            ex_alusel_2 <= id_alusel_2;
            ex_reg1_data <= id_reg1_data;
            ex_reg2_data <= id_reg2_data;
            ex_csr_data <= id_csr_data;
            ex_reg_we <= id_reg_we;
            ex_csr_we <= id_csr_we;
            ex_reg_waddr <= id_reg_waddr;
            ex_csr_waddr <= id_csr_waddr;
            ex_imm <= id_imm;
            if(id_aluop == `INST_TYPE_B && id_alusel_1 == `INST_BNE)begin
                $display("pc:%h---inst:%h---1:%h---2:%h",id_pc,id_inst,id_reg1_data,id_reg2_data);
            end
        end
    end
endmodule