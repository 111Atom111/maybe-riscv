`include"define.v"

module mem_stage(
    input wire rst,
    
    input wire[31:0] reg_waddr_i,
    input wire reg_we_i,
    input wire[31:0] reg_wdata_i,
    input wire[31:0] csr_waddr_i,
    input wire csr_we_i,
    input wire[31:0] csr_wdata_i,
    input wire[31:0] mem_addr_i,
    input wire[6:0] aluop,
    input wire[31:0] mem_wdata_i,
    input wire[2:0] sel,
    input wire[31:0] mem_data_i,
     
    output reg[31:0] reg_waddr_o,
    output reg reg_we_o,
    output reg[31:0] reg_wdata_o,
    output reg[31:0] csr_waddr_o,
    output reg csr_we_o,
    output reg[31:0] csr_wdata_o,
    output reg mem_we,
    output reg[31:0] mem_addr_o, //读写地址
    output reg[31:0] mem_data_o  //写入内存的数据
);

   
    `define SET_MEM(i_mem_we,i_mem_addr_o,i_mem_data_o)\
        mem_we = i_mem_we;\
        mem_addr_o = i_mem_addr_o;\
        mem_data_o = i_mem_data_o;
    
    always @ (*)begin
        if(rst)begin
            `SET_MEM(0,0,0)
            reg_waddr_o = 0;
            reg_we_o = 0;
            reg_wdata_o = 0;
            csr_we_o = 0;
            csr_waddr_o = 0;
            csr_wdata_o = 0;
        end else begin
            reg_waddr_o = reg_waddr_i;
            reg_we_o = reg_we_i;
            reg_wdata_o = reg_wdata_i;
            csr_we_o = csr_we_i;
            csr_waddr_o = csr_waddr_i;
            csr_wdata_o = csr_wdata_i;
            `SET_MEM(0,0,0)
           
            case(aluop)
                `INST_TYPE_I_L:begin
                    `SET_MEM(0,{mem_addr_i[31:2], 2'b0}, 0)
                    case(sel)
                        `INST_LB:begin
                            case (mem_addr_i[1:0])
						      2'b00   : reg_wdata_o = {{24{mem_data_i[7]}}, mem_data_i[7:0]};
						      2'b01   : reg_wdata_o = {{24{mem_data_i[15]}}, mem_data_i[15:8]};
						      2'b10   : reg_wdata_o = {{24{mem_data_i[23]}}, mem_data_i[23:16]};
						      2'b11   : reg_wdata_o = {{24{mem_data_i[31]}}, mem_data_i[31:24]};
						      default : reg_wdata_o = 0;
					        endcase // mem_addr_i[1:0]
					    end
					    `INST_LH:begin
					       case (mem_addr_i[1:0])
						      2'b00   : reg_wdata_o = {{16{mem_data_i[15]}}, mem_data_i[15:0]};
						      2'b10   : reg_wdata_o = {{16{mem_data_i[15]}}, mem_data_i[31:16]};
						      default : reg_wdata_o = 0;
					       endcase // mem_addr_i[1:0]
				        end
				        `INST_LW:begin
				            case (mem_addr_i[1:0])
						      2'b00   : begin reg_wdata_o = mem_data_i;   
						     
               
           
            end         
						      default : reg_wdata_o = 0;
						     
					          endcase // mem_addr_i[1:0]
				         end
				         `INST_LBU:begin
				            case (mem_addr_i[1:0])
						      2'b00   : reg_wdata_o = {{24{1'b0}}, mem_data_i[7:0]};
						      2'b01   : reg_wdata_o = {{24{1'b0}}, mem_data_i[15:8]};
						      2'b10   : reg_wdata_o = {{24{1'b0}}, mem_data_i[23:16]};
						      2'b11   : reg_wdata_o = {{24{1'b0}}, mem_data_i[31:24]};
						      default : reg_wdata_o = 0;
					       endcase // mem_addr_i[1:0]
				        end
				        `INST_LHU:begin
				            case (mem_addr_i[1:0])
						      2'b00   : reg_wdata_o = {{16{1'b0}}, mem_data_i[15:0]};
						      2'b10   : reg_wdata_o = {{16{1'b0}}, mem_data_i[31:16]};
						      default : reg_wdata_o = 0;
					       endcase // mem_addr_i[1:0]
				        end
				        default : begin
					       reg_wdata_o = reg_wdata_i;
				        end
			         endcase     
                end
                `INST_TYPE_S:begin
                    mem_we = 1;
                    mem_addr_o = mem_addr_i;
                    case(sel)
                        `INST_SB:begin
                            case(mem_addr_i[1:0])
                                2'b00: begin
                                    mem_data_o = {mem_data_i[31:8], mem_wdata_i[7:0]};
                                end
                                2'b01: begin
                                    mem_data_o = {mem_data_i[31:16], mem_wdata_i[7:0], mem_data_i[7:0]};
                                end
                                2'b10: begin
                                    mem_data_o = {mem_data_i[31:24], mem_wdata_i[7:0], mem_data_i[15:0]};
                                end
                                default: begin
                                    mem_data_o = {mem_wdata_i[7:0], mem_data_i[23:0]};
                                end  
                            endcase
                        end
                        `INST_SH:begin
                            if(mem_addr_i[1:0] == 2'b00)begin
                                mem_data_o = {mem_data_i[31:16], mem_wdata_i[15:0]};
                            end else begin
                                mem_data_o = {mem_wdata_i[15:0], mem_data_i[15:0]};
                            end
                        end
                        `INST_SW:begin
                            mem_data_o = mem_wdata_i;
                           
                        end
                    endcase
                end
            endcase
        end
     end
        
     
endmodule