
module	LifeBarBitMap	(	
		input		logic		clk,
		input		logic		resetN,
		input 	logic		[10:0] offsetX,// offset inside bracket from top left position 
		input 	logic		[10:0] offsetY,
		input		logic		InsideRectangle, //input that the pixel is within a bracket 
		input 	logic 	collision0, //collision of player monster missile, will decrease the life bar
		input 	logic 	collision1, //collision of player and monster, will decrease the life bar to 0
		input 	logic 	collision3, //collision of monster and shield, will decrease the life bar to 0
		input 	logic 	startOfFrame, 
		
		output	logic		drawingRequest, //output that the pixel should be dispalyed 
		output	logic		[7:0] RGBout  //rgb value from the bitmap 
 ) ;

parameter		int	InitialLives = 3 ;
parameter		int	LifeBarLength = 120 ;
localparam		logic		[7:0] TRANSPARENT_ENCODING = 8'hFF ; //RGB value in the bitmap representing a transparent pixel

int		XPaintLimit = LifeBarLength ; //initial value of the life bar drawing length, will decrease when collision occurs
int		currentPaintLimit = LifeBarLength ; //used to for smooth decrease of the life bar, will decrease to current XPaintLimit value
int		lives = InitialLives ; //initial value of the lives
logic		hurt = 1'b0 ; //flag to indicate that the player was hurt and start the decrease of the life bar to the new value

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout <= 8'hFF ;
		hurt <= 1'b0 ;
		lives <= InitialLives ;
		XPaintLimit <= LifeBarLength ;
		currentPaintLimit <= LifeBarLength ;
	end
	
	else begin
		RGBout <= TRANSPARENT_ENCODING ; //default 
		if (collision0 & (currentPaintLimit <= XPaintLimit)) begin // if the player was hit by a monster missile
			hurt <= 1'b1 ;
			XPaintLimit <= (lives != 0) ? (XPaintLimit - (LifeBarLength/lives)) : 0 ; //decrease the life bar length, if the life bar is 0, keep it 0
			lives <= (lives > 0) ? (lives - 1) : 0 ; //decrease the lives, if the lives are 0, keep them 0
		end

		if (collision1 || collision3) begin // if the player was hit by a monster or the monster hit a shield
			hurt <= 1'b1;
			XPaintLimit <= 0;
			lives <= 0;
		end

		if (hurt & startOfFrame) begin //decrease the life bar smoothly
			currentPaintLimit <= (currentPaintLimit != XPaintLimit) ? (currentPaintLimit - 5) : currentPaintLimit ; //decrease the life bar smoothly
			hurt <= (currentPaintLimit != XPaintLimit) ? 1'b1 : 1'b0 ; //if the life bar is not at the new value, keep decreasing it
		end

		if (InsideRectangle & (offsetX < currentPaintLimit)) begin 
			case(lives)
				InitialLives: begin
					RGBout <= 8'b00011100;
				end
				1: begin
					RGBout <= 8'b11100000;
				end
				0: begin
					RGBout <= 8'b11100000;
				end
				default: begin
					RGBout <= 8'hD8;
				end
			endcase
		end 	
	end 
end

// decide if to draw the pixel or not 
assign	drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   
endmodule