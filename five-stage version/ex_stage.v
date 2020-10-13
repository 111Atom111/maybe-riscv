`include "define.v"

module ex_stage(
    input wire rst,
    
    input wire[31:0] pc_i,
    input wire[31:0] inst_i,
    input wire[6:0] aluop,
    input wire[2:0] alusel_1,
    input wire[6:0] alusel_2,
    input wire[31:0] reg1_data,
    input wire[31:0] reg2_data,
    input wire[31:0] csr_data,
    input wire reg_we,
    input wire csr_we,
    input wire[31:0] reg_waddr,
    input wire[31:0] csr_waddr,
    input wire[31:0] imm,
    
    //forwarding
    output wire[6:0] ex_aluop, //用于数据转发 和判断读写内存
    output wire[2:0] sel,
    output reg reg_we_o,
    output reg[31:0] reg_waddr_o,
    output reg[31:0] reg_data_o,
    output reg csr_we_o,
    output reg[31:0] csr_waddr_o,
    output reg[31:0] csr_data_o,
    output reg[31:0] mem_addr_o, //读写 内存地址
    output reg[31:0] mem_data_o, //写入内存的数据
    
    output reg stallreq,
   
    output reg pc_o,
    output reg inst_o,
    
    output reg we_cf
      
);
    assign ex_aluop = aluop;
    assign sel = alusel_1;
    wire[31:0] sign_extend_tmp;
    assign sign_extend_tmp =  {{20{inst_i[31]}}, inst_i[31:20]}; 
    wire[4:0] shift_bits;
    assign shift_bits = inst_i[24:20];
    wire[4:0] uimm;
    assign uimm = inst_i[19:15];
    
    reg[31:0] mul_op1;
    reg[31:0] mul_op2;
    wire[63:0] mul_temp;
    wire[63:0] mul_temp_invert;
    assign mul_temp = mul_op1 * mul_op2;
    assign mul_temp_invert = ~mul_temp + 1;
    
    always @ (*) begin
        if (rst) begin
            mul_op1 = 0;
            mul_op2 = 0;
        end else begin
            if ((aluop == `INST_TYPE_R_M)) begin
                case (alusel_1)
                    `INST_MUL, `INST_MULHU: begin
                        mul_op1 = reg1_data;
                        mul_op2 = reg2_data;
                       
                    end
                    `INST_MULHSU: begin
                        mul_op1 = (reg1_data[31] == 1'b1)? (~reg1_data + 1): reg1_data;
                        mul_op2 = reg2_data;
                    end
                    `INST_MULH: begin
                        mul_op1 = (reg1_data[31] == 1'b1)? (~reg1_data + 1): reg1_data;
                        mul_op2 = (reg2_data[31] == 1'b1)? (~reg2_data + 1): reg2_data;
                    end
                    default: begin
                        mul_op1 = reg1_data;
                        mul_op2 = reg2_data;
                    end
                endcase
            end else begin
                mul_op1 = reg1_data;
                mul_op2 = reg2_data;
            end
        end
    end
    
    always @ (*)begin
        if(rst)begin    
         
            reg_we_o = 0;
            reg_waddr_o = 0;
            reg_data_o = 0;
            csr_we_o = 0;
            csr_data_o = 0;
            csr_waddr_o = 0;
            mem_addr_o = 0;
            mem_data_o = 0;
            stallreq = 0;
            pc_o = 0;
            inst_o = 0;
            we_cf = 0;
        end else begin
            stallreq = 0;
            reg_we_o = reg_we;
            reg_waddr_o = reg_waddr;
            csr_we_o = csr_we;
            csr_waddr_o = csr_waddr;
            mem_addr_o = 0;
            pc_o = pc_i;
            inst_o = inst_i;
            we_cf = 0;
            case(aluop)
               
               `INST_TYPE_R_M:begin
                   
                    
                    if ((alusel_2 == 7'b0000000) || (alusel_2 == 7'b0100000)) begin
                 
                    case(alusel_1) 
                        `INST_ADD_SUB:begin
                            if(alusel_2 == 7'b0)begin
                                reg_data_o = reg1_data + reg2_data;
                            end else begin
                                reg_data_o = reg1_data - reg2_data;
                            end 
                             if(reg1_data[31] == reg2_data[31])begin
                                if(reg1_data[31] != reg_data_o)begin
                                    we_cf = 1;
                                end                                
                            end   
                        end
                        `INST_SLL:begin
                            reg_data_o = reg1_data << reg2_data[4:0];
                        end
                        `INST_SLT:begin
                            if(reg1_data  < reg2_data )begin
                                reg_data_o = 32'h00000001;
                            end else begin
                                reg_data_o = 32'b0;  
                            end
                        end
                        `INST_SLTU:begin
                            if(reg1_data  < reg2_data )begin
                                reg_data_o = 32'h00000001;
                            end else begin
                                reg_data_o = 32'b0;  
                            end
                        end
                        `INST_XOR:begin
                            reg_data_o = reg1_data ^ reg2_data;
                        end
                        `INST_SR:begin
                            if(alusel_2 == 7'b0)begin
                                reg_data_o = reg1_data >> reg2_data[4:0];
                            end else begin
                                reg_data_o = ({32{reg1_data[31]}} << (6'd32 - {1'b0, reg2_data[4:0]})) | (reg1_data >> reg2_data[4:0]);
                            end   
                        end
                        `INST_OR:begin
                            reg_data_o = reg1_data | reg2_data;
                        end 
                        `INST_AND:begin
                            reg_data_o = reg1_data & reg2_data;  
                        end 
                        default:begin
                            reg_data_o = 0;
                        end
                    endcase
                    end else if(alusel_2 == 7'b0000001)begin
                    case(alusel_1)
                       `INST_MUL:begin
                            reg_data_o = mul_temp[31:0];
                            
                        end
                        `INST_MULHU:begin
                            reg_data_o = mul_temp[63:32];
                            
                        end
                        `INST_MULH:begin
                           case ({reg1_data[31], reg2_data[31]})
                                    2'b00: begin
                                        reg_data_o = mul_temp[63:32];
                                    end
                                    2'b11: begin
                                        reg_data_o = mul_temp[63:32];
                                    end
                                    2'b10: begin
                                        reg_data_o = mul_temp_invert[63:32];
                                    end
                                    default: begin
                                        reg_data_o = mul_temp_invert[63:32];
                                    end
                            endcase
                        end
                        `INST_MULHSU:begin
                            if (reg1_data[31] == 1'b1) begin
                                    reg_data_o = mul_temp_invert[63:32];
                            end else begin
                                    reg_data_o = mul_temp[63:32];
                            end
                        end
                    endcase
                end
                end
                `INST_TYPE_I_M:begin
                    case(alusel_1)
                        `INST_ADDI:begin
                            reg_data_o = reg1_data + sign_extend_tmp;
                           // $display("ex_pc:%h----ex_isnt:%h---reg1_data_o:%h",pc_i,inst_i,id_reg_data_o);
                        end
                        `INST_SLTI:begin
                            if(reg1_data < sign_extend_tmp)begin
                                reg_data_o = 32'h00000001;
                            end else begin
                                reg_data_o = 32'h00000000;
                            end
                        end
                        `INST_SLTIU:begin
                            if(reg1_data < sign_extend_tmp)begin
                                reg_data_o = 32'h00000001;
                            end else begin
                                reg_data_o = 32'h00000000;
                            end
                        end
                        `INST_XORI:begin
                            reg_data_o = reg1_data ^ {{20{inst_i[31]}}, inst_i[31:20]};
                        end
                        `INST_ORI:begin
                            reg_data_o = reg1_data | {{20{inst_i[31]}}, inst_i[31:20]};
                        end
                        `INST_ANDI:begin
                            reg_data_o = reg1_data & {{20{inst_i[31]}}, inst_i[31:20]};
                        end
                        `INST_SLLI:begin
                            reg_data_o = reg1_data << shift_bits;
                        end
                        `INST_SRI:begin
                              if (inst_i[30] == 1'b1) begin
                                reg_data_o = ({32{reg1_data[31]}} << (6'd32 - {1'b0, shift_bits})) | (reg1_data >> shift_bits);
                            end else begin
                                reg_data_o = reg1_data >> shift_bits;
                            end
                        end
                        default:begin
                            reg_data_o = 0;
                        end
                    
                endcase
                end
             
                `INST_TYPE_I_L:begin
                    case(alusel_1)
                        `INST_LB:begin
                            mem_addr_o =  reg1_data + {{20{inst_i[31]}}, inst_i[31:20]};
                        end
                        `INST_LH:begin
                            mem_addr_o = reg1_data + {{20{inst_i[31]}}, inst_i[31:20]};
                        end
                        `INST_LW:begin
                            mem_addr_o = reg1_data + {{20{inst_i[31]}}, inst_i[31:20]};
                        end
                        `INST_LBU:begin
                            mem_addr_o = reg1_data + {{20{inst_i[31]}}, inst_i[31:20]};
                        end
                        `INST_LHU:begin
                            mem_addr_o = reg1_data + {{20{inst_i[31]}}, inst_i[31:20]};
                        end
                        default:begin
                            mem_addr_o = 0;
                        end
                    endcase
                end
                `INST_TYPE_I_CSR_E:begin
                    case(alusel_1)
                        `INST_CSRRW: begin
                            csr_data_o = reg1_data;
                            reg_data_o = csr_data;
                        end
                        `INST_CSRRS: begin
                            csr_data_o = reg1_data | csr_data;
                            reg_data_o = csr_data;
                        end
                        `INST_CSRRC: begin
                            csr_data_o = csr_data & (~reg1_data);
                            reg_data_o = csr_data;
                        end
                        `INST_CSRRWI: begin
                            csr_data_o = {27'h0, uimm};
                            reg_data_o = csr_data;
                        end
                        `INST_CSRRSI: begin
                            csr_data_o = {27'h0, uimm} | csr_data;
                            reg_data_o = csr_data;
                        end
                        `INST_CSRRCI: begin
                            csr_data_o = (~{27'h0, uimm}) & csr_data;
                            reg_data_o = csr_data;
                        end
                        default: begin
                           csr_data_o = 0;
                           reg_data_o = 0;
                        end
                    endcase
                end
               
                `INST_TYPE_LUI:begin
                    reg_data_o = {inst_i[31:12], 12'b0};     
                end    
                `INST_TYPE_AUIPC:begin
                    reg_data_o = {inst_i[31:12], 12'b0} + pc_i;
                end
                `INST_TYPE_S:begin
                    mem_addr_o = reg1_data + {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
                    mem_data_o = reg2_data;
                   
                end
                `INST_TYPE_J:begin
                    reg_data_o = pc_i + 4'h4; 
                end
                `INST_TYPE_I_J:begin
                    reg_data_o = pc_i + 4'h4;
                   
                end
             endcase     
         end                                                 
    end                        
endmodule