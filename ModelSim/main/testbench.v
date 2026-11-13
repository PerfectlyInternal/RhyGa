`timescale 1ns / 1ps

module testbench ( );
    // 50 MHz clock has 20 ns period
	parameter CLOCK_PERIOD = 20;

	reg Clk, R, S;
	wire Qa, Qb;

	initial begin
		Clk <= 1'b0;
	end // initial
	always @ (*)
	begin : Clock_Generator
		#((CLOCK_PERIOD) / 2) Clk <= ~Clk;
	end
	
	initial begin
		R <= 1; S <= 0;
		#10 R <= 0;
		#10 S <= 1;
		#10 S <= 0;
		#20 R <= 1;
		#10 R <= 0;
	end // initial

	main U1 (Clk);

endmodule
