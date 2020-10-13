module ex_mem(
    input wire clk,
    input wire rst,
    
    input wire[31:0] ex_reg_waddr,
    input wire ex_reg_we,
    input wire[31:0] ex_reg_data,
    input wire[31:0] ex_csr_waddr,
    input wire ex_csr_we,
    input wire[31:0] ex_csr_data,
    input wire[31:0] ex_mem_addr,
    input wire[6:0] ex_aluop,
    input wire[31:0] ex_mem_data,
    input wire[2:0] ex_sel,
    input wire[5:0] stall,
    output reg[2:0] mem_sel,
    output reg[31:0] mem_reg_waddr,
    output reg mem_reg_we,
    output reg[31:0] mem_reg_data,
    output reg[31:0] mem_csr_waddr,
    output reg mem_csr_we,
    output reg[31:0] mem_csr_data,
    output reg[31:0] mem_mem_addr,
    output reg[6:0] mem_aluop,
    output reg[31:0] mem_mem_data
);
    
    always @ (posedge clk)begin
        if(rst || (stall[3] && !stall[4]))begin
            mem_reg_waddr <= 0;
            mem_reg_we <= 0;
            mem_reg_data <= 0;
            mem_csr_waddr <= 0;
            mem_csr_we <= 0;
            mem_csr_data <= 0;
            mem_mem_addr <= 0;
            mem_aluop <= 0;
            mem_mem_data <= 0;
            mem_sel <= 0;
        end else if(!stall[3])begin
            mem_reg_waddr <= ex_reg_waddr;
            mem_reg_we <= ex_reg_we;
            mem_reg_data <= ex_reg_data;
            mem_csr_waddr <= ex_csr_waddr;
            mem_csr_we <= ex_csr_we;
            mem_csr_data <= ex_csr_data;
            mem_mem_addr <= ex_mem_addr;
            mem_aluop <= ex_aluop;
            mem_mem_data <= ex_mem_data;
            mem_sel <= ex_sel;
           
       end
   end 
endmodule