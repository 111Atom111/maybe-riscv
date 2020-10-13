`include "define.v"

module LSU(
    input wire clk,
    input wire rst,
    //decoder 
    input wire alu_enable,
    input wire[1:0] alu_sel,
    input wire[`ALU_BUS-1:0] alu_bus,
    input wire[7:0] alu_tag,
    output reg busy, 
    //CDB
    input wire[7:0] cdb_in_index,
    input wire[31:0] cdb_in_result,
    
    input wire grnt,
    output reg cdb_out_valid,
    output reg[7:0] cdb_out_index,
    output reg[31:0] cdb_out_result,
    output reg[31:0] cdb_out_addr,
    //check load
    output reg check_load_enable,
    output reg[31:0] check_load_addr,
    input wire can_load_enable, 
    //mem
    output reg[31:0] mem_addr_o,
    input wire[31:0] mem_data_i,
    input wire br
);
    reg[`ALU_BUS:0] station[3:0];
    reg[1:0] cur,tail,counter;
    reg[7:0] tag[3:0];
    reg[4:0] load_sel;
    reg valid_load;
    reg[7:0] cheat;
    integer k;
    initial begin
        cur = 0;
        tail = 0;
        counter = 0;
        valid_load = 0;
        cheat = 0;
        for(k=0;k<4;k=k+1)begin
            station[k][129] = 0;
        end
    end
    
    genvar i;
    generate for(i=0;i<4;i=i+1)
        begin : gfor
            always @(cdb_in_index || cdb_in_result)begin
            if(station[i][129]==1 && cdb_in_index != 0 && station[i][111:104] == cdb_in_index)begin
               
                station[i][111:104] = 0;
                station[i][95:64] = cdb_in_result;
            end
            if(station[i][129]==1 && cdb_in_index != 0 && station[i][103:96] == cdb_in_index)begin
                station[i][103:96] = 0;
                station[i][63:32] = cdb_in_result;
            end
            end
        end   
    endgenerate
    
    integer j;
    always @(*)begin
        for(j=0;j<4;j=j+1)begin
            if(station[j][129]==1 && station[j][111:104]==8'b0 && station[j][103:96]==8'b0)begin
                if(tag[j] < cheat || cheat == 0)begin
                    cur = j;
                    cheat = tag[j];
                end
            end
        end  
        
    end
    
    always @(station[cur] || alu_tag)begin
        if(station[cur][128:122] == `INST_TYPE_I_L && station[cur][111:104]==8'b0)begin
            check_load_enable = 1;
            check_load_addr = station[cur][31:0] + station[cur][95:64];
        end else begin
            check_load_enable = 0;
        end
    end
    
    always @(alu_tag)begin
         //decoder write
        if(alu_enable && !station[tail][129] && alu_sel == 2'b10)begin
          
            counter <= counter + 1;
            station[tail][128:0] <= alu_bus;
            station[tail][129] <= 1;
            tag[tail] <= alu_tag;
            tail <= (tail + 1) % 4;
        end
    end
    
    integer p;
    always @(posedge clk)begin
          $display("tag",tag[cur],grnt);
          cheat <= 0;
          if(br)begin
            cur <= 0;
            tail <= 0;
            valid_load <= 0;
            cdb_out_valid <= 0;
            cdb_out_result <= 0;
            cdb_out_addr <= 0;
            counter <= 0;
            mem_addr_o <= 0;
            for(p=0;p<4;p=p+1)begin
                station[p] <= 0;
            end
        end
        //commit
        else if(grnt && station[cur][129]==1 && station[cur][111:104]==8'b0 && station[cur][103:96]==8'b0)begin
          // $display("I am coming",can_load_enable);
//          if(tag[cur] == 44)begin
//            $display("");
//          end
            
            cdb_out_index <= tag[cur];
            case(station[cur][128:122])        
            `INST_TYPE_I_L:begin
                //$display("can_load_enable:%b",can_load_enable);
            if(can_load_enable)begin   
                valid_load <= 1;
            case(station[cur][121:119]) 
                       `INST_LB:begin
                            mem_addr_o <= station[cur][95:64] + station[cur][31:0];
                            load_sel <= 5'b00001;
                        end
                        `INST_LH:begin
                            mem_addr_o <= station[cur][95:64] + station[cur][31:0];
                            load_sel = 5'b00010;
                        end
                        `INST_LW:begin
                            mem_addr_o <= station[cur][95:64] + station[cur][31:0];
                            load_sel <= 5'b00100;
                            
                        end
                        `INST_LBU:begin
                            mem_addr_o <= station[cur][95:64] + station[cur][31:0];
                            load_sel <= 5'b01000;
                        end
                        `INST_LHU:begin
                            mem_addr_o <= station[cur][95:64] + station[cur][31:0];
                            load_sel <= 5'b10000;
                        end
                        default:begin
                            mem_addr_o <= 0;
                        end
                   
            endcase
            end else begin
                cdb_out_valid <= 0;
            end
            end
            `INST_TYPE_S:begin
                cdb_out_valid <= 1;
                cdb_out_addr <= station[cur][95:64] + station[cur][31:0];
                // $display("string %h  %h",station[cur][95:64], station[cur][31:0]);
                cdb_out_result <= station[cur][63:32];
                station[cur] <= {`ALU_BUS{1'b0}};
                counter <= counter - 1;
                mem_addr_o <= 0;
            end
        endcase 
        end else begin
            cdb_out_valid <= 0;
        end   
    end
    

    
    always @(*)begin
         if(counter == 1)begin
            busy <= 1;
        end else begin
            busy <= 0;
        end 
       
    end
    
    always @(mem_data_i)begin
        
         if(grnt && can_load_enable && station[cur][128:122] == `INST_TYPE_I_L &&!br )begin
            cdb_out_valid <= 1;
            case(load_sel)
                5'b00001:begin
                    case(mem_addr_o[1:0])
                           2'b00   : cdb_out_result <= {{24{mem_data_i[7]}}, mem_data_i[7:0]};
						   2'b01   : cdb_out_result <= {{24{mem_data_i[15]}}, mem_data_i[15:8]};
						   2'b10   : cdb_out_result <= {{24{mem_data_i[23]}}, mem_data_i[23:16]};
						   2'b11   : cdb_out_result <= {{24{mem_data_i[31]}}, mem_data_i[31:24]};                    
                    endcase
                end
                5'b00010:begin
                      case (mem_addr_o[1:0])
						      2'b00   : cdb_out_result <= {{16{mem_data_i[15]}}, mem_data_i[15:0]};
						      2'b10   : cdb_out_result <= {{16{mem_data_i[15]}}, mem_data_i[31:16]};
					  endcase
                end
                5'b00100: begin
                    cdb_out_result = mem_data_i;
                    if(tag[cur] == 46)begin
                                $display("mem-addr:%h",station[cur][95:64] + station[cur][31:0]);
                            end
                end
                5'b01000:begin
                    case (mem_addr_o[1:0])
						      2'b00   : cdb_out_result <= {{24{1'b0}}, mem_data_i[7:0]};
						      2'b01   : cdb_out_result <= {{24{1'b0}}, mem_data_i[15:8]};
						      2'b10   : cdb_out_result <= {{24{1'b0}}, mem_data_i[23:16]};
						      2'b11   : cdb_out_result <= {{24{1'b0}}, mem_data_i[31:24]};
					endcase 
                end
                5'b10000:begin
                      case (mem_addr_o[1:0])
						      2'b00   : cdb_out_result <= {{16{1'b0}}, mem_data_i[15:0]};
						      2'b10   : cdb_out_result <= {{16{1'b0}}, mem_data_i[31:16]};
					  endcase
                end
            endcase
        station[cur] <= {`ALU_BUS{1'b0}};
        counter <= counter - 1;
        valid_load <= 0;
        mem_addr_o <= 0;
        end	       
    end
        
endmodule  