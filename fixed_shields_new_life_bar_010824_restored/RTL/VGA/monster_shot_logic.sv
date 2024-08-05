
module	monster_shot_logic	(	
 
		input	 	logic				clk,
		input	 	logic 			resetN,
		input	 	logic 			startOfFrame,      		//short pulse every start of frame 30Hz    
		input  	logic 			collision0,         		//collision if smiley hits an object
		input	 	logic 			collision5,
		input  	logic 			collision9,
		input		logic unsigned	[5:0] random,
		input  	logic signed	[10:0] topLeftXMonster,
		input  	logic signed  	[10:0] topLeftYMonster,
					
		output 	logic signed 	[10:0] topLeftX, 	// output the top left corner 
		output 	logic signed	[10:0] topLeftY  	// can be negative , if the object is partliy outside	
);

const 		int 	X_INITIAL = 0 ;
const			int	Y_INITIAL = 0 ;
parameter	int	Y_SPEED = 100 ;

logic [62:0] [1:0] missile_initial = {
	{4'd0,4'd2},{4'd0,4'd4},{4'd0,4'd5},{4'd0,4'd11},{4'd0,4'd12},{4'd0,4'd14},
	{4'd1,4'd3},{4'd1,4'd6},{4'd1,4'd7},{4'd1,4'd8},{4'd1,4'd9},{4'd1,4'd10},{4'd1,4'd13},
	{4'd2,4'd3},{4'd2,4'd4},{4'd2,4'd7},{4'd2,4'd8},{4'd2,4'd9},{4'd2,4'd12},{4'd2,4'd13},
	{4'd3,4'd4},{4'd3,4'd5},{4'd3,4'd6},{4'd3,4'd7},{4'd3,4'd8},{4'd3,4'd9},{4'd3,4'd10},{4'd3,4'd10},{4'd3,4'd11},{4'd3,4'd12},
	{4'd4,4'd1},{4'd4,4'd5},{4'd4,4'd6},{4'd4,4'd7},{4'd4,4'd8},{4'd4,4'd9},{4'd4,4'd10},{4'd4,4'd11},{4'd4,4'd15},
	{4'd5,4'd1},{4'd5,4'd2},{4'd5,4'd6},{4'd5,4'd7},{4'd5,4'd8},{4'd5,4'd9},{4'd5,4'd10},{4'd5,4'd14},{4'd5,4'd15},
	{4'd6,4'd2},{4'd6,4'd3},{4'd6,4'd5},{4'd6,4'd6},{4'd6,4'd10},{4'd6,4'd11},{4'd6,4'd13},{4'd6,4'd14},
	{4'd7,4'd4},{4'd7,4'd5},{4'd7,4'd6},{4'd7,4'd7},{4'd7,4'd9},{4'd7,4'd10},{4'd7,4'd11},{4'd7,4'd12}};
const		int	MULTI = 32 ;

const 	int	FIXED_POINT_MULTIPLIER = 64 ; // note it must be 2^n 
// FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that 
// we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calcuatuions,
// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions

// movement limits 
const 	int  	OBJECT_WIDTH_X = 2 ;
const 	int  	OBJECT_HIGHT_Y = 4 ;
const 	int	SafetyMargin   = 2 ;

const 	int	x_FRAME_LEFT	=	(SafetyMargin )* FIXED_POINT_MULTIPLIER ; 
const 	int	x_FRAME_RIGHT	=	(639 - SafetyMargin - OBJECT_WIDTH_X) * FIXED_POINT_MULTIPLIER ; 
const 	int	y_FRAME_TOP		=	(SafetyMargin) * FIXED_POINT_MULTIPLIER ;
const 	int	y_FRAME_BOTTOM	=	(479 - SafetyMargin - OBJECT_HIGHT_Y ) * FIXED_POINT_MULTIPLIER ; //- OBJECT_HIGHT_Y

enum  	logic [2:0] {IDLE_ST,         	// initial state
						 MOVE_ST, 					// moving no colision 
						 START_OF_FRAME_ST, 	   // startOfFrame activity-after all data collected 
						 HIT_ST,
						 ENDGAME_ST,
						 POSITION_CHANGE_ST,		// position interpolate 
						 POSITION_LIMITS_ST  	// check if inside the frame  
						}  SM_MOTION ;
  
int 	Yspeed  ;
int	Xposition ;	//position   
int 	Yposition ;  

logic collision ;
logic enable ;

//---------
always_ff @(posedge clk or negedge resetN)
begin : fsm_sync_proc

	if (resetN == 1'b0) begin 
		SM_MOTION <= IDLE_ST ;  
		Yspeed <= 0 ;
		Xposition <= 0 ; 
		Yposition <= 0 ; 
		enable <= 0 ;
		collision <= 0;	
	end 	
	
	else begin

		case(SM_MOTION)
		
		//------------
			IDLE_ST: begin
		//------------
				Yspeed  <= Y_INITIAL ;
				Xposition <= X_INITIAL ; 
				Yposition <= Y_INITIAL ; 
				enable <= 1'b1 ;
				collision <= 0 ;
				if (startOfFrame) 
					SM_MOTION <= MOVE_ST ;
			end
	
		//------------
			MOVE_ST:  begin     // moving no collision 
		//------------
      // collecting collisions
		
				if(enable) begin
					Xposition <= (missile_initial[random][0]*MULTI + topLeftXMonster)* FIXED_POINT_MULTIPLIER ;
					Yposition <= (missile_initial[random][1]*MULTI + topLeftYMonster)* FIXED_POINT_MULTIPLIER ;
					Yspeed <= Y_SPEED * FIXED_POINT_MULTIPLIER ; 
					enable <= 1'b0 ;
				end

				if ( collision0 || collision5 || collision9 ) begin
				collision <= 1 ;	
				end
				
				if (startOfFrame)
					SM_MOTION <= START_OF_FRAME_ST ; 
			end 
		
		//------------
			START_OF_FRAME_ST:  begin      //check if any colisin was detected 
		//------------
			
				if (collision) begin
					Xposition <= X_INITIAL ;
					Yposition <= Y_INITIAL ;
					Yspeed <= Y_INITIAL;
					enable <= 1'b1 ;
				end
				
				SM_MOTION <= POSITION_CHANGE_ST ; 
				
			end 
	
		//------------------------
			POSITION_CHANGE_ST : begin  // position interpolate 
		//------------------------
		
				Yposition <= Yposition + Yspeed ;
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
 
