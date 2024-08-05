//=========The concept is to separate the width of the screen into regions, each region is 32 pixels wide. 
//=========Each region is devided into 15 sections. Based on the section we know the x position of the shot, and can set the width of the shot, 
//=========since every two pixels are one section.


module	PlayerMissileMatrixBitMap	(	
					input		logic	clk,
					input		logic	resetN,

					input 	logic	[10:0] offsetX, // offset from top left position 
					input 	logic	[10:0] offsetY,

					input		logic	[10:0] offsetXPlayerCenter, //offset from top left position of the player, used to know where we're shooting from
					input		logic	[10:0] offsetYPlayerCenter,
					input 	logic 	enterkey,//shoot
		
					input 	logic 	collision2, //collision with monster
					input 	logic 	collision4, //collision with shield
					input		logic 	collision8, //collision with border

					input 	logic	startOfFrame,
					input		logic	InsideRectangle, //input that the pixel is within a bracket 
					output	logic	drawingRequest, //output that the pixel should be dispalyed
					output	logic	[7:0] RGBout  //rgb value from the bitmap 
 ) ;
 
localparam 	logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// RGB value in the bitmap representing a transparent pixel 
parameter	int	FramesPerShot = 2; //used to set the speed of the shot, the more frames, the slower the shot

//=========32 regions by 32 regions matrix. For each element we have 5 bits, 
//=========bits 0-3 for the section and 4 to enable or disable drawing the region,
//=========as 1 means enable, 0 means disable.
logic [0:31] [0:31][4:0] MazeBitMapMask ;  
logic [0:31] [0:31][4:0] MazeDefaultBitMapMask = '0; // initialize the table with zeros, since there are no shots fired yet


logic [3:0] vga_section_in_region; //will be set to offsetX][4:1], used to determine the section the VGA is in.
logic [3:0] player_section_in_region; //will be set to offsetXPlayerCenter[4:1], used to determine the section the player is in.


int frames = 0; //used to set the speed of the shot, see below
logic flag = 0; //used to separate between one shot and the next

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		frames <= 0;
		RGBout <=	8'hFF;
		MazeBitMapMask  <=  MazeDefaultBitMapMask ;  //copy default tabel 
	end

	else begin
		RGBout <= TRANSPARENT_ENCODING ; //default color is transparent

		//=========Every two pixels are one section, so we don't care about the LSB. 
		//=========The region is determined by the top 5 bits out of 10.
		vga_section_in_region <= offsetX[4:1];

		if (collision2 | collision4 | collision8) begin //disable drawing of a region if a collision occured in it
			MazeBitMapMask[offsetY[10:4]][offsetX[10:5]][4] <= 0; 
		end

		//----------------setting shot speed---------------------
		if (startOfFrame) begin
			if (frames == FramesPerShot-1) begin
					MazeBitMapMask[0:30] <= MazeBitMapMask[1:31]; //shift all shots up evrey second frame
					MazeBitMapMask[31] <= '0;
					frames <= 0;
			end
			else begin
				frames <= frames + 1;
			end
		end
		//----------------setting shot speed---------------------


		//------------------single shooting------------------
		player_section_in_region <= offsetXPlayerCenter[4:1]; //same principle as the VGA section

		//=========Here we set the section by assigning the lower 4 bits od each element as the section, 
		//=========and enable the region drawing with the 5 bit.
		if(enterkey & !flag) begin
			flag <= 1;
			//=========Section 15 is problematic since it will draw section 0 as well,
			//=========the resolution is fine enough to ignore this section.
			if (player_section_in_region == 4'b1111) 
				MazeBitMapMask[offsetYPlayerCenter[10:4]][offsetXPlayerCenter[10:5]][3:0] <= 4'b1110; //set previous section
			else
				MazeBitMapMask[offsetYPlayerCenter[10:4]][offsetXPlayerCenter[10:5]][3:0] <= player_section_in_region; //set the section
			MazeBitMapMask[offsetYPlayerCenter[10:4]][offsetXPlayerCenter[10:5]][4] <= 1; //enable drawing

		end
		else if(!enterkey) begin //differentiate between one shot and the next
			flag <= 0;
		end
		//------------------single shooting------------------
		
		
		//------------------drawing shot---------------------
		if (InsideRectangle == 1'b1 )	
			begin 
				//=========If the region is enabled, check if the vga is in the same dection as the shot, if so, draw the shot
				if (MazeBitMapMask[offsetY[10:4]][offsetX[10:5]][4])
					case (MazeBitMapMask[offsetY[10:4]][offsetX[10:5]][3:0] == vga_section_in_region) 
						0 : RGBout <= TRANSPARENT_ENCODING ;
						1 : RGBout <= 8'hD8; 
						default:  RGBout <= TRANSPARENT_ENCODING;
					endcase 
				else
					RGBout <= TRANSPARENT_ENCODING ;
			end 
		//------------------drawing shot---------------------
	end 
end

// decide if to draw the pixel or not 
assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   
endmodule