
module	game_controller	(	
		input		logic		clk,
		input		logic		resetN,
		input		logic		startOfFrame,  // short pulse every start of frame 30Hz 
		input		logic		drawingRequestPlayer,
		input		logic		drawingRequestMonster,
		input		logic		drawingRequestPlayerMissile,
		input		logic		drawingRequestMonsterMissile,
		input		logic		drawingRequestShields,
		input 	logic 	drawingRequestBoarders,
	
		output	logic		[9:0] collision // active in case of collision between two objects
			
);

assign	collision[0] = (drawingRequestPlayer && drawingRequestMonsterMissile) ;
assign	collision[1] = (drawingRequestPlayer && drawingRequestMonster) ;
assign	collision[2] = (drawingRequestMonster && drawingRequestPlayerMissile) ;
assign	collision[3] = (drawingRequestMonster && drawingRequestShields) ;
assign	collision[4] = (drawingRequestShields && drawingRequestPlayerMissile) ;
assign	collision[5] = (drawingRequestShields && drawingRequestMonsterMissile) ;
assign	collision[6] = (drawingRequestBoarders && drawingRequestPlayer) ;
assign	collision[7] = (drawingRequestBoarders && drawingRequestMonster) ;
assign	collision[8] = (drawingRequestBoarders && drawingRequestPlayerMissile) ;
assign	collision[9] = (drawingRequestBoarders && drawingRequestMonsterMissile) ;

endmodule
