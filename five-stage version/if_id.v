`include "define.v"
module if_id(
    input wire clk,
    input wire rst,
    
    input wire[31:0] if_pc,
    input wire[31:0] if_inst,
    input wire[5:0] stall,
    input wire br,
    
    output reg[31:0] id_pc,
    output reg[31:0] id_inst
);
   
    always @ (posedge clk)begin
        if(rst || br || (stall[1] && !stall[2]))begin
            id_pc <= 0;
            id_inst <= 0;
        end else if(!stall[1])begin
            id_pc <= if_pc;
            id_inst <= if_inst;
            if(if_pc== 32'h000102f0)begin
                $display("---pc:%h---inst:%h",if_pc,if_inst);
            end
        end
    end
endmodule