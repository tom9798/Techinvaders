
module	square_object_monster	(	
		input		logic				clk,
		input		logic				resetN,
		input 	logic signed	[10:0] pixelX,		//  current VGA pixel 
		input 	logic signed	[10:0] pixelY,
		input 	logic signed	[10:0] topLeftX,	// position on the screen 
		input 	logic	signed	[10:0] topLeftY,	// can be negative , if the object is partliy outside 
			
		output 	logic				[10:0] offsetX,// offset inside bracket from top left position 
		output 	logic				[10:0] offsetY,
		output	logic				InsideRectangle 
);

parameter  	int		OBJECT_WIDTH_X = 512 ;
parameter  	int 		OBJECT_HEIGHT_Y = 256 ;
parameter  	logic 	[7:0] OBJECT_COLOR = 8'b00000011 ; 
localparam 	logic 	[7:0] TRANSPARENT_ENCODING = 8'hFF ;// bitmap  representation for a transparent pixel 
 
int 	rightX ; //coordinates of the sides  
int 	bottomY ;
logic insideBracket ; 

//////////--------------------------------------------------------------------------------------------------------------=
// Calculate object right  & bottom  boundaries
assign rightX = (topLeftX + OBJECT_WIDTH_X) ;
assign bottomY	= (topLeftY + OBJECT_HEIGHT_Y) ;
assign	insideBracket = ( (pixelX >= topLeftX) && (pixelX < rightX) // math is made with SIGNED variables  
						   && (pixelY >= topLeftY) && (pixelY < bottomY) ) ; // as the top left position can be negative

//////////--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		InsideRectangle <= 1'b0 ;
	end
	
	else begin 
	// DEFUALT outputs
		InsideRectangle <= 1'b0 ;// transparent color 
		offsetX <= 0 ; //no offset
		offsetY <= 0 ; //no offset
	
 
		if (insideBracket) // test if it is inside the rectangle 
		begin 
			InsideRectangle <= 1'b1 ;
			offsetX <= (pixelX - topLeftX) ; //calculate relative offsets from top left corner allways a positive number 
			offsetY <= (pixelY - topLeftY) ;
		end 
		
	end
	
end 

endmodule 