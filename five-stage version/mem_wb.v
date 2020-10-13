`include "define.v"

module mem_wb(
    input wire clk,
    input wire rst,
    
    input wire[31:0] mem_reg_waddr,
    input wire mem_reg_we,
    input wire[31:0] mem_reg_wdata,
    input wire[31:0] mem_csr_waddr,
    input wire mem_csr_we,
    input wire[31:0] mem_csr_wdata,
    
    input wire[5:0] stall,
    
    output reg[31:0] wb_reg_waddr,
    output reg wb_reg_we,
    output reg[31:0] wb_reg_wdata,
    output reg[31:0] wb_csr_waddr,
    output reg wb_csr_we,
    output reg[31:0] wb_csr_data
);
    
    always @ (posedge clk)begin
        if(rst || (stall[4] && !stall[5]))begin
            wb_reg_waddr <= 0;
			wb_reg_we <= 0;
			wb_reg_wdata <= 0;
			wb_csr_waddr <= 0;
			wb_csr_we <= 0;
			wb_csr_data <= 0;
			
        end else if(!stall[4])begin
            wb_reg_waddr <= mem_reg_waddr;
			wb_reg_we <= mem_reg_we;
			wb_reg_wdata <= mem_reg_wdata;
			wb_csr_waddr <= mem_csr_waddr;
			wb_csr_we <= mem_csr_we;
			wb_csr_data <= mem_csr_wdata;
			//$display("result_wb",wb_reg_wdata);
		end
    end
endmodule