
module	ShieldsMatrixBitMap	(	
		input		logic		clk,
		input		logic		resetN,
		input 	logic		[10:0] offsetX,// offset from top left  position 
		input 	logic		[10:0] offsetY,
		input		logic		InsideRectangle, //input that the pixel is within a bracket 
		input 	logic 	collision5, //collision with monster missile, the other collisions wont do anything
		input		logic		collision4,
					
		output	logic		drawingRequestShields, //output that the pixel should be dispalyed 
		output	logic		[7:0] RGBShields  //rgb value from the bitmap 
 ) ;
 
 // this is the divider used to access the right pixel 
localparam  int 	OBJECT_NUMBER_OF_Y_BITS = 4 ;  // 2^4 = 16 
localparam  int 	OBJECT_NUMBER_OF_X_BITS = 5 ;  // 2^5 = 32 

localparam  int 	OBJECT_HEIGHT_Y = 1 << OBJECT_NUMBER_OF_Y_BITS ;
localparam  int	 OBJECT_WIDTH_X = 1 << OBJECT_NUMBER_OF_X_BITS ;

// this is the divider used to access the right pixel 
localparam  int 	OBJECT_HEIGHT_Y_DIVIDER = OBJECT_NUMBER_OF_Y_BITS - 3 ; // -2; how many pixel bits are in every collision pixel
localparam  int	OBJECT_WIDTH_X_DIVIDER = OBJECT_NUMBER_OF_X_BITS - 3 ; // -2

localparam logic 	[7:0] TRANSPARENT_ENCODING = 8'hFF ;// RGB value in the bitmap representing a transparent pixel 
 
logic [0:3] [0:17] MazeBitMapMask ;  

logic [0:3] [0:17] MazeDefaultBitMapMask = // defult table to load on reset 
{{18'b111001110011100111},
 {18'b111001110011100111},
 {18'b111001110011100111},
 {18'b111001110011100111}};

 
logic [0:OBJECT_HEIGHT_Y - 1][0:OBJECT_WIDTH_X - 1][7:0] object_colors = {
	{8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6},
	{8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6},
	{8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6},
	{8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6},
	{8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6},
	{8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6},
	{8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6},
	{8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6},
	{8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6},
	{8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6},
	{8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6},
	{8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6},
	{8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6},
	{8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6},
	{8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6},
	{8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6,8'hB6}};

 
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBShields <= 8'hFF ;
		MazeBitMapMask <= MazeDefaultBitMapMask ;  //  copy default tabel 
	end
	else begin
		RGBShields <= TRANSPARENT_ENCODING ; // default 	
		if (collision4 || collision5)
			MazeBitMapMask[offsetY[6:4]][offsetX[9:5]] <= 4'h0 ;

		if (InsideRectangle == 1'b1) begin 
			case (MazeBitMapMask[offsetY[6:4]][offsetX[9:5]])
				0 : RGBShields <= TRANSPARENT_ENCODING ;
				1 : RGBShields <= object_colors[offsetY[3:0]][offsetX[4:0]] ; 
				default:  RGBShields <= TRANSPARENT_ENCODING ; 
			endcase
		end 
 
	end 
	
end

//==----------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequestShields = (RGBShields != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   
endmodule

