
module	shields_square_object	(	
		input		logic				clk,
		input		logic				resetN,
		input 	logic signed	[10:0] pixelX,//  current VGA pixel 
		input 	logic signed	[10:0] pixelY,
					
		output 	logic	[10:0] offsetX,// offset inside bracket from top left position 
		output 	logic	[10:0] offsetY,
		output	logic	InsideRectangle // indicates pixel inside the bracket
);

parameter	int 	topLeftX = 16 ;
parameter	int 	topLeftY = 176 ;
parameter 	int 	OBJECT_WIDTH_X = 100 ;
parameter	int 	OBJECT_HEIGHT_Y = 100 ;
 
int 	rightX ; //coordinates of the sides  
int 	bottomY ;
logic insideBracket ; 

//////////--------------------------------------------------------------------------------------------------------------=
// Calculate object right  & bottom  boundaries
assign 	rightX = (topLeftX + OBJECT_WIDTH_X) ;
assign 	bottomY = (topLeftY + OBJECT_HEIGHT_Y) ;
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