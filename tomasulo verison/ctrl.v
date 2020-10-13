module ctrl (
	input wire rst,
	input wire stallreq1,
	input wire stallreq2,
	output reg  stall
);

// stall[0] PC
// stall[1] IF
// stall[2] ID
// stall[3] EX
// stall[4] MEM
// stall[5] WB
	always @ (*) begin
		if(rst) begin
			stall <= 6'b000000;
		end else if (stallreq1 || stallreq2) begin
		    stall = 1;
		end else begin
		    stall = 0;
		end
	end 

endmodule