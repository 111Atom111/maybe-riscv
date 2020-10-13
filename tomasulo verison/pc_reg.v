module pc_reg(
    input wire clk,
    input wire rst,
    input wire stall,
    
    input wire br,
    input wire[31:0] br_addr,
    //BPU
    input wire pr,
    input wire[31:0] pr_addr,
    //if_stage && BPU
    output reg[31:0] pc_o
    
);
    initial begin
        pc_o = 256;
    end
    always @(posedge clk)begin
        if(rst)begin
            pc_o <= 0;
        end else if(br && !stall)begin
            pc_o <= br_addr;
           
        end else if(pr && !stall)begin
            pc_o <= pr_addr;
        end else if(!stall)begin
            pc_o <= pc_o + 4'h4;
    
        end
    end
    
endmodule