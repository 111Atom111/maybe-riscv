`include "define.v"

module id_stage(
    input wire rst,
    
    //from if_id
    input wire[31:0] inst_i,
    input wire[31:0] pc_i,
    
    
    //from register
    input wire[31:0] reg1_data_i,
    input wire[31:0] reg2_data_i,
    input wire[31:0] csr_data_i,
    
    //forwarding
    //from ex
    input wire[6:0] ex_aluop,
    input wire ex_we,
    input wire[31:0] ex_reg_wdata,
    input wire[31:0] ex_reg_waddr,
    //from mem
    input wire mem_we,
    input wire[31:0] mem_reg_wdata,
    input wire[31:0] mem_reg_waddr,
    //from wb
    input wire wb_we,
    input wire[31:0] wb_reg_wdata,
    input wire[31:0] wb_reg_waddr,
    
    output reg[31:0] pc_o,
    output reg[31:0] inst_o,
    output reg[31:0] reg1_addr_o,
    output reg[31:0] reg2_addr_o,
    
    output reg[6:0] aluop,
    output reg[2:0] alusel_1,
    output reg[6:0] alusel_2,
    output reg[31:0] reg1_data_o,
    output reg[31:0] reg2_data_o,
    
    output reg[31:0] reg_waddr_o,
    output reg reg_we_o,
    output reg[31:0] csr_raddr_o,
    output reg csr_we_o,
    output reg[31:0] csr_data_o,
    output reg[31:0] csr_waddr_o,
    output reg[31:0] imm,
    output wire stallreq,
    output reg br,
    output reg[31:0] br_addr
);

    wire[6:0] opcode = inst_i[6:0];
    wire[2:0] fun3 = inst_i[14:12];
    wire[6:0] fun7 = inst_i[31:25];
   
    wire[11:0] I_imm = inst_i[31:20];
    wire[11:0] S_imm = {inst_i[31:25],inst_i[11:7]};
    wire[11:0] B_imm = {inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
    wire[19:0] U_imm = inst_i[31:12];  
    wire[31:0] rd = inst_i[11:7];
    wire[31:0] rs1 = inst_i[19:15];
    wire[31:0] rs2 = inst_i[24:20];
    
    reg stallreq_for_reg1_load;
    reg stallreq_for_reg2_load;
    
    assign stallreq = stallreq_for_reg1_load || stallreq_for_reg2_load;
    wire pre_is_load;
    assign prev_is_load = (ex_aluop == `INST_TYPE_I_L)  || 
                          (ex_aluop == `INST_TYPE_FLW) ;
                       
    
    `define SET_INST(_aluop,_alusel_1,_alusel_2,_reg1_addr,_reg2_addr,_reg_we,_reg_waddr,_csr_we,_csr_waddr,_imm)\
        aluop = _aluop;\
        alusel_1 = _alusel_1;\
        alusel_2 = _alusel_2;\
        reg1_addr_o = _reg1_addr;\
        reg2_addr_o = _reg2_addr;\
        reg_we_o = _reg_we;\
        reg_waddr_o = _reg_waddr;\
        csr_we_o = _csr_we;\
        csr_waddr_o = _csr_waddr;\
        imm = _imm;
        
    always @ (*)begin
    case(aluop)
        `INST_TYPE_B:begin
                    case(alusel_1)
                        `INST_BEQ:begin
                            if(reg1_data_o == reg2_data_o)begin
                                br = 1;
                                br_addr = pc_i +  {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                               // $display("why%h------reg_data1:%h----------reg2_data:%h",pc_i,reg1_data_o,reg2_data_o);
                            end else begin
                                br = 1;
                                br_addr = pc_i + 4'h4;
                            end
                         end
                          `INST_BNE:begin
                            if(reg1_data_o != reg2_data_o)begin                      
                                br = 1;
                                br_addr = pc_i +  {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};                        
                      
                            end else begin
                                br = 1;
                                br_addr = pc_i + 4'h4;
                            end
                         end
                          `INST_BLT:begin
                      
                            if(reg1_data_o < reg2_data_o)begin
                                br = 1;
                                br_addr = pc_i +  {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};    
                            end else begin
                                br = 1;
                                br_addr = pc_i + 4'h4;
                            end
                         end
                          `INST_BGE:begin
                            if(reg1_data_o >= reg2_data_o)begin
                                br = 1;
                                br_addr = pc_i +  {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                            end else begin
                                br = 1;
                                br_addr = pc_i + 4'h4;
                            end
                         end
                          `INST_BLTU:begin
                            if(reg1_data_o < reg2_data_o)begin
                                br = 1;
                                br_addr = pc_i +  {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                            end else begin
                                br = 1;
                                br_addr = pc_i + 4'h4;
                            end
                         end      
                          `INST_BGEU:begin
                            if(reg1_data_o == reg2_data_o)begin
                                br = 1;
                                br_addr = pc_i +  {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
                               
                            end else begin
                                br = 1;
                                br_addr = pc_i + 4'h4;
                            end
                         end    
                   endcase
               end
            `INST_TYPE_J:begin
                    br = 1;
                    br_addr = pc_i + {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
                      
                    
                end
                `INST_TYPE_I_J:begin
                    br = 1;
                    br_addr = (reg1_data_o + {{20{inst_i[31]}}, inst_i[31:20]}) & (32'hfffffffe);
                    
                end
           endcase
    end    
    
    always @ (*)begin 
        //$display("opcode:",opcode);
        //$display("fun7",fun7);
        if(rst)begin
            csr_raddr_o = 0;
            pc_o = 0;
            inst_o = 0;
            `SET_INST(0,0,0,rs1,rs2,0,0,0,0,0)
            br = 0;
            br_addr = 0;
        end else begin
            `SET_INST(0,0,0,0,0,0,0,0,0,0)
            pc_o = pc_i;
            inst_o = inst_i;
            br = 0;
            br_addr = 0;
            case(opcode)
                `INST_TYPE_R_M:begin
                    `SET_INST(opcode,fun3,fun7,rs1,rs2,1,rd,0,0,0)
                 end
                 `INST_TYPE_I_M,`INST_TYPE_I_L,`INST_TYPE_I_FENCE,`INST_TYPE_I_J,`INST_TYPE_FSW:begin
                    `SET_INST(opcode,fun3,0,rs1,0,1,rd,0,0,I_imm)
                   
                 end
                 `INST_TYPE_I_CSR_E:begin
                    case(fun3)
                        `INST_E:begin
                            `SET_INST(opcode,0,fun7,0,0,0,0,0,0,0)
                         end
                        default: begin
                            csr_raddr_o = {20'h0, inst_i[31:20]};
                            `SET_INST(opcode,fun3,0,rs1,0,1,rd,1,{20'h0, inst_i[31:20]},0)
                        end
                    endcase
                   end
                  `INST_TYPE_S,`INST_TYPE_FSW:begin
                    `SET_INST(opcode,fun3,0,rs1,rs2,0,0,0,0,S_imm)
                   end
                   `INST_TYPE_B:begin
                    `SET_INST(opcode,fun3,0,rs1,rs2,0,0,0,0,B_imm)
                    end
                    `INST_TYPE_LUI,`INST_TYPE_AUIPC:begin
                        `SET_INST(opcode,0,0,0,0,1,rd,0,0,0)
                     end  
                     `INST_TYPE_J:begin
                        `SET_INST(opcode,0,0,0,0,1,rd,0,0,0)
                     end
                     `INST_TYPE_F:begin
                        `SET_INST(opcode,0,fun7,rs1,rs2,1,rd,0,0,0)
                     end
                     default:begin
                       csr_raddr_o = 0;
                       `SET_INST(0,0,0,rs1,rs2,0,0,0,0,0)
                     end
                 endcase  
             end
         end 

         
         `define SET_DATA(rs,reg_data_o,reg_addr,reg_data_i,stallreq)\
            //$display("reg_data:",reg_data_o);\
            stallreq = 0;\
            if(rst)begin \
                reg_data_o = 0; \
            end else if((rs != 0) && prev_is_load && (ex_reg_waddr == reg_addr) )begin \
                stallreq = 1;\
            end else if((rs != 0) && ex_we && (ex_reg_waddr == reg_addr) && reg_addr != 0)begin \
                reg_data_o = ex_reg_wdata; \
            end else if((rs != 0)&& mem_we && (mem_reg_waddr == reg_addr) && reg_addr != 0)begin \
                reg_data_o = mem_reg_wdata; \
            end else if((rs != 0)&& wb_we && (wb_reg_waddr == reg_addr) && reg_addr != 0)begin \
                reg_data_o = wb_reg_wdata; \
            end else begin \
                reg_data_o = reg_data_i;\
            end  
        
        always @(*) begin
            `SET_DATA(rs1,reg1_data_o,reg1_addr_o,reg1_data_i,stallreq_for_reg1_load)
            
        end
        
        always @ (*) begin
          `SET_DATA(rs2,reg2_data_o,reg2_addr_o,reg2_data_i,stallreq_for_reg2_load)  
          
        end
         
endmodule