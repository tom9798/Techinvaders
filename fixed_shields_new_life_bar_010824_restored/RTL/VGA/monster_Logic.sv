
module	monster_Logic	(	
 
		input		logic		clk,
		input		logic 	resetN,
		input		logic 	startOfFrame,      		//short pulse every start of frame 30Hz    
		input		logic 	collision1,         		//collision if smiley hits an object
		input		logic 	collision2,
		input		logic 	collision3,
		input		logic 	collision7,
		input		logic 	[3:0] HitEdgeCode, 		//one bit per edge

		output	logic signed 	[10:0] topLeftX, 	// output the top left corner 
		output	logic signed	[10:0] topLeftY  	// can be negative , if the object is partliy outside	
);

// a module used to generate the  ball trajectory.  
parameter 	int	INITIAL_X = 280 ;
parameter 	int	INITIAL_Y = 20 ;
parameter 	int	INITIAL_X_SPEED = 30	;
parameter 	int	INITIAL_Y_SPEED = 0 ;
parameter	int	Y_SPEED = 50 ;

const 	int	FIXED_POINT_MULTIPLIER = 64 ; // note it must be 2^n 
// FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that 
// we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calcuatuions,
// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions

// movement limits 
const 	int  	OBJECT_WIDTH_X = 512 ;
const 	int  	OBJECT_HIGHT_Y = 256 ;
const 	int	SafetyMargin   =	2 ;

const 	int	x_FRAME_LEFT	=	(SafetyMargin)* FIXED_POINT_MULTIPLIER ; 
const 	int	x_FRAME_RIGHT	=	(639 - SafetyMargin - OBJECT_WIDTH_X)* FIXED_POINT_MULTIPLIER ; 
const 	int	y_FRAME_TOP		=	(SafetyMargin) * FIXED_POINT_MULTIPLIER;
const 	int	y_FRAME_BOTTOM	=	(479 - SafetyMargin - OBJECT_HIGHT_Y ) * FIXED_POINT_MULTIPLIER ; //- OBJECT_HIGHT_Y

enum  logic [2:0] {IDLE_ST,         		// initial state
						 MOVE_ST, 					// moving no colision 
						 START_OF_FRAME_ST, 	   // startOfFrame activity-after all data collected 
						 HIT_ST,
						 ENDGAME_ST,
						 POSITION_CHANGE_ST,	// position interpolate 
						 POSITION_LIMITS_ST  	// check if inside the frame  
						}  SM_MOTION ;

int	Xspeed  ; 		// speed    
int	Yspeed  ;
int	Xposition ;	//position   
int	Yposition ;  

logic		collisionMonsterPlayerOrShields ;
logic 	collisionMonsterMissile ;

logic 	[15:0] hit_reg = 16'b00000 ;  // register to collect all the collisions in the frame. |corner|left|top|right|bottom|

//---------
always_ff @(posedge clk or negedge resetN)
begin : fsm_sync_proc

	if (resetN == 1'b0) begin 
		SM_MOTION <= IDLE_ST ; 
		Xspeed <= 0 ; 
		Yspeed <= 0 ;
		Xposition <= 0 ; 
		Yposition <= 0 ; 
		hit_reg <= 16'b0 ;	
	end 	
	
	else begin

		case(SM_MOTION)
		
		//------------
			IDLE_ST: begin
		//------------
		
				Xspeed  <= INITIAL_X_SPEED* FIXED_POINT_MULTIPLIER ;
				Yspeed  <= INITIAL_Y_SPEED* FIXED_POINT_MULTIPLIER ;
				Xposition <= INITIAL_X* FIXED_POINT_MULTIPLIER ; 
				Yposition <= INITIAL_Y* FIXED_POINT_MULTIPLIER ; 
				
				if (startOfFrame) 
					SM_MOTION <= MOVE_ST ;
			end
	
		//------------
			MOVE_ST:  begin     // moving no collision 
		//------------
      // collecting collisions 
		
				if (collision1 || collision3) begin
					collisionMonsterPlayerOrShields <= 1'b1 ;
				end
				
				if (collision2) begin
					collisionMonsterMissile <= 1'b1 ;
				end
				
				if (collision7) begin
					hit_reg[HitEdgeCode] <= 1'b1 ;
				end
			
				if (startOfFrame)
					SM_MOTION <= START_OF_FRAME_ST ; 
			end 
		
		//------------
			START_OF_FRAME_ST:  begin      //check if any colisin was detected 
		//------------
	
//		  {32'hC4444446,     
//			32'h8C444462,    
//			32'h88c44622,    
//			32'h888C6222,    
//			32'h88893222,    
//			32'h88911322,    
//			32'h89111132,    
//			32'h91111113};
			
				if (collisionMonsterPlayerOrShields) begin
					SM_MOTION <= ENDGAME_ST	;
				end
				
				if (collisionMonsterMissile) begin
					SM_MOTION <= HIT_ST	;
				end
			
				case (hit_reg)
				
					16'h0000:  // no collision in the frame 
					
						begin
							Xspeed <= Xspeed ;
							Yspeed <= INITIAL_Y_SPEED ;
						end

					// 8H   ;  (CH & 8H);  (8H & 9H);  (cH & 9H); (cH&9H&8H);  		CH   ;   	9H
					16'h0100,	16'h1100,	16'h0300,	16'h1200,	16'h1300,	16'h1000,	16'h0200:  // left side 
						
						begin
							Yspeed <= Y_SPEED ;
							//Yposition = Yposition + Y_SPEED;
							if (Xspeed < 0)
								Xspeed <= -Xspeed ;
						end

					// 2H   ;  (2H & 6H);  (2H & 3H);  (6H & 3H); (6H&2H&3H);      6H	  ;      3H 
					16'h0004,	16'h0044,	16'h000C,	16'h0048,	16'h004C,	16'h0040,	16'h0008: // right side 
					
						begin
							Yspeed <= Y_SPEED ;
							//Yposition = Yposition + Y_SPEED;
							if (Xspeed > 0)
								Xspeed <= -Xspeed ;
						end
						
					//  1H  ;  (1H & 9H);  (1H & 3H);  (3H & 9H); (3H & 1H & 9H)
					16'h0002,	16'h0202,	16'h000A,	16'h0028,	16'h002A: // bottom side 
					
						begin
							SM_MOTION <= ENDGAME_ST ;
						end
						
					default:  //complex corner 
					
						begin
							Xspeed <= -Xspeed ;
						end			 

				endcase
				
				hit_reg <= 16'h0000 ;  //clear for next time 
								
				SM_MOTION <= POSITION_CHANGE_ST ; 
				
			end 
			

		//------------
			HIT_ST:  begin
		//------------
				
				collisionMonsterMissile <= 1'b0 ;
				SM_MOTION <= MOVE_ST ;
				
			end
			
		//------------
			ENDGAME_ST:  begin
		//------------
				
				SM_MOTION <= IDLE_ST ;
				
			end
	
		//------------------------
			POSITION_CHANGE_ST : begin  // position interpolate 
		//------------------------
	
				Xposition <= Xposition + Xspeed ;
				Yposition <= Yposition + Yspeed ;
				Yspeed <= INITIAL_Y_SPEED ;
				SM_MOTION <= POSITION_LIMITS_ST ; 
 
			end
		
		//------------------------
			POSITION_LIMITS_ST : begin  //check if still inside the frame 
		//------------------------
		
				if (Xposition < x_FRAME_LEFT) 
					Xposition <= x_FRAME_LEFT ; 
					
				if (Xposition > x_FRAME_RIGHT)
					Xposition <= x_FRAME_RIGHT ;
					
				if (Yposition < y_FRAME_TOP) 
					Yposition <= y_FRAME_TOP ;
					
				if (Yposition > y_FRAME_BOTTOM) 
					Yposition <= y_FRAME_BOTTOM ; 

				SM_MOTION <= MOVE_ST ; 
			
			end
		
		endcase  // case 

	end 

end // end fsm_sync


//return from FIXED point  trunc back to prame size parameters 
  
assign 	topLeftX = Xposition / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
assign 	topLeftY = Yposition / FIXED_POINT_MULTIPLIER ;    
	

endmodule	
//---------------
 
