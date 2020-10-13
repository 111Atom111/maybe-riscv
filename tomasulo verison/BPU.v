module BPU(
    input rst,
    
    input wire[31:0] pc_addr_i,
    input wire[31:0] rob_addr_i,
    input wire br_i,
    input wire[31:0] br_addr_i,
    
    output reg br_o,
    output reg pr, 
    output reg[31:0] pr_addr_o,
    output reg[31:0] br_addr_o
);
    
    reg[2:0] BPC[0:4095];
    reg[31:0] BPT[0:4095];
    wire[11:0] index_pc;
    assign index_pc = pc_addr_i[11:0];
    wire[11:0] index_id;
    assign index_id = rob_addr_i[11:0];
    
    
    integer i;
    initial begin
       for(i=0;i<4096;i=i+1)begin
           BPC[i][2] = 0;
       end
    end
     
    always @(*)begin
        if(rst)begin
            pr = 0;
            br_o = 0;
            pr_addr_o = 0;
            br_addr_o = 0;
        end else if(br_i)begin
            if(BPC[index_id][2])begin
            if(BPT[index_id] == 31'h30)begin
                $display();
            end
            if(BPT[index_id] == br_addr_i)begin
                case(BPC[index_id][1:0])
                   00: BPC[index_id][1:0] = 2'b01;
                   01: BPC[index_id][1:0] = 2'b10;
                   10: BPC[index_id][1:0] = 2'b11;
                   11: BPC[index_id][1:0] = 2'b11;
                endcase
                br_o = 0;
               
            end else begin
                case(BPC[index_id][1:0])
                   //00: BPT[index_id][2] = 0;
                   00: BPC[index_id][1:0] = 2'b00;
                   01: begin
                           BPC[index_id][1:0] = 2'b00;
                           BPC[index_id][2] = 0;
                       end
                   10: BPC[index_id][1:0] = 2'b01;
                   11: BPC[index_id][1:0] = 2'b11;
                endcase
                br_o = 1;
                br_addr_o = br_addr_i;
            end
            end else begin
                BPC[index_id] = 3'b110;
                BPT[index_id] = br_addr_i;
                br_o = 1;
                br_addr_o = br_addr_i;
       
            end
        end else begin
            br_o = 0;   
        end   
    end 
    
    always @(*)begin
        if(rst)begin
            pr = 0;
            pr_addr_o = 0;
        end else if(BPC[index_pc]==3'b111 ||  BPC[index_pc]==3'b110 )begin
            pr = 1;
            pr_addr_o = BPT[index_pc];     
        end else begin
            pr = 0;
            pr_addr_o = 0;
        end        
    end 
endmodule