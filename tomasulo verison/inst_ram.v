module inst_ram(
    input wire clk,
    input wire rst,
    
    input wire[31:0] addr_i,
    output reg[31:0] data_o
);
    
    reg[31:0] _ram[0:32837];
    
    initial begin
        _ram[0] = 32'hfe010113;
		_ram[1] = 32'h00112e23;
		_ram[2] = 32'h00812c23;
		_ram[3] = 32'h02010413;
		_ram[4] = 32'hfea42623;
		_ram[5] = 32'hfec42703;
		_ram[6] = 32'h00100793;
		_ram[7] = 32'h00f71663;
		_ram[8] = 32'h00100793;
		_ram[9] = 32'h0300006f;
		_ram[10] = 32'hfec42703;
		_ram[11] = 32'h00100793;
		_ram[12] = 32'h02e7d263;
		_ram[13] = 32'hfec42783;
		_ram[14] = 32'hfff78793;
		_ram[15] = 32'h00078513;
		_ram[16] = 32'hfc1ff0ef;
		_ram[17] = 32'h00050713;
		_ram[18] = 32'hfec42783;
		_ram[19] = 32'h02f707b3;
		_ram[20] = 32'h0040006f;
		_ram[21] = 32'h00078513;
		_ram[22] = 32'h01c12083;
		_ram[23] = 32'h01812403;
		_ram[24] = 32'h02010113;
		_ram[25] = 32'h00008067;
		_ram[26] = 32'hfd010113;
		_ram[27] = 32'h02812623;
		_ram[28] = 32'h03010413;
		_ram[29] = 32'hfca42e23;
		_ram[30] = 32'hfdc42703;
		_ram[31] = 32'h00100793;
		_ram[32] = 32'h00f70863;
		_ram[33] = 32'hfdc42703;
		_ram[34] = 32'h00200793;
		_ram[35] = 32'h00f71663;
		_ram[36] = 32'h00100793;
		_ram[37] = 32'h05c0006f;
		_ram[38] = 32'h00200793;
		_ram[39] = 32'hfef42623;
		_ram[40] = 32'h00100793;
		_ram[41] = 32'hfef42423;
		_ram[42] = 32'h00100793;
		_ram[43] = 32'hfef42223;
		_ram[44] = 32'h0300006f;
		_ram[45] = 32'hfe442703;
		_ram[46] = 32'hfe842783;
		_ram[47] = 32'h00f707b3;
		_ram[48] = 32'hfef42223;
		_ram[49] = 32'hfe442703;
		_ram[50] = 32'hfe842783;
		_ram[51] = 32'h40f707b3;
		_ram[52] = 32'hfef42423;
		_ram[53] = 32'hfec42783;
		_ram[54] = 32'h00178793;
		_ram[55] = 32'hfef42623;
		_ram[56] = 32'hfec42703;
		_ram[57] = 32'hfdc42783;
		_ram[58] = 32'hfcf746e3;
		_ram[59] = 32'hfe442783;
		_ram[60] = 32'h00078513;
		_ram[61] = 32'h02c12403;
		_ram[62] = 32'h03010113;
		_ram[63] = 32'h00008067;
		_ram[64] = 32'hfd010113;
		_ram[65] = 32'h02112623;
		_ram[66] = 32'h02812423;
		_ram[67] = 32'h03010413;
		_ram[68] = 32'hfca42e23;
		_ram[69] = 32'hfcb42c23;
		_ram[70] = 32'h00a00793;
		_ram[71] = 32'hfef42623;
		_ram[72] = 32'hfec42503;
		_ram[73] = 32'heddff0ef;
		_ram[74] = 32'hfea42423;
		_ram[75] = 32'hfec42503;
		_ram[76] = 32'hf39ff0ef;
		_ram[77] = 32'hfea42223;
		_ram[78] = 32'h00000793;
		_ram[79] = 32'h00078513;
		_ram[80] = 32'h02c12083;
		_ram[81] = 32'h02812403;
		_ram[82] = 32'h03010113;
		_ram[83] = 32'h00008067;
    end
    
    always @(*)begin
        if(rst)begin
            data_o = 0;
        end else begin
            data_o = _ram[addr_i[31:2]];
        end
    end
endmodule