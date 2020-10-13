module pc_reg(
    input wire clk,
    input wire rst,
    
    input wire[5:0] stall,
    input wire br,
    input wire[31:0] br_addr,
    input wire pr,
    input wire[31:0] pr_addr,
    
    output reg[31:0] pc_o
);
   
    reg[31:0] pc;
    initial begin
       // pc_o =65676;
       pc_o = 66752;
    end
	

	always @ (posedge clk) begin
		if (rst) begin
            pc_o <= 0;
        // Ìø×ª
        end else if (br && !stall[0]) begin
            pc_o <= br_addr;
        // Ô¤²â
        end else if(pr && !stall[0]) begin
            pc_o <= pr_addr;
        // ÔÝÍ£
        end else if (stall[0]) begin
            pc_o <= pc_o;
        // µØÖ·¼Ó4
        end else begin
            pc_o <= pc_o + 4'h4;
        end
   end
	

	
endmodule