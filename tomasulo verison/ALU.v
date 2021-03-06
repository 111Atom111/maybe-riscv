`include "define.v"

module ALU(
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
    input wire br
);
    reg[`ALU_BUS:0] station[3:0];
    reg[1:0] cur,tail,counter;
    reg[7:0] tag[3:0];
    
    integer k;
    initial begin
        cur = 0;
        tail = 0;
        counter = 0;
        for(k=0;k<4;k=k+1)begin
            station[k][129] = 0;
        end
    end
    
    
    genvar i;
    generate for(i=0;i<4;i=i+1)
        begin : gfor
            always @(station[i][129] || cdb_in_index)begin
            
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
            if(station[cur][129]==1 && station[cur][111:104]==8'b0 && station[cur][103:96]==8'b0)begin
                j = 4;
            end else begin
                cur = (cur + 1) % 4;
            end
        end 
         if(counter == 2'b11)begin
            busy <= 1;
        end else begin
            busy <= 0;
        end       
    end
    
    always @(alu_tag )begin
         //decoder write
        if(alu_enable && !station[tail][129] && alu_sel == 2'b00)begin
            counter <= counter + 1;
            station[tail][128:0] <= alu_bus;
            station[tail][129] <= 1;
            tag[tail][7:0] <= alu_tag;
            tail <= (tail + 1) % 4;
            
        end
    end
    
    integer p;
    always @(posedge clk)begin
         if(br)begin
            cur <= 0;
            tail <= 0;
            cdb_out_valid <= 0;
            counter <= 0;
            cdb_out_result <= 0;
            for(p=0;p<4;p=p+1)begin
                station[p] <= 0;
            end
        end
        else if(grnt && station[cur][129]==1 && station[cur][111:104]==8'b0 && station[cur][103:96]==8'b0)begin
            cdb_out_valid <= 1;
            cdb_out_index <= tag[cur];
            
            case(station[cur][128:122])
            `INST_TYPE_R_M:begin
            case(station[cur][121:119])
             `INST_ADD_SUB:begin  
                            
                            if(station[cur][118:112] == 7'b0)begin
                                cdb_out_result = station[cur][95:64] + station[cur][63:32];
                            end else begin
                                cdb_out_result = station[cur][95:64] - station[cur][63:32];
                            end   
                        end
                        `INST_SLL:begin
                            cdb_out_result = station[cur][95:64] << station[cur][36:32];
                        end
                        `INST_SLT:begin
                            if(station[cur][95:64]  < station[cur][63:32] )begin
                                cdb_out_result = 32'h00000001;
                            end else begin
                                cdb_out_result = 32'b0;  
                            end
                        end
                        `INST_SLTU:begin
                            if(station[cur][95:64]  < station[cur][63:32] )begin
                                cdb_out_result = 32'h00000001;
                            end else begin
                                cdb_out_result = 32'b0;  
                            end
                        end
                        `INST_XOR:begin
                            cdb_out_result = station[cur][95:64] ^ station[cur][63:32];
                        end
                        `INST_SR:begin
                            if(station[cur][118:112] == 7'b0)begin
                                cdb_out_result = station[cur][95:64] >> station[cur][36:32];
                            end else begin
                                cdb_out_result = ({32{station[cur][95]}} << (6'd32 - {1'b0, station[cur][36:32]})) | (station[cur][95:64] >> station[cur][36:32]);
                            end   
                        end
                        `INST_OR:begin
                            cdb_out_result = station[cur][95:64] | station[cur][63:32];
                        end 
                        `INST_AND:begin
                            cdb_out_result = station[cur][95:64] & station[cur][63:32];  
                        end 
                        default:begin
                            cdb_out_result = 0;
                        end
                    endcase
        end
        `INST_TYPE_I_M:begin
                    case(station[cur][121:119])
                        `INST_ADDI:begin
                            cdb_out_result = station[cur][95:64] + station[cur][31:0];
                            
                        end
                        `INST_SLTI:begin
                            if(station[cur][95:64] < station[cur][31:0])begin
                                cdb_out_result = 32'h00000001;
                            end else begin
                                cdb_out_result = 32'h00000000;
                            end
                        end
                        `INST_SLTIU:begin
                            if(station[cur][95:64] < station[cur][31:0])begin
                                cdb_out_result = 32'h00000001;
                            end else begin
                                cdb_out_result = 32'h00000000;
                            end
                        end
                        `INST_XORI:begin
                            cdb_out_result = station[cur][95:64] ^ station[cur][31:0];
                        end
                        `INST_ORI:begin
                            cdb_out_result = station[cur][95:64] | station[cur][31:0];
                        end
                        `INST_ANDI:begin
                            cdb_out_result = station[cur][95:64] & station[cur][31:0];
                        end
                        `INST_SLLI:begin
                            cdb_out_result = station[cur][95:64] << station[cur][4:0];
                        end
                        `INST_SRI:begin
                              if (station[cur][10]) begin
                                cdb_out_result = ({32{station[cur][95]}} << (6'd32 - {1'b0, station[cur][4:0]})) | (station[cur][95:64] >> station[cur][4:0]);
                            end else begin
                                cdb_out_result = station[cur][95:64] >> station[cur][4:0];
                            end
                        end
                        default:begin
                            cdb_out_result = 0;
                        end
                   endcase
        end
        `INST_TYPE_AUIPC:begin
            cdb_out_result = station[cur][95:64] + station[cur][31:0];
        end
        `INST_TYPE_LUI:begin
            cdb_out_result = station[cur][31:0];
        end
        endcase
        station[cur] <= {`ALU_BUS{1'b0}};    
        counter = counter - 1;
        end else begin
            cdb_out_valid <= 0;
        end   
    end
    
    always @(negedge clk)begin
        cdb_out_valid <= 0;
    end
endmodule 
