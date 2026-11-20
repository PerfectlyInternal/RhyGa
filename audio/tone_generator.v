module tone_generator(
	// Inputs
	CLOCK_50,
	
	enable,
	
	shape,
	period,
	
	// Outputs
	audio_out
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/

parameter NONE = 2'b00, SQUARE = 2'b01, TRIANGLE = 2'b10, SAWTOOTH = 2'b11;

parameter MAX_SAMPLE = 32'd10000000;

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input				CLOCK_50;

input				enable;

input	[1:0]		shape;
input [18:0]	period;

// Outputs
output [31:0]	audio_out;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// Wires
wire	[31:0]	wave_portion;
wire				wave_side;

// Registers
reg	[18:0]	frequency_divider;
reg	[31:0]	sample;

/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

// Divide the 50 MHz clock down to the set output frequency
always @(posedge CLOCK_50) begin
	if(frequency_divider == period) begin
		frequency_divider <= 0;
	end else frequency_divider <= frequency_divider + 1;
end

// Set the output sample based on the frequency divider
always @(frequency_divider) begin
	case(shape)
		NONE: sample <= 0;
		SQUARE: sample <= wave_side ? MAX_SAMPLE : -MAX_SAMPLE;
		TRIANGLE: sample <= wave_side ? MAX_SAMPLE - (2 * wave_portion) : -MAX_SAMPLE + (2 * wave_portion);
		SAWTOOTH: sample <= wave_side ? -MAX_SAMPLE + wave_portion : 0 + wave_portion;
	endcase
end

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

// Ranges from 0 to MAX_SAMPLE over the course of one half period, sync'd to the wave side.
assign wave_portion = (MAX_SAMPLE * frequency_divider / (period / 2));
// 0 in the first half of the period, 1 in the second half.
assign wave_side = frequency_divider > (period / 2);

assign audio_out = enable ? sample : 32'b0;

endmodule