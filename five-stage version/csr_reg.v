`include "define.v"

// CSR寄存器模块
module csr_reg(

    input wire clk,
    input wire rst,

    // form ex
    input wire we_i,                        // ex模块写寄存器标志
    input wire[31:0] raddr_i,        // ex模块读寄存器地址
    input wire[31:0] waddr_i,        // ex模块写寄存器地址
    input wire[31:0] data_i,             // ex模块写寄存器数据
    input wire we_cf,

    // to ex
    output reg[31:0] data_o              // ex模块读寄存器数据

    );


    reg[63:0] cycle;
    reg[31:0] mtvec;
    reg[31:0] mcause;
    reg[31:0] mepc;
    reg[31:0] mie;
    reg[31:0] mstatus;
    reg[31:0] mscratch;
    reg cf;


  
  


    // cycle counter
    // 复位撤销后就一直计数
    always @ (posedge clk) begin
        if (rst) begin
            cycle <= {32'b0, 32'b0};
        end else begin
            cycle <= cycle + 1'b1;
        end
    end
  
    // write reg
    // 写寄存器操作
    always @ (posedge clk) begin
        if (rst) begin
            mtvec <= 0;
            mcause <= 0;
            mepc <= 0;
            mie <= 0;
            mstatus <= 0;
            mscratch <= 0;
        end else begin
            
            if(we_cf == 1)begin
               cf <= 1;
            end else
                cf <=0; 
            end
            // 优先响应ex模块的写操作
            if (we_i == 1) begin
                case (waddr_i[11:0])
                    `CSR_MTVEC: begin
                        mtvec <= data_i;
                    end
                    `CSR_MCAUSE: begin
                        mcause <= data_i;
                    end
                    `CSR_MEPC: begin
                        mepc <= data_i;
                    end
                    `CSR_MIE: begin
                        mie <= data_i;
                    end
                    `CSR_MSTATUS: begin
                        mstatus <= data_i;
                    end
                    `CSR_MSCRATCH: begin
                        mscratch <= data_i;
                    end
                    default: begin

                    end
                endcase
            end
        end
 

    // read reg
    // ex模块读CSR寄存器
    always @ (*) begin
        if (rst) begin
            data_o = 0;
        end else begin
            if ((waddr_i[11:0] == raddr_i[11:0]) && (we_i == 1)) begin
                data_o = data_i;
            end else begin
                case (raddr_i[11:0])
                    `CSR_CYCLE: begin
                        data_o = cycle[31:0];
                    end
                    `CSR_CYCLEH: begin
                        data_o = cycle[63:32];
                    end
                    `CSR_MTVEC: begin
                        data_o = mtvec;
                    end
                    `CSR_MCAUSE: begin
                        data_o = mcause;
                    end
                    `CSR_MEPC: begin
                        data_o = mepc;
                    end
                    `CSR_MIE: begin
                        data_o = mie;
                    end
                    `CSR_MSTATUS: begin
                        data_o = mstatus;
                    end
                    `CSR_MSCRATCH: begin
                        data_o = mscratch;
                    end
                    default: begin
                        data_o = 0;
                    end
                endcase
            end
        end
    end


endmodule

