module if_stage(
    input rst,
    input br,
    //pc_reg
    input wire[31:0] pc_i,
    //inst_ram
    output reg[31:0] mem_addr_o,
    input wire[31:0] mem_data_i,
    //decoder
    output reg[31:0] pc_o,
    output reg[31:0] inst_o
);
    always @(*)begin
        if(rst || br)begin
            pc_o = 0;
            inst_o = 0;
  
        end else begin
            mem_addr_o = pc_i;
            pc_o = pc_i;
            inst_o = mem_data_i;
         
        end
    end
endmodule