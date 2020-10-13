module regs(
    input clk,
    input rst,
    //ROB
    input wire ROB_we,
    input wire[4:0] reg_addr,
    input wire[31:0] reg_data,
    input wire[7:0] reg_tag,
    //decoder read
    input wire[4:0] reg1_raddr,reg2_raddr,
    output reg[7:0] lock1,lock2,
    output reg[31:0] reg1_data,reg2_data,
    //decoder write
    input wire reg_we,
    input wire[4:0] reg_waddr,
    input wire[7:0] reg_wtag,
    input wire br,
    
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
    output wire[31:0] reg_a5,
    output wire[7:0] lock_a5
);
   
    reg[7:0] lock[31:0];
    reg[31:0] data[31:0];
    
    assign reg_ra = data[1];
    assign reg_sp = data[2];
    assign reg_gp = data[3];
    assign reg_t0 = data[5];
    assign reg_t1 = data[6];
    assign reg_s0 = data[8];
    assign reg_a0 = data[10];
    assign reg_a1 = data[11];
    assign reg_a2 = data[12];
    assign reg_a3 = data[13];
    assign reg_a4 = data[14];
    assign reg_a5 = data[15]; 
    assign lock_a5 = lock[15];
    
    integer i;
    initial begin
        for(i=0;i<32;i=i+1)begin
            data[i] = 0;
            lock[i] = 0;
        end
        data[2] = 32'h1000;
     //   data[3] = 32'h13418;
    end
    
    integer p;
    always @(posedge clk)begin
        if(br)begin
            for(p=0;p<32;p=p+1)begin
                lock[p] <= 0;
            end  
        end
        if(ROB_we && reg_addr != 0  )begin
            data[reg_addr] <= reg_data;
            if(reg_tag == lock[reg_addr])begin
                lock[reg_addr] <= 0;
            end
        end
    end
    
    always @(reg_wtag || reg_waddr)begin
        if(reg_we && reg_waddr != 0)begin
            lock[reg_waddr] <= reg_wtag;       
        end
    end
    
    always @(*)begin
        if(reg1_raddr == 0)begin
            reg1_data <= 0;
            lock1 <= 0;
        end else if(ROB_we && reg_addr == reg1_raddr && reg_tag == lock[reg1_raddr])begin
            reg1_data <= reg_data;
            lock1 <= 0;
        end else begin
            lock1 <= lock[reg1_raddr];
            reg1_data <= data[reg1_raddr];
        end
        
        if(reg2_raddr == 0)begin
            reg2_data <= 0;
            lock2 <= 0;
        end else if(ROB_we && reg_addr == reg2_raddr && reg_tag == lock[reg2_raddr])begin
            reg2_data <= reg_data;
            lock2 <= 0;
        end else begin
            lock2 <= lock[reg2_raddr];
            reg2_data <= data[reg2_raddr];
        end
    end
endmodule