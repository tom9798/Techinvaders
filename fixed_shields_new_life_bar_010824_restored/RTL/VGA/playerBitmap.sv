
module	playerBitmap	(	
		input		logic		clk,
		input		logic		resetN,
		input 	logic		[10:0] offsetX,// offset from top left  position 
		input 	logic		[10:0] offsetY,
		input		logic		InsideRectangle, //input that the pixel is within a bracket 

		output	logic		drawingRequestPlayer, //output that the pixel should be dispalyed 
		output	logic		[7:0] RGBPlayer,  //rgb value from the bitmap 
		output   logic		[3:0] HitEdgeCode //one bit per edge 
 ) ;

// this is the divider used to access the right pixel 
localparam  int 	OBJECT_NUMBER_OF_Y_BITS = 5 ;  // 2^5 = 32 
localparam  int	OBJECT_NUMBER_OF_X_BITS = 5 ;  // 2^5 = 32 


localparam  int	OBJECT_HEIGHT_Y = 1 << OBJECT_NUMBER_OF_Y_BITS ;
localparam  int	OBJECT_WIDTH_X = 1 << OBJECT_NUMBER_OF_X_BITS ;

// this is the divider used to access the right pixel 
localparam  int	OBJECT_HEIGHT_Y_DIVIDER = OBJECT_NUMBER_OF_Y_BITS - 3 ; // -2; how many pixel bits are in every collision pixel
localparam  int	OBJECT_WIDTH_X_DIVIDER = OBJECT_NUMBER_OF_X_BITS - 3 ;  // -2

// generating a smiley bitmap
localparam	logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// RGB value in the bitmap representing a transparent pixel 

logic [0:OBJECT_HEIGHT_Y-1] [0:OBJECT_WIDTH_X-1] [7:0] object_colors = {
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hdb,8'hdb,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hdb,8'hdb,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hdb,8'h2d,8'h2d,8'hdb,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hdb,8'hdf,8'h32,8'hdb,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hdb,8'h77,8'h77,8'hdb,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'hdb,8'h32,8'h32,8'hdb,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hdb,8'hff,8'hdb,8'h2d,8'h2d,8'hdb,8'hff,8'hdb,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hdb,8'hdb,8'hff,8'hdb,8'hb6,8'hb7,8'hdb,8'hff,8'hdb,8'hdb,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'hdb,8'hff,8'hdb,8'hdb,8'hdb,8'hdb,8'hff,8'hdb,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hdb,8'hb6,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hb6,8'hdb,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb6,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hdb,8'hff,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hff,8'hdb,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hdb,8'hff,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hff,8'hdb,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hff,8'hdb,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hdb,8'hff,8'hff,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hff,8'hdb,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hdb,8'hdb,8'hdb,8'he0,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hff,8'hdb,8'hdb,8'hff,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'he0,8'hdb,8'hdb,8'hdb,8'hff,8'hff},
	{8'hff,8'hff,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'h92,8'h92,8'h92,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'h92,8'h92,8'h92,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h92,8'h92,8'h92,8'h92,8'hff,8'h92,8'hb6,8'hdb,8'hdb,8'hb6,8'h92,8'hff,8'h8d,8'h92,8'h92,8'h92,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h92,8'h6e,8'h6d,8'h6d,8'hff,8'hb6,8'hb6,8'hdb,8'hdb,8'hb6,8'hb6,8'hff,8'h6d,8'h6e,8'h72,8'h6e,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h6d,8'h6d,8'hff,8'hff,8'hff,8'hb6,8'hdb,8'hdb,8'hb6,8'hff,8'hff,8'hff,8'h6d,8'h6d,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf4,8'hec,8'hff,8'hff,8'hff,8'hb6,8'h92,8'h6e,8'hb6,8'hff,8'hff,8'hff,8'hec,8'hf8,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf8,8'hec,8'hff,8'hff,8'hff,8'h6d,8'h6e,8'h92,8'h6d,8'hff,8'hff,8'hff,8'he4,8'hf8,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf4,8'hec,8'hff,8'hff,8'h6d,8'h92,8'h92,8'h6e,8'h72,8'h6d,8'hff,8'hff,8'hec,8'hf4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he0,8'he0,8'hff,8'h92,8'h71,8'hdb,8'hff,8'hff,8'hdb,8'h6d,8'h92,8'hff,8'he0,8'he0,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfa,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfa,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfa,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfa,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}};

//////////--------------------------------------------------------------------------------------------------------------=
//hit bit map has one bit per edge:  hit_colors[3:0] =   {Left, Top, Right, Bottom}	
//there is one bit per edge, in the corner two bits are set  
//each picture row and column divided to 8 sections 

logic [0:7] [0:7] [3:0] hit_colors = 
		  {32'hC4444446,     
			32'h8C444462,    
			32'h88C44622,    
			32'h888C6222,    
			32'h88893222,    
			32'h88911322,    
			32'h89111132,    
			32'h91111113};
 
// pipeline (ff) to get the pixel color from the array 	 
//////////--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBPlayer <= 8'hFF ;
		HitEdgeCode <= 4'h0 ;
	end

	else begin
		RGBPlayer <= TRANSPARENT_ENCODING ; // default  
		HitEdgeCode <= 4'h0 ;

		if (InsideRectangle == 1'b1) begin // inside an external bracket 
			RGBPlayer <= object_colors[offsetY][offsetX] ;
			HitEdgeCode <= hit_colors[offsetY >> OBJECT_HEIGHT_Y_DIVIDER][offsetX >> OBJECT_WIDTH_X_DIVIDER] ;	//get hitting edge code from the colors table  
		end  	
		
	end
		
end

//////////--------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequestPlayer = (RGBPlayer != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   

endmodule 