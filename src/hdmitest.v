`timescale 1ns / 1ps

module hdmitest(
	input wire CLK100,
	
	//Buttons
	input btns,
	input btnd,
	
	//HDMI/DVI
	output wire[3:0] TX0_TMDS_P,
	output wire[3:0] TX0_TMDS_N,
	
	//VGA
	output Hsync,
	output Vsync,
	output [2:0] vgaRed,
	output [2:0] vgaGreen,
	output [1:0] vgaBlue
    );
	
	//get reset signal from button
	//This signal is not debounced... fuck it, this is only a demo.
	wire global_rst = btns;
	
	//vga clock
	//the clock generates 108MHz for 1280x1024@60Hz
	//if you want HD-Video, change the clock, the VGA timings and use hdcolorbar for the test pattern generation
	wire vga_clk;
	wire vga_clk_locked;
	vga_1280_1024_60_clock instance_name (
		.CLK_IN1(CLK100),
		.CLK_OUT1(vga_clk),
		.RESET(global_rst),
		.LOCKED(vga_clk_locked)
	);
	
	//vga reset
	wire vga_reset = ~vga_clk_locked | global_rst;
	
	wire vga_blank;
	wire [11:0] CounterX;
	wire [11:0] CounterY;

	vga_sync sync (
		.pixel_clk(vga_clk),
		.HS(Hsync),
		.VS(Vsync),
		.blank(vga_blank),
		.hcounter(CounterX),
		.vcounter(CounterY)
	);
	
	wire [7:0] pattern_r;
	wire [7:0] pattern_g;
	wire [7:0] pattern_b;
	
	colorbar patterngen (
		.i_clk_pxl(vga_clk),
		.i_rst(vga_reset),
		.baronly(1'b0),
		.i_vcnt(CounterY),
		.i_hcnt(CounterX),

		.o_r(pattern_r),
		.o_g(pattern_g),
		.o_b(pattern_b)
	);
	
	assign vgaRed = (!vga_blank) ? (btnd ? 3'b111 : pattern_r[7:5]) : 3'b0;
    assign vgaGreen = (!vga_blank) ? (btnd ? 3'b111 : pattern_g[7:5]) : 3'b0;
    assign vgaBlue = (!vga_blank) ? (btnd ? 2'b11 : pattern_b[7:6]) : 2'b0;


	wire tx0_clkfbout, tx0_clkfbin;
	wire tx0_pllclk0, tx0_pllclk2;
	wire tx0_plllckd;
	PLL_BASE # (
		.CLKIN_PERIOD(9.0), // 108 MHz
		.CLKFBOUT_MULT(10), //set VCO to 10x of CLKIN
		.CLKOUT0_DIVIDE(1),
		.CLKOUT1_DIVIDE(10),
		.CLKOUT2_DIVIDE(5),
		.COMPENSATION("SOURCE_SYNCHRONOUS")
	) PLL_OSERDES_0 (
		.CLKFBOUT(tx0_clkfbout),
		.CLKOUT0(tx0_pllclk0),
		.CLKOUT1(),
		.CLKOUT2(tx0_pllclk2),
		.CLKOUT3(),
		.CLKOUT4(),
		.CLKOUT5(),
		.LOCKED(tx0_plllckd),
		.CLKFBIN(tx0_clkfbin),
		.CLKIN(vga_clk),
		.RST(~vga_clk_locked)  
	);
	
	// This BUFG is needed in order to deskew between PLL clkin and clkout
	// So the tx0 pclkx2 and pclkx10 will have the same phase as the pclk input
	BUFG tx0_clkfb_buf (.I(tx0_clkfbout), .O(tx0_clkfbin));

	// regenerate pclkx2 for TX
	BUFG tx0_pclkx2_buf (.I(tx0_pllclk2), .O(tx0_pclkx2));

	// regenerate pclkx10 for TX
	wire tx0_bufpll_lock;
	wire tx0_serdesstrobe;
	BUFPLL #(
		.DIVIDE(5)
	) tx0_ioclk_buf (
		.PLLIN(tx0_pllclk0), 
		.GCLK(tx0_pclkx2),
		.LOCKED(tx0_plllckd),
		.IOCLK(tx0_pclkx10),
		.SERDESSTROBE(tx0_serdesstrobe),
		.LOCK(tx0_bufpll_lock)
	);


	dvi_encoder_top enc0 (
		.pclk        (vga_clk),
		.pclkx2      (tx0_pclkx2),
		.pclkx10     (tx0_pclkx10),
		.serdesstrobe(tx0_serdesstrobe),
		.rstin       (vga_reset),
		.blue_din    (pattern_b),
		.green_din   (pattern_g),
		.red_din     (pattern_r),
		.hsync       (Hsync),
		.vsync       (Vsync),
		.de          (!vga_blank),
		.TMDS        (TX0_TMDS_P),
		.TMDSB       (TX0_TMDS_N)
    );
endmodule
