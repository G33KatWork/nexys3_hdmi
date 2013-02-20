`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   01:14:08 02/17/2013
// Design Name:   hdmitest
// Module Name:   /home/andy/Desktop/nexys3_hdmi/hdmitest_tb.v
// Project Name:  nexys3_hdmi
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: hdmitest
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module hdmitest_tb;
	//Clock parameters
	parameter tck              = 10;       // clock period in ns
	parameter clk_freq = 1000000000 / tck; // Frequenzy in HZ

	// Inputs
	reg CLK100;
	reg btns;
	reg btnd;

	// Outputs
	wire [3:0] TX0_TMDS_P;
	wire [3:0] TX0_TMDS_N;
	wire Hsync;
	wire Vsync;
	wire [2:0] vgaRed;
	wire [2:0] vgaGreen;
	wire [1:0] vgaBlue;

	// Instantiate the Unit Under Test (UUT)
	hdmitest uut (
		.CLK100(CLK100), 
		.btns(btns),
		.btnd(btnd),
		.TX0_TMDS_P(TX0_TMDS_P),
		.TX0_TMDS_N(TX0_TMDS_N),
		.Hsync(Hsync), 
		.Vsync(Vsync), 
		.vgaRed(vgaRed), 
		.vgaGreen(vgaGreen), 
		.vgaBlue(vgaBlue)
	);
	
	initial btnd <= 0;

	initial         CLK100 <= 0;
	always #(tck/2) CLK100 <= ~CLK100;

	initial begin
		// reset
		#0  btns <= 0;
		#20 btns <= 1;
		#80 btns <= 0;
        
		//#(tck*50000) $finish;
	end
      
endmodule

