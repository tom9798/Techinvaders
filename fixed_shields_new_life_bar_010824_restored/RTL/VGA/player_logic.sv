
module	player_logic	(	
 
		input		logic		clk,
		input		logic		resetN,
		input		logic		startOfFrame,					// short pulse every start of frame 30Hz 
		input		logic		rightKey,						// key 6 on keyboard is pressed
		input		logic		leftKey,							// key 4 on keyboard is pressed
		input		logic		collision0,						// collision if player is shot by monster
		input		logic		collision1,						// collision if monster hits player
		input		logic		collision6,						// collision if player hits edges
		input		logic		[3:0] HitEdgeCode,			// one bit per edge

		output	logic		signed	[10:0] topLeftX,	// output the top left corner 
		output	logic		signed 	[10:0] topLeftY,
		output 	logic					wasShot
);

parameter	int	INITIAL_X = 280 ;
parameter	int	INITIAL_Y = 300 ;
parameter 	int	INITIAL_X_SPEED = 0 ;
parameter	int	X_SPEED = 50 ;
parameter	int	INITIAL_LIVES = 3 ;
const			int	FIXED_POINT_MULTIPLIER = 64 ; // note it must be 2^n 
// FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that 
// we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calcuatuions,
// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions

// movement limits 
const 		int	OBJECT_WIDTH_X = 32 ;
const			int   OBJECT_HIGHT_Y = 32 ;
const			int	SafetyMargin   =	2 ;

const			int	x_FRAME_LEFT	=	(SafetyMargin)* FIXED_POINT_MULTIPLIER ; 
const			int	x_FRAME_RIGHT	=	(639 - SafetyMargin - OBJECT_WIDTH_X)* FIXED_POINT_MULTIPLIER ; 
const			int	y_FRAME_TOP		=	(SafetyMargin) * FIXED_POINT_MULTIPLIER ;
const			int	y_FRAME_BOTTOM	=	(479 -SafetyMargin - OBJECT_HIGHT_Y ) * FIXED_POINT_MULTIPLIER ; //- OBJECT_HIGHT_Y


enum  logic [2:0] {IDLE_ST,         	// initial state
						 STATIONARY_ST, 		// state when player does not move
						 HIT_ST, 				// state when player is hit
						 ENDGAME_ST,			//state when game is over
						 START_OF_FRAME_ST,  // startOfFrame activity-after all data collected 
						 POSITION_CHANGE_ST, // position interpolate 
						 POSITION_LIMITS_ST  // check if inside the frame  
						}  SM_MOTION ;

int 	Xspeed  ;    // speed    
int 	Xposition ;  // position
int 	Yposition ;  // position
int 	lives;		 // player lives

logic 	[15:0] hit_reg = 16'b00000 ;  // register to collect all the collisions in the frame. |corner|left|top|right|bottom|
logic 	collisionPlayerMissile = 1'b0 ;
logic 	collisionPlayerMonster = 1'b0 ;
//for collisions from objects

//---------
 
always_ff @(posedge clk or negedge resetN)
begin : fsm_sync_proc

	if (resetN == 1'b0) begin 
		SM_MOTION <= IDLE_ST	; 
		Xspeed <= 0	;  
		Xposition <= 0	; 
		hit_reg <= 16'b0 ;
		collisionPlayerMissile <= 1'b0 ;
		collisionPlayerMonster <= 1'b0 ;
		lives <= 0 ;
	end 	
	
	else begin

		case(SM_MOTION)
		
		//------------
			IDLE_ST: begin
		//------------
				Xspeed  <= INITIAL_X_SPEED ;  
				Xposition <= INITIAL_X*FIXED_POINT_MULTIPLIER ; 
				Yposition <= INITIAL_Y*FIXED_POINT_MULTIPLIER ; 
				hit_reg <= 16'b0 ;
				collisionPlayerMissile <= 1'b0 ;
				collisionPlayerMonster <= 1'b0 ;
				lives <= INITIAL_LIVES ;
				
				if (startOfFrame) 
					SM_MOTION <= STATIONARY_ST ;
			end
	
		//------------
			STATIONARY_ST:  begin     // when the player does not move
		//------------
				Xspeed  <= INITIAL_X_SPEED ;
				
				if (collision1) begin
					collisionPlayerMonster <= 1'b1 ;
				end

				if (collision0) begin 
					collisionPlayerMissile <= 1'b1 ;
				end
				
				if (collision6) begin
					hit_reg[HitEdgeCode] <= 1'b1 ;
				end

				if (leftKey) begin
					Xspeed <= -X_SPEED ;
					
				end
				
				if (rightKey) begin
					Xspeed <= X_SPEED ;
				end
				
				if(startOfFrame)
					SM_MOTION <= START_OF_FRAME_ST ;
					
			end
				
		//------------
			START_OF_FRAME_ST:  begin      //check if any collision was detected 
		//------------
				
				if (collisionPlayerMonster) begin 
					SM_MOTION <= ENDGAME_ST ;
				end
			
				if (collisionPlayerMissile) begin
					SM_MOTION <= HIT_ST ;
				end
			
				case (hit_reg)
				
					16'h0000:  // no collision in the frame 
						begin
							Xspeed <= Xspeed ;
						end
					//   CH       6H		3H         9H
					16'h1000,16'h0040,16'h0008,16'h0200:	// one of the four corners 	
						begin
							Xspeed <= INITIAL_X_SPEED ;
						end
					//   8H   ; (CH & 8H) ; (8H & 9H) ; (cH & 9H) ;(cH & 9H & 8H)   
					16'h0100,16'h1100,16'h0300,16'h1200,16'h1300:  // left side 
						begin
							Xspeed <= rightKey ? X_SPEED : INITIAL_X_SPEED ;
						end
					//  4H     (CH & 4H)  (4H & 6H) (CH & 6H)  (CH & 4H & 6H)
					16'h0010,16'h1010,16'h0050, 16'h1040 , 16'h1050 : //  top side 
						begin 
							Xspeed <= INITIAL_X_SPEED ;
						end
					//   2H  (2H & 6H) (2H & 3H) (6H & 3H )  (6H & 2H &3H )
					16'h0004,16'h0044,16'h000C, 16'h0048 , 16'h004C: // right side 
						begin
							// Xspeed <= INITIAL_X_SPEED ;
							Xspeed <= leftKey ? -X_SPEED : INITIAL_X_SPEED ;
						end
					//   1H  (1H & 9H) (1H & 3H) (3H & 9H ) (3H & 1H & 9H )
					16'h0002,16'h0202,16'h000A, ,16'h0028 ,16'h002A: // bottom side 
						begin
							Xspeed <= INITIAL_X_SPEED ;
						end
					default:  //complex corner 
						begin
							Xspeed <= INITIAL_X_SPEED ;
						end
				 
				endcase
					
				hit_reg <= 16'h0000;  //clear for next time 
								
				SM_MOTION <= POSITION_CHANGE_ST ; 
				
			end 

		//------------
			HIT_ST:  begin      //?? 
		//------------			
				wasShot <= 1'b1 ;
				lives <= (lives - 1) ;
				collisionPlayerMissile <= 1'b0 ;

					
				if (startOfFrame) begin
					wasShot <= 1'b0;
				end
				
				if (lives == 0) begin
						SM_MOTION <= ENDGAME_ST ; 
				end
				
				SM_MOTION <= STATIONARY_ST ;
				
			end
			
		//------------
			ENDGAME_ST:  begin      //?? 
		//------------			
				
				SM_MOTION <= IDLE_ST ;
			
			end
			
		//------------------------
			POSITION_CHANGE_ST : begin  // position interpolate 
		//------------------------
	
				Xposition <= Xposition + Xspeed ;
				
				SM_MOTION <= POSITION_LIMITS_ST ; 
				
			end
		
		//------------------------
			POSITION_LIMITS_ST : begin  //check if still inside the frame 
		//------------------------
			
				if (Xposition < x_FRAME_LEFT) 
					Xposition <= x_FRAME_LEFT ; 
					
				if (Xposition > x_FRAME_RIGHT)
					Xposition <= x_FRAME_RIGHT ;  

				SM_MOTION <= STATIONARY_ST ; 
			
			end
		
		endcase  // case
		
	end 

end // end fsm_sync

//return from FIXED point  trunc back to prame size parameters 
  
assign 	topLeftX = Xposition / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
assign 	topLeftY = INITIAL_Y ;
	
endmodule
//---------------
 
