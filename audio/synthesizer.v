module synthesizer(
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
 *                           Parameter Declarations                          *
 *****************************************************************************/


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
output		AUD_DACDAT,

output		FPGA_I2C_SCLK

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// Wires
wire reset = ~KEY[0];

wire				audio_out_allowed;
wire	[31:0]	audio_out; // Only one channel, no L/R
wire				write_audio_out;

wire	[18:0]	period;

// Registers
reg	[18:0]	frequency_divider;
reg				wave_side;

/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/
 
always @(posedge CLOCK_50)
	if(frequency_divider == period) begin
		frequency_divider <= 0;
		wave_side <= !wave_side;
	end else frequency_divider <= frequency_divider + 1;

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/
 
assign period				= {SW[3:0], 15'd3000};
assign audio_out			= wave_side ? 32'd10000000 : -32'd10000000;
assign write_audio_out	= audio_out_allowed;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

Audio_Controller Audio_Controller (
	// Inputs
	.CLOCK_50						(CLOCK_50),
	.reset							(reset),

	.clear_audio_in_memory		(),
	.read_audio_in					(),
	
	.clear_audio_out_memory		(),
	.left_channel_audio_out		(audio_out),
	.right_channel_audio_out	(audio_out),
	.write_audio_out				(write_audio_out),

	.AUD_ADCDAT						(AUD_ADCDAT),

	// Bidirectionals
	.AUD_BCLK						(AUD_BCLK),
	.AUD_ADCLRCK					(AUD_ADCLRCK),
	.AUD_DACLRCK					(AUD_DACLRCK),

	// Outputs
	.audio_in_available			(),
	.left_channel_audio_in		(),
	.right_channel_audio_in		(),

	.audio_out_allowed			(audio_out_allowed),

	.AUD_XCK							(AUD_XCK),
	.AUD_DACDAT						(AUD_DACDAT)
);

avconf #(.USE_MIC_INPUT(0)) avc (
	.FPGA_I2C_SCLK	(FPGA_I2C_SCLK),
	.FPGA_I2C_SDAT	(FPGA_I2C_SDAT),
	.CLOCK_50		(CLOCK_50),
	.reset			(reset)
);
	
endmodule