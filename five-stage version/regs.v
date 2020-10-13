module regs(
    input wire clk,
    input wire rst,
    
    input wire we_i,
    input wire[31:0] waddr_i,
    input wire[31:0] wdata_i,
    input wire[31:0] raddr1_i,
    input wire[31:0] raddr2_i,
    
   
    output reg[31:0] rdata1_o,
    output reg[31:0] rdata2_o,    
    
    output wire[31:0] reg_ra,
    output wire[31:0] reg_sp,
    output wire[31:0] reg_gp,
    output wire[31:0] reg_t0,
    output wire[31:0] reg_t1,
    output wire[31:0] reg_s0,
    output wire[31:0] reg_a0,
    output wire[31:0] reg_a1,
    output wire[31:0] reg_a2,
    output wire[31:0] reg_a3,
    output wire[31:0] reg_a4,
    output wire[31:0] reg_a5
); 
    
    reg[31:0] regs[0:31];
    assign reg_ra = regs[1];
    assign reg_sp = regs[2];
    assign reg_gp = regs[3];
    assign reg_t0 = regs[5];
    assign reg_t1 = regs[6];
    assign reg_s0 = regs[8];
    assign reg_a0 = regs[10];
    assign reg_a1 = regs[11];
    assign reg_a2 = regs[12];
    assign reg_a3 = regs[13];
    assign reg_a4 = regs[14];
    assign reg_a5 = regs[15];
    
    integer i;
    initial begin
        for(i=0;i<32;i=i+1)begin
            regs[i] = 0;
        end
        regs[2] = 32'h10000;
        regs[3] = 32'h13418;
    end
    
    always @ (posedge clk)begin
        if(!rst)begin
           //$display("result_reg",regs[3]);
           if(we_i && waddr_i != 0 )begin 
                regs[waddr_i] <= wdata_i;
           end
        end
    end
    
    //read register1
    always @ (*)begin
     
        if(rst)begin
            rdata1_o = 0;
        
        end else begin
            rdata1_o = regs[raddr1_i];
        end
     end
     
         //read register2
    always @ (*)begin
        if(rst)begin
            rdata2_o = 0;
      
        end else begin
            rdata2_o = regs[raddr2_i];
        end
     end
endmodule