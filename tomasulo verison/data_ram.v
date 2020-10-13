module data_ram(
    input wire clk,
    input wire rst,
    
    input wire we_i,
    input wire[31:0] raddr_i,
    input wire[31:0] waddr_i, 
    input wire[31:0] wdata_i,
    
    input wire[31:0] address,
    output wire[31:0] mem_rob,
    output reg[31:0] data_o
);
    
    reg[31:0] _ram[0:65535];

    always @ (posedge clk)begin
        if(we_i)begin
            _ram[waddr_i[31:2]] <= wdata_i;  
        end
    end
    
    always @ (*)begin
        if(rst)begin
            data_o = 0;
        end else if(we_i && waddr_i == raddr_i)begin
            data_o = wdata_i;
        end else begin
            data_o = _ram[raddr_i[31:2]];
        end
    end
endmodule