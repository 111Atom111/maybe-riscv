`include "define.v"

module Mul_U(
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
    reg[31:0] mul_op1;
    reg[31:0] mul_op2;
    wire[63:0] mul_temp;
    wire[63:0] mul_temp_invert;
    assign mul_temp = mul_op1 * mul_op2;
    assign mul_temp_invert = ~mul_temp + 1;
    
    integer k;
    initial begin
        cur = 0;
        tail = 0;
        counter = 0;
        for(k=0;k<4;k=k+1)begin
            station[k][129] = 0;
        end
    end
    
    integer i;
    always @(*)begin
        for(i=0;i<4;i=i+1)begin
            if(station[i][129]==1 && cdb_in_index != 0 && station[i][111:104] == cdb_in_index)begin
                station[i][111:104] = 0;
                station[i][95:64] = cdb_in_result;
            end
            if(station[i][129]==1 && cdb_in_index != 0 && station[i][103:96] == cdb_in_index)begin
                station[i][103:96] = 0;
                station[i][63:32] = cdb_in_result;
            end
        end
        if(counter == 2'b11)begin
            busy <= 1;
        end else begin
            busy <= 0;
        end 
    end
    
    integer j;
    always @(*)begin
        for(j=0;j<4;j=j+1)begin
            if(station[cur][129]==1 && station[cur][111:104]==8'b0 && station[cur][103:96]==8'b0)begin
                j = 4;
            end else begin
                cur = (cur + 1) % 4;
            end
        end   
        
        case (station[cur][121:119])
                    `INST_MUL, `INST_MULHU: begin
                        mul_op1 = station[cur][95:64];
                        mul_op2 = station[cur][63:32];
                       
                    end
                    `INST_MULHSU: begin
                        mul_op1 = (station[cur][95] == 1'b1)? (~station[cur][95:64] + 1): station[cur][95:64];
                        mul_op2 = station[cur][63:32];
                    end
                    `INST_MULH: begin
                        mul_op1 = (station[cur][95] == 1'b1)? (~station[cur][95:64] + 1): station[cur][95:64];
                        mul_op2 = (station[cur][63] == 1'b1)? (~station[cur][63:32] + 1): station[cur][63:32];
                    end
                    default: begin
                        mul_op1 = station[cur][95:64];
                        mul_op2 = station[cur][63:32];
                    end
                endcase    
    end
    
    integer p;
    always @(posedge clk)begin
      if(br)begin
            cur <= 0;
            tail <= 0;
            cdb_out_valid <= 0;
            counter <= 0;
            //cdb_out_result <= 0;
            for(p=0;p<4;p=p+1)begin
                station[p][129] <= 0;
            end
        end
        //decoder write
        else if(alu_enable && !station[tail][129] && alu_sel == 2'b01)begin
            counter <= counter + 1;
            station[tail][128:0] <= alu_bus;
            station[tail][129] <= 1;
            tag[tail] <= alu_tag;
            tail <= (tail + 1) % 4;
        end
        if(  grnt && station[cur][129]==1 && station[cur][111:104]==8'b0 && station[cur][103:96]==8'b0)begin
            cdb_out_valid <= 1;
            cdb_out_index <= tag[cur];
            case(station[cur][121:119])
                       `INST_MUL:begin
                            cdb_out_result = mul_temp[31:0];
                            
                        end
                        `INST_MULHU:begin
                            cdb_out_result = mul_temp[63:32];
                            
                        end
                        `INST_MULH:begin
                           case ({station[cur][95], station[cur][63]})
                                    2'b00: begin
                                        cdb_out_result = mul_temp[63:32];
                                    end
                                    2'b11: begin
                                        cdb_out_result = mul_temp[63:32];
                                    end
                                    2'b10: begin
                                        cdb_out_result = mul_temp_invert[63:32];
                                    end
                                    default: begin
                                        cdb_out_result = mul_temp_invert[63:32];
                                    end
                            endcase
                        end
                        `INST_MULHSU:begin
                            if (station[cur][95] == 1'b1) begin
                                    cdb_out_result = mul_temp_invert[63:32];
                            end else begin
                                    cdb_out_result = mul_temp[63:32];
                            end
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

