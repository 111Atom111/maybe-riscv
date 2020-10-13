module if_stage(
    input wire rst,
    
    input wire[31:0] pc_i,
    input wire br,
    input wire [31:0] mem_data_i,
    
    output reg[31:0] pc_o,
    output reg[31:0] inst_o,
    output reg[31:0] mem_addr_o

);
    
    always @ (*) begin 
        if(rst )begin
            pc_o = 0;
            inst_o = 0;
            mem_addr_o = 0;
        end else begin
            mem_addr_o = pc_i;
            pc_o = pc_i;
            inst_o = mem_data_i;
        end
    end            
endmodule