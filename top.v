module top(
	// Inputs
	CLOCK_50,
	KEY,
	SW,

	AUD_ADCDAT,

	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,

	FPGA_I2C_SDAT,

	// Outputs
	AUD_XCK,
	AUD_DACDAT,

	FPGA_I2C_SCLK
);

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input			CLOCK_50;
input [3:0]	KEY;
input [9:0]	SW;

input			AUD_ADCDAT;

// Bidirectionals
inout 		AUD_BCLK;
inout 		AUD_ADCLRCK;
inout 		AUD_DACLRCK;

inout 		FPGA_I2C_SDAT;

// Outputs
output		AUD_XCK;
output		AUD_DACDAT;

output		FPGA_I2C_SCLK;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/
synthesizer synthesizer (
	// Inputs
	.CLOCK_50		(CLOCK_50),
	.KEY				(KEY),
	.SW				(SW),

	.AUD_ADCDAT		(AUD_ADCAT),

	// Bidirectionals
	.AUD_BCLK		(AUD_BCLK),
	.AUD_ADCLRCK	(AUD_ADCLRCK),
	.AUD_DACLRCK	(AUD_DACLRCK),

	.FPGA_I2C_SDAT	(FPGA_I2C_SDAT),

	// Outputs
	.AUD_XCK			(AUD_XCK),
	.AUD_DACDAT		(AUD_DACDAT),

	.FPGA_I2C_SCLK	(FPGA_I2C_SCLK)
);

endmodule