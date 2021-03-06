module inst_ram(
    input wire clk,
    input wire rst,
    
    input wire we_i,
    input wire[31:0] addr_i,
    input wire[31:0] data_i,
    
    output reg[31:0] data_o
);
    
    reg[31:0] _ram[0:32837];
    
    reg[5:0] i;
    initial begin
      	_ram[16512] = 32'h00002e17;
		_ram[16513] = 32'he08e2e03;
		_ram[16514] = 32'h000e0367;
		_ram[16515] = 32'h00000013;
		_ram[16516] = 32'hfe010113;
		_ram[16517] = 32'h00812e23;
		_ram[16518] = 32'h02010413;
		_ram[16519] = 32'hfea42623;
		_ram[16520] = 32'hfeb42423;
		_ram[16521] = 32'hfec42223;
		_ram[16522] = 32'hfe442783;
		_ram[16523] = 32'h00079663;
		_ram[16524] = 32'h00000793;
		_ram[16525] = 32'h07c0006f;
		_ram[16526] = 32'hfec42783;
		_ram[16527] = 32'h0007c703;
		_ram[16528] = 32'hfe842783;
		_ram[16529] = 32'h00178693;
		_ram[16530] = 32'hfed42423;
		_ram[16531] = 32'h0007c783;
		_ram[16532] = 32'h02f70663;
		_ram[16533] = 32'hfec42783;
		_ram[16534] = 32'h0007c783;
		_ram[16535] = 32'h00078713;
		_ram[16536] = 32'hfe842783;
		_ram[16537] = 32'hfff78793;
		_ram[16538] = 32'hfef42423;
		_ram[16539] = 32'hfe842783;
		_ram[16540] = 32'h0007c783;
		_ram[16541] = 32'h40f707b3;
		_ram[16542] = 32'h0380006f;
		_ram[16543] = 32'hfec42783;
		_ram[16544] = 32'h00178713;
		_ram[16545] = 32'hfee42623;
		_ram[16546] = 32'h0007c783;
		_ram[16547] = 32'h00078e63;
		_ram[16548] = 32'hfe442783;
		_ram[16549] = 32'hfff78793;
		_ram[16550] = 32'hfef42223;
		_ram[16551] = 32'hfe442783;
		_ram[16552] = 32'hf8079ce3;
		_ram[16553] = 32'h0080006f;
		_ram[16554] = 32'h00000013;
		_ram[16555] = 32'h00000793;
		_ram[16556] = 32'h00078513;
		_ram[16557] = 32'h01c12403;
		_ram[16558] = 32'h02010113;
		_ram[16559] = 32'h00008067;
		_ram[16560] = 32'hfd010113;
		_ram[16561] = 32'h02812623;
		_ram[16562] = 32'h03010413;
		_ram[16563] = 32'hfca42e23;
		_ram[16564] = 32'hfdc42783;
		_ram[16565] = 32'hfef42623;
		_ram[16566] = 32'h0100006f;
		_ram[16567] = 32'hfec42783;
		_ram[16568] = 32'h00178793;
		_ram[16569] = 32'hfef42623;
		_ram[16570] = 32'hfec42783;
		_ram[16571] = 32'h0007c783;
		_ram[16572] = 32'hfe0796e3;
		_ram[16573] = 32'hfec42703;
		_ram[16574] = 32'hfdc42783;
		_ram[16575] = 32'h40f707b3;
		_ram[16576] = 32'h00078513;
		_ram[16577] = 32'h02c12403;
		_ram[16578] = 32'h03010113;
		_ram[16579] = 32'h00008067;
		_ram[16580] = 32'hfd010113;
		_ram[16581] = 32'h02112623;
		_ram[16582] = 32'h02812423;
		_ram[16583] = 32'h03010413;
		_ram[16584] = 32'hfca42e23;
		_ram[16585] = 32'hfdc42503;
		_ram[16586] = 32'hf99ff0ef;
		_ram[16587] = 32'h00050713;
		_ram[16588] = 32'hc0e1a823;
		_ram[16589] = 32'hfe042623;
		_ram[16590] = 32'h02c0006f;
		_ram[16591] = 32'hc101a703;
		_ram[16592] = 32'h000127b7;
		_ram[16593] = 32'h01078693;
		_ram[16594] = 32'hfec42783;
		_ram[16595] = 32'h00279793;
		_ram[16596] = 32'h00f687b3;
		_ram[16597] = 32'h00e7a023;
		_ram[16598] = 32'hfec42783;
		_ram[16599] = 32'h00178793;
		_ram[16600] = 32'hfef42623;
		_ram[16601] = 32'hfec42703;
		_ram[16602] = 32'h0ff00793;
		_ram[16603] = 32'hfce7d8e3;
		_ram[16604] = 32'hfe042623;
		_ram[16605] = 32'h0480006f;
		_ram[16606] = 32'hc101a703;
		_ram[16607] = 32'hfec42783;
		_ram[16608] = 32'h40f707b3;
		_ram[16609] = 32'hfec42703;
		_ram[16610] = 32'hfdc42683;
		_ram[16611] = 32'h00e68733;
		_ram[16612] = 32'h00074703;
		_ram[16613] = 32'h00070613;
		_ram[16614] = 32'hfff78713;
		_ram[16615] = 32'h000127b7;
		_ram[16616] = 32'h01078693;
		_ram[16617] = 32'h00261793;
		_ram[16618] = 32'h00f687b3;
		_ram[16619] = 32'h00e7a023;
		_ram[16620] = 32'hfec42783;
		_ram[16621] = 32'h00178793;
		_ram[16622] = 32'hfef42623;
		_ram[16623] = 32'hc101a783;
		_ram[16624] = 32'hfec42703;
		_ram[16625] = 32'hfaf74ae3;
		_ram[16626] = 32'hfdc42703;
		_ram[16627] = 32'hc0e1aa23;
		_ram[16628] = 32'h00000013;
		_ram[16629] = 32'h02c12083;
		_ram[16630] = 32'h02812403;
		_ram[16631] = 32'h03010113;
		_ram[16632] = 32'h00008067;
		_ram[16633] = 32'hfd010113;
		_ram[16634] = 32'h02112623;
		_ram[16635] = 32'h02812423;
		_ram[16636] = 32'h02912223;
		_ram[16637] = 32'h03212023;
		_ram[16638] = 32'h03010413;
		_ram[16639] = 32'hfca42e23;
		_ram[16640] = 32'hc101a783;
		_ram[16641] = 32'hfff78493;
		_ram[16642] = 32'hfdc42503;
		_ram[16643] = 32'heb5ff0ef;
		_ram[16644] = 32'hfea42623;
		_ram[16645] = 32'h0840006f;
		_ram[16646] = 32'h012484b3;
		_ram[16647] = 32'hfec42783;
		_ram[16648] = 32'h02f4d863;
		_ram[16649] = 32'h00048713;
		_ram[16650] = 32'hfdc42783;
		_ram[16651] = 32'h00e787b3;
		_ram[16652] = 32'h0007c783;
		_ram[16653] = 32'h00078693;
		_ram[16654] = 32'h000127b7;
		_ram[16655] = 32'h01078713;
		_ram[16656] = 32'h00269793;
		_ram[16657] = 32'h00f707b3;
		_ram[16658] = 32'h0007a903;
		_ram[16659] = 32'hfd2046e3;
		_ram[16660] = 32'h04091463;
		_ram[16661] = 32'hc141a683;
		_ram[16662] = 32'hc101a783;
		_ram[16663] = 32'h40f487b3;
		_ram[16664] = 32'h00178793;
		_ram[16665] = 32'hfdc42703;
		_ram[16666] = 32'h00f707b3;
		_ram[16667] = 32'hfef42423;
		_ram[16668] = 32'hc101a783;
		_ram[16669] = 32'h00078613;
		_ram[16670] = 32'hfe842583;
		_ram[16671] = 32'h00068513;
		_ram[16672] = 32'hd91ff0ef;
		_ram[16673] = 32'h00050793;
		_ram[16674] = 32'h00079663;
		_ram[16675] = 32'hfe842783;
		_ram[16676] = 32'h0140006f;
		_ram[16677] = 32'h00148493;
		_ram[16678] = 32'hfec42783;
		_ram[16679] = 32'hf8f4c0e3;
		_ram[16680] = 32'h00000793;
		_ram[16681] = 32'h00078513;
		_ram[16682] = 32'h02c12083;
		_ram[16683] = 32'h02812403;
		_ram[16684] = 32'h02412483;
		_ram[16685] = 32'h02012903;
		_ram[16686] = 32'h03010113;
		_ram[16687] = 32'h00008067;
		_ram[16688] = 32'hf9010113;
		_ram[16689] = 32'h06112623;
		_ram[16690] = 32'h06812423;
		_ram[16691] = 32'h07010413;
		_ram[16692] = 32'h000107b7;
		_ram[16693] = 32'h64c78793;
		_ram[16694] = 32'h0007a503;
		_ram[16695] = 32'h0047a583;
		_ram[16696] = 32'h0087a603;
		_ram[16697] = 32'h00c7a683;
		_ram[16698] = 32'h0107a703;
		_ram[16699] = 32'h0147a783;
		_ram[16700] = 32'hfca42823;
		_ram[16701] = 32'hfcb42a23;
		_ram[16702] = 32'hfcc42c23;
		_ram[16703] = 32'hfcd42e23;
		_ram[16704] = 32'hfee42023;
		_ram[16705] = 32'hfef42223;
		_ram[16706] = 32'h000107b7;
		_ram[16707] = 32'h66478713;
		_ram[16708] = 32'hf9440793;
		_ram[16709] = 32'h00070693;
		_ram[16710] = 32'h03c00713;
		_ram[16711] = 32'h00070613;
		_ram[16712] = 32'h00068593;
		_ram[16713] = 32'h00078513;
		_ram[16714] = 32'h0;
		_ram[16715] = 32'hfe042623;
		_ram[16716] = 32'h04c0006f;
		_ram[16717] = 32'hfec42783;
		_ram[16718] = 32'h00279793;
		_ram[16719] = 32'hff040713;
		_ram[16720] = 32'h00f707b3;
		_ram[16721] = 32'hfe07a783;
		_ram[16722] = 32'h00078513;
		_ram[16723] = 32'hdc5ff0ef;
		_ram[16724] = 32'hfec42783;
		_ram[16725] = 32'h00279793;
		_ram[16726] = 32'hff040713;
		_ram[16727] = 32'h00f707b3;
		_ram[16728] = 32'hfa47a783;
		_ram[16729] = 32'h00078513;
		_ram[16730] = 32'he7dff0ef;
		_ram[16731] = 32'hfea42423;
		_ram[16732] = 32'hfec42783;
		_ram[16733] = 32'h00178793;
		_ram[16734] = 32'hfef42623;
		_ram[16735] = 32'hfec42783;
		_ram[16736] = 32'h00279793;
		_ram[16737] = 32'hff040713;
		_ram[16738] = 32'h00f707b3;
		_ram[16739] = 32'hfe07a783;
		_ram[16740] = 32'hfa0792e3;
		_ram[16741] = 32'h00000793;
		_ram[16742] = 32'h00078513;
		_ram[16743] = 32'h06c12083;
		_ram[16744] = 32'h06812403;
		_ram[16745] = 32'h07010113;
		_ram[16746] = 32'h00008067;
    end
    always @ (posedge clk)begin
        if(we_i)begin
            _ram[addr_i[31:2]] <= data_i;
        end
    end
    
    always @ (*)begin
        if(rst)begin
            data_o = 0;
        end else begin
            data_o = _ram[addr_i[31:2]];
        end
    end
endmodule