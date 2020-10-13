`include "define.v"

module ROB(
    input wire clk,
    input rst,
    
    //decoder
    input wire check1,check2,
    input wire[7:0] check_entry1,check_entry2,
    output reg check_value_enable1,check_value_enable2,
    output reg[31:0] check_value1,check_value2,
    input wire rob_write,
    input wire[`ROB_BUS-1:0] rob_bus,
    output reg[7:0] tag,  
    //regs
    output reg reg_write,
    output reg[4:0] reg_waddr,
    output reg[31:0] reg_data,
    output reg[7:0] reg_tag,
    //data_ram
    output reg mem_write,
    output reg[31:0] mem_addr,
    output reg[31:0] mem_data_o,
    //CDB
    input wire[7:0] cdb_in_entry,
    input wire[31:0] cdb_in_value,
    input wire[31:0] cdb_in_addr,
    //BPU
    input wire pr_wrong,
    input wire[7:0] br_tag,
    output reg br,
    output reg[31:0] pc,
    output reg[31:0] br_addr,
    output reg[7:0] br_lock,
    //asdffaf adfasdfa gfadfa
    output reg[31:0] address,
    input wire[31:0] mem_data_i,
    //check_load
    input wire check_load_enable,
    input wire[31:0] check_load_addr,
    output reg can_load_enable
);
    reg[`ROB_BUS+1:0] rob[255:0];
    reg[7:0] head,tail,counter;
    reg[31:0] mem_wdata_i;
    reg[2:0] sel;
    
    integer k;
    initial begin
        head = 1;
        tail = 1;
        counter = 0;
        for(k=0;k<256;k=k+1)begin
            rob[k][77] = 0;
            rob[k][76] = 0;
        end
    end
    integer i;
    always @(*)begin
        check_value_enable1 = 0;
        check_value_enable2 = 0;
        can_load_enable = 0;
        if(check1)begin
           // $display("I am checking",check_entry1);
            if(cdb_in_entry == check_entry1)begin
                check_value1 = cdb_in_value;
                check_value_enable1 = 1;
            end else begin
                check_value_enable1 = rob[check_entry1][76];
                check_value1 = rob[check_entry1][75:44];
            end
        end
        if(check2)begin
            if(cdb_in_entry == check_entry2)begin
                check_value2 = cdb_in_value;
                check_value_enable2 = 1;
            end else begin
                check_value_enable2 = rob[check_entry2][76];
                check_value2 = rob[check_entry2][75:44];
            end
        end

         if(check_load_enable)begin
            can_load_enable = 1;
            for(i=head;i<256;)begin
                if(i==tail)begin
                    i = 256;
                end else begin
                    if(rob[i][43:37] == `INST_TYPE_S && rob[i][36:5] == check_load_addr)begin
                        //$display("you are great");
                        can_load_enable = 0;
                    end
                    i = (i + 1) % 255;
                    if(i == 0)begin
                        i = 1;
                    end
                end
            end
         end         
    end
    
    always @(cdb_in_entry || cdb_in_value)begin
                //cdb writes rob
        if(cdb_in_entry != 0 && !rob[cdb_in_entry][76])begin
        if(cdb_in_entry == 24)begin
            $display("value:%h",cdb_in_value);
        end
               
                rob[cdb_in_entry][76] <= 1;
                rob[cdb_in_entry][75:44] <= cdb_in_value;
                if(rob[cdb_in_entry][43:37] == `INST_TYPE_S )begin
                    rob[cdb_in_entry][36:5] <= cdb_in_addr;  
                    //$display("address:h",cdn_in_addr);                      
                end
         end
    end
    //decoder writes rob
     always @(rob_write)begin
          if(rob_write && counter < 256 && !rob[tail][77])begin
                    counter <= counter + 1;
                    rob[tail][75:0] <= rob_bus;
                    rob[tail][77] <= 1;
                    tag <= tail; 
                    tail <= (tail + 1) % 256;
         end else begin
                    tag <= 0;
         end
    end
    
    integer p;
    always @(posedge clk)begin
        if(rst)begin
        end else begin
            br <= 0;
            reg_write <= 0;
            mem_write <= 0;
            if(pr_wrong)begin
                tail <= head;
                tag <=0 ;
                for(p=0;p<256;p=p+1)begin
                    rob[p][77] <= 0;
                    rob[p][76] <= 0;
                end
            end else begin
                //rob commit
                if(rob[head][77] == 1 && rob[head][76] == 1)begin
                    $display("I am committing--%d---%h",head,rob[head][75:44]);
             
                    case(rob[head][43:37])
                        `INST_TYPE_B:begin
                            br <= 1;
                            br_addr <= rob[head][36:5] + rob[head][75:44];
                            pc <= rob[head][36:5];
                           
                        end
                        `INST_TYPE_I_J:begin
                            br <= 1;
                            br_addr <= rob[head][75:44];
                            pc <= rob[head][36:5];
//                            reg_write <= 1;
//                            reg_waddr <= rob[head][4:0];
//                            reg_data <= rob[head][36:5] + 4'h4;
//                            reg_tag <= head;
                           // $display("br_addr:%h,pc:%h",rob[head][75:44],rob[head][36:5]);
                           // $display("data:%h,imm:%h",rob[head][75:44],rob[head][36:5]);
                            //$display("br_addr:%h",(rob[head][75:44] + {{20{rob[head][36]}}, rob[head][16:5]}) & (32'hfffffffe));
                        end
                        `INST_TYPE_J:begin
                            br <= 1;
                            br_addr <= rob[head][75:44] + rob[head][36:5] - 4'h4;
                            pc <= rob[head][75:44] - 4'h4;
                            reg_write <= 1;
                            reg_waddr <= rob[head][4:0];
                            reg_data <= rob[head][75:44];
                            reg_tag <= head;
                            //$display("jal:%h",rob[head][36:5]);
                        end
                        `INST_TYPE_S:begin
                            mem_write <= 1;
                            mem_addr <= rob[head][36:5];
                            sel <= 010;
                         case(sel)
                        `INST_SB:begin
                            case(mem_addr[1:0])
                                2'b00: begin
                                    mem_data_o <= {mem_data_i[31:8], rob[head][51:44]};
                                end
                                2'b01: begin
                                    mem_data_o <= {mem_data_i[31:16], rob[head][51:44], mem_data_i[7:0]};
                                end
                                2'b10: begin
                                    mem_data_o <= {mem_data_i[31:24], rob[head][51:44], mem_data_i[15:0]};
                                end
                                default: begin
                                    mem_data_o <= {rob[head][51:44], mem_data_i[23:0]};
                                end  
                            endcase
                        end
                        `INST_SH:begin
                            if(mem_addr[1:0] == 2'b00)begin
                                mem_data_o <= {mem_data_i[31:16], rob[head][59:44]};
                            end else begin
                                mem_data_o <= {rob[head][59:44], mem_data_i[15:0]};
                            end
                        end
                        `INST_SW:begin
                            mem_data_o <= rob[head][75:44];
                        end
                    endcase
                        end    
                        default:begin
                            reg_write <= 1;
                            reg_waddr <= rob[head][4:0];
                            reg_data <= rob[head][75:44];
                            reg_tag <= head;
                        end
                    endcase
                head = (head + 1) % 256;
                end
            end
        end
    end
    
    always @(*)begin
        if(head == 0)begin
            head = head + 1;
        end 
        if(tail == 0)begin
            tail = tail + 1;
        end
        if(rob[head][43:37] == `INST_TYPE_S)begin
            address <= rob[head][36:5];
        end
    end
endmodule