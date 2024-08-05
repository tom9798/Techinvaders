
module	monsterBitMap	(	
		input		logic		clk,
		input		logic		resetN,
		input 	logic		[10:0] offsetX,// offset from top left  position 
		input 	logic		[10:0] offsetY,
		input		logic		InsideRectangle, //input that the pixel is within a bracket 
		input		logic		collision2,	

		output	logic		drawingRequestMonster, //output that the pixel should be dispalyed 
		output	logic		[7:0] RGBMonster, //rgb value from the bitmap 
		output   logic		[3:0] HitEdgeCode //one bit per edge 
 ) ;

// this is the divider used to access the right pixel 
localparam	int	OBJECT_NUMBER_OF_Y_BITS = 5 ;  // 2^5 = 32 
localparam  int	OBJECT_NUMBER_OF_X_BITS = 5 ;  // 2^5 = 32 

localparam  int	OBJECT_HEIGHT_Y = 1 <<  OBJECT_NUMBER_OF_Y_BITS ;
localparam  int	OBJECT_WIDTH_X = 1 <<  OBJECT_NUMBER_OF_X_BITS ;

// this is the divider used to access the right pixel 
localparam  int	OBJECT_HEIGHT_Y_DIVIDER = OBJECT_NUMBER_OF_Y_BITS - 3 ; // -2; how many pixel bits are in every collision pixel
localparam  int	OBJECT_WIDTH_X_DIVIDER = OBJECT_NUMBER_OF_X_BITS - 3 ; // -2

// generating a smiley bitmap
localparam	logic	[7:0] TRANSPARENT_ENCODING = 8'hFF ;// RGB value in the bitmap representing a transparent pixel 

logic [0:7] [0:15] [3:0]  MazeBitMapMask ;  

logic [0:7] [0:15] [3:0]  MazeDefaultBitMapMask = // defult table to load on reset 
{{64'h0020220000022020},
 {64'h0002002222200200},
 {64'h0002200222002200},
 {64'h0000222222222000},
 {64'h0200022222220002},
 {64'h0220002222200022},
 {64'h0022022000220220},
 {64'h0000222202222000}};

logic [1:0][0:OBJECT_HEIGHT_Y - 1][0:OBJECT_WIDTH_X - 1][7:0] object_colors = {
  {{8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0},
	{8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0},
	{8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0},
	{8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0},
	{8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0},
	{8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0},
	{8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0},
	{8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0},
	{8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0},
	{8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0},
	{8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0},
	{8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0},
	{8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0},
	{8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0},
	{8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0},
	{8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0},
	{8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0},
	{8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0},
	{8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0},
	{8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0},
	{8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0},
	{8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0},
	{8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0},
	{8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0},
	{8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0},
	{8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0},
	{8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0},
	{8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0},
	{8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0},
	{8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0},
	{8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0},
	{8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0,8'he0}},
	
  {{8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc},
	{8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc}}};
  
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
 
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBMonster <= 8'hFF ;
		MazeBitMapMask <= MazeDefaultBitMapMask ;  //  copy default tabel 
		HitEdgeCode <= 4'h0 ;
	end
	
	else begin
		RGBMonster <= TRANSPARENT_ENCODING ; // default 
		HitEdgeCode <= 4'h0 ;
			if (collision2 == 1'b1)
				MazeBitMapMask[offsetY[8:5]][offsetX[8:5]] <= MazeBitMapMask[offsetY[8:5]][offsetX[8:5]] - 1;
				
		if (InsideRectangle == 1'b1 )	
			begin 
				case (MazeBitMapMask[offsetY[8:5]][offsetX[8:5]])
					 4'h0 : RGBMonster <= TRANSPARENT_ENCODING ;
					 4'h1 : RGBMonster <= object_colors[2'h1][offsetY[4:0]][offsetX[4:0]]; 
					 4'h2 : RGBMonster <= object_colors[2'h0][offsetY[4:0]][offsetX[4:0]]; 
					 default:  RGBMonster <= TRANSPARENT_ENCODING ; 
				endcase
				HitEdgeCode <= hit_colors[offsetY >> OBJECT_HEIGHT_Y_DIVIDER][offsetX >> OBJECT_WIDTH_X_DIVIDER] ;	//get hitting edge code from the colors table
			end 
 
	end 
	
end

//==----------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequestMonster = (RGBMonster != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   
endmodule

