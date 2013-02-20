module vga_sync (
	input             pixel_clk,
	output reg        HS,
	output reg        VS,
	output reg        blank,
	output reg [11:0] hcounter,
	output reg [11:0] vcounter
);

	parameter HMAX = 1688; 			// maxium value for the horizontal pixel counter
	parameter VMAX = 1066; 			// maxium value for the vertical pixel counter
	parameter HLINES = 1280; 		// total number of visible columns
	parameter HFP = HLINES + 48; 	// value for the horizontal counter where front porch ends
	parameter HSP = HFP + 112; 		// value for the horizontal counter where the synch pulse ends
	parameter VLINES = 1024; 		// total number of visible lines
	parameter VFP = VLINES + 1; 	// value for the vertical counter where the frone proch ends
	parameter VSP = VFP + 3; 		// value for the vertical counter where the synch pulse ends
	parameter SPP = 1;				//sync pulse polarity (1 = positive)

	always @(posedge pixel_clk) begin
		blank <= ~video_enable; 
	end

	//horzintal counter
	always @(posedge pixel_clk) begin
		if (hcounter == HMAX) hcounter <= 0;
		else hcounter <= hcounter + 1;
	end

	//vertical counter
	always @(posedge pixel_clk) begin
		if(hcounter == HMAX) begin
			if(vcounter == VMAX) vcounter <= 0;
			else vcounter <= vcounter + 1; 
		end
	end

	//Hsync generation
	always @(posedge pixel_clk) begin
		if(hcounter >= HFP && hcounter < HSP) HS <= SPP;
		else HS <= ~SPP; 
	end

	//Vsync generation
	always @(posedge pixel_clk) begin
		if(vcounter >= VFP && vcounter < VSP) VS <= SPP;
		else VS <= ~SPP; 
	end

	//Vertical blanking
	assign video_enable = (hcounter < HLINES && vcounter < VLINES) ? 1'b1 : 1'b0;

endmodule
