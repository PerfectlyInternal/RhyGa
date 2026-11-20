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

parameter [31:0]
	C = 32'd191110,
	Cs = 32'd180388,
	D = 32'd170265,
	Ds = 32'd160705,
	E = 32'd151685,
	F = 32'd143172,
	Fs = 32'd135139,
	G = 32'd127551,
	Gs = 32'd120395,
	A = 32'd113636,
	As = 32'd107259,
	B = 32'd101239;
 
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
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// Wires
wire reset = ~KEY[0];

wire				audio_out_allowed;
wire	[31:0]	audio_out; // Only one channel, no L/R
wire				write_audio_out;

wire	[31:0]	ch1_out;
wire	[31:0]	ch2_out;

// Registers
reg	[31:0]	second_timer;
reg	[3:0]		note_index;
reg	[31:0]	note;

/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

always @(posedge CLOCK_50) begin
	if(second_timer == 25000000) begin
		second_timer <= 0;
		if (note_index == 11) note_index <= 0;
		else note_index <= note_index + 1;
	end else second_timer <= second_timer + 1;
end

always @(note_index) begin
	case(note_index)
		0: note <= C;
		1: note <= Cs;
		2: note <= D;
		3: note <= Ds;
		4: note <= E;
		5: note <= F;
		6: note <= Fs;
		7: note <= G;
		8: note <= Gs;
		9: note <= A;
		10: note <= As;
		11: note <= B;
	endcase
end

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

assign audio_out 			= ch1_out;
assign write_audio_out	= audio_out_allowed;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

tone_generator channel_1 (
	.CLOCK_50	(CLOCK_50),
	.enable		(SW[9]),
	.shape		(2'b01),
	.period		(note),
	.audio_out	(ch1_out)
);

tone_generator channel_2 (
	.CLOCK_50	(CLOCK_50),
	.enable		(SW[8]),
	.shape		(2'b10),
	.period		({SW[7:4], 15'd3000}),
	.audio_out	(ch2_out)
);

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