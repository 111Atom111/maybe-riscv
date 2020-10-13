module delay(
    input rst,
    input clk,
    
    input wire[31:0] pc_addr_i,
    input wire[31:0] id_addr_i,
    input wire br_i,
    input wire[31:0] br_addr_i,
    input wire[5:0] stall,
    
    output reg[31:0] d_pc_addr_i,
    output reg[31:0] d_id_addr_i,
    output reg d_br_i,
    output reg[31:0] d_br_addr_i
 );
    
    always @ (negedge clk)begin
       if(!stall[2])begin
            d_pc_addr_i <= pc_addr_i;
            d_id_addr_i <= id_addr_i;
            d_br_i <= br_i;
            d_br_addr_i <= br_addr_i;
       end
    end
endmodule
