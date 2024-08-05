
module	SQR_missile_object	(	
					input	logic	clk,
					input	logic	resetN,
					input  	logic 	signed	[10:0] topLeftPlayerX,
					input  	logic 	signed	[10:0] topLeftPlayerY,
					input 	logic 	signed	[10:0] pixelX,//  current VGA pixel 
					input 	logic 	signed	[10:0] pixelY,
					// input 	logic 	signed	[10:0] topLeftX, //top left of the screen
					// input 	logic	signed  [10:0] topLeftY,   // can be negative , if the object is partliy outside 
					
					output 	logic	[10:0] offsetX,// offset inside bracket from top left position 
					output 	logic	[10:0] offsetY,
					output 	logic	[10:0] offsetXPlayerCenter,// offset inside bracket from top left position 
					output 	logic	[10:0] offsetYPlayerCenter,
					output	logic	InsideRectangle // indicates pixel inside the bracket 
);


const int	FIXED_POINT_MULTIPLIER = 64; // note it must be 2^n
 
localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// bitmap  representation for a transparent pixel 

logic insideBracket ; 

parameter int	BordersWidth   =	16; 
parameter int	playerHeight   =	32;
parameter int 	playerWidth    =	32;

const logic signed [10:0] topLeftX = 16;
const logic signed [10:0] topLeftY = 16;

assign insideBracket  = ( (pixelX >= topLeftX) && (pixelX < 640-16) && (pixelY >= topLeftY) && (pixelY < 480-16) ); 

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		InsideRectangle <= 1'b0;
	end
	else begin 
		// DEFUALT outputs
			InsideRectangle <= 1'b0 ;// transparent color 
			offsetX	<= 0; //no offset
			offsetY	<= 0; //no offset
 
		if (insideBracket) // test if it is inside the rectangle 
		begin
			InsideRectangle <= 1'b1 ;

			offsetX	<= (pixelX - topLeftX); //calculate relative offsets from top left corner allways a positive number 
			offsetY	<= (pixelY - topLeftY);
			offsetXPlayerCenter <= (topLeftPlayerX - topLeftX + playerWidth/2); //player width is 32, so the center is 16
			offsetYPlayerCenter <= (topLeftPlayerY - topLeftY);

		end 
	
	end
end 

endmodule 