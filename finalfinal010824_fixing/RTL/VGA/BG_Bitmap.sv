
module	BG_Bitmap	(	

					input		logic	clk,
					input		logic	resetN,
					input 	logic	[10:0] pixelX,
					input 	logic	[10:0] pixelY,

					output	logic	[7:0]	BG_RGB,
					output	logic	dr_boarders 
);

const int	xFrameSize	=	635 ;
const int	yFrameSize	=	475 ;
const int	bracketOffset = 16 ;

logic [7:0] color ;

parameter logic [7:0] NAVY = 8'b00000001 ;
parameter logic [7:0] SILVER = 8'b10110110 ;
 
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		color <= NAVY ;		 
	end
	
	else begin
	// defaults 
		color <= NAVY ;
		dr_boarders <= 1'b0 ; 
		
		if (        ((pixelX <= bracketOffset) && (pixelX >= (bracketOffset - bracketOffset/4)) && (pixelY >= (bracketOffset - bracketOffset/4)) && (pixelY <= (yFrameSize - (bracketOffset - bracketOffset/4))))||
						((pixelY <= bracketOffset) && (pixelY >= (bracketOffset - bracketOffset/4)) && (pixelX >= bracketOffset) && (pixelX <= (xFrameSize - bracketOffset))) ||
						((pixelX >= (xFrameSize - bracketOffset)) && (pixelX <= (xFrameSize - (bracketOffset - bracketOffset/4))) && (pixelY >= (bracketOffset - bracketOffset/4)) && (pixelY <= (yFrameSize -(bracketOffset - bracketOffset/4))))||
						((pixelY >= (yFrameSize - bracketOffset)) && (pixelY <= (yFrameSize - (bracketOffset - bracketOffset/4))) && (pixelX >= bracketOffset) && (pixelX <= (xFrameSize - bracketOffset))))
		begin 
			color <= SILVER ;
			dr_boarders <= 1'b1 ;
		end
			
		BG_RGB <= color ;

	end
	
end
 
endmodule

