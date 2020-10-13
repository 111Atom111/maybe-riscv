module CDB(
    input wire clk,
    input wire rst,
    input wire br,
    
    input wire alu_req,mul_req,ls_req,bra_req,
    output reg alu_grnt,mul_grnt,ls_grnt,bra_grnt,
    input wire[7:0] alu_in_index,mul_in_index,ls_in_index,bra_in_index,
    input wire[31:0] alu_in_data,mul_in_data,ls_in_data,bra_in_data,ls_in_addr,
    output reg[7:0] rob_out_index,
    output reg[31:0] rob_out_data,
    output reg[31:0] rob_out_addr,
    output wire stallreq
);
    reg[38:0] alu_cache;
    reg[38:0] mul_cache;
    reg[70:0] ls_cache;
    reg[38:0] bra_cache;
    reg alu_have,mul_have,ls_have,bra_have;
//    assign alu_have = alu_req;
//    assign mul_have = mul_req;
//    assign ls_have = ls_req;
//    assign bra_have = bra_req;
    wire all_have;
    assign all_have = alu_have | mul_have | ls_have | bra_have;
    assign stallreq = all_have;
    initial begin
        alu_grnt <= 1;
        mul_grnt <= 1;
        ls_grnt <= 1;
        bra_grnt <= 1;
    end
    
     always @(*)begin
        if(alu_req)begin
            alu_cache = {alu_in_index,alu_in_data};
            alu_have = 1;
        end
        if(mul_req)begin
            mul_cache = {mul_in_index,mul_in_data};
            mul_have = 1;
            
        end
        if(ls_req)begin
            ls_cache = {ls_in_index,ls_in_data,ls_in_addr};  
            ls_have = 1; 
        end
        if(bra_req)begin
            bra_cache = {bra_in_index,bra_in_data};
            bra_have = 1;
           
        end
        
        if(all_have)begin
            alu_grnt <= 0;
            mul_grnt <= 0;
            ls_grnt <= 0;
            bra_grnt <= 0;
           
        end else begin
            alu_grnt <= 1;
            mul_grnt <= 1;
            ls_grnt <= 1;
            bra_grnt <= 1;
        end
    end
    
    always @(posedge clk)begin
        if(br)begin
        rob_out_index <= 0;
        rob_out_data <= 0;
        rob_out_addr <= 0; 
        alu_cache <= 0;
        mul_cache <= 0;
        ls_cache <= 0;
        bra_cache <= 0;
        alu_have <= 0;
        mul_have <= 0;
        ls_have <= 0;
        bra_have <= 0;    
        end  
    end
    
    always @(negedge clk )begin  
    if(alu_have)begin
        rob_out_index <= alu_cache[38:32];
        rob_out_data <= alu_cache[31:0];
        alu_have <= 0;
    end else if(mul_have)begin
        rob_out_index <= mul_cache[38:32];
        rob_out_data <= mul_cache[31:0];
        mul_have <= 0;
    end else if(ls_have)begin
        rob_out_index <= ls_cache[70:64];
        rob_out_data <= ls_cache[63:32];
        rob_out_addr <= ls_cache[31:0];
        ls_have <= 0;
    end else if(bra_have)begin
        rob_out_index <= bra_cache[38:32];
        rob_out_data <= bra_cache[31:0]; 
        bra_have <= 0;
    end    
    end
endmodule 