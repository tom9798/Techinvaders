
module	monster_shot_bitmap	(	
		input		logic		clk,
		input		logic		resetN,
		input 	logic		[10:0] offsetX,		// offset from top left  position 
		input 	logic		[10:0] offsetY,
		input		logic		InsideRectangle, 		//input that the pixel is within a bracket 	

		output	logic		drawingRequestMonsterShot, 	//output that the pixel should be dispalyed 
		output	logic		[7:0] RGBMonsterShot //rgb value from the bitmap 
 ) ;

// this is the divider used to access the right pixel 
localparam  int	OBJECT_NUMBER_OF_Y_BITS = 2 ;  // 2^2 = 4 
localparam  int	OBJECT_NUMBER_OF_X_BITS = 1 ;  // 2^1 = 2 

localparam  int	OBJECT_HEIGHT_Y = 1 << OBJECT_NUMBER_OF_Y_BITS ;
localparam  int	OBJECT_WIDTH_X = 1 << OBJECT_NUMBER_OF_X_BITS ;

// this is the divider used to access the right pixel 
localparam  int	OBJECT_HEIGHT_Y_DIVIDER = OBJECT_NUMBER_OF_Y_BITS - 3 ; // -2; how many pixel bits are in every collision pixel
localparam  int	OBJECT_WIDTH_X_DIVIDER = OBJECT_NUMBER_OF_X_BITS - 3 ; // -2

// generating a smiley bitmap
localparam	logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// RGB value in the bitmap representing a transparent pixel 

logic [0:OBJECT_HEIGHT_Y - 1][0:OBJECT_WIDTH_X - 1][7:0] object_colors = {
	{8'hD8,8'hD8},
	{8'hD8,8'hD8},
	{8'hD8,8'hD8},
	{8'hD8,8'hD8}};
	
//////////--------------------------------------------------------------------------------------------------------------=

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBMonsterShot <=	8'h00 ;
	end
	
	else begin
		RGBMonsterShot <= TRANSPARENT_ENCODING ; // default 
		
		if (InsideRectangle == 1'b1 )	begin 
			RGBMonsterShot <= object_colors[offsetY][offsetX] ;
		end 
 
	end
	
end

//==----------------------------------------------------------------------------------------------------------------=
 //decide if to draw the pixel or not 
assign drawingRequestMonsterShot = (RGBMonsterShot != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   
endmodule

