
module	SQR_objects_mux	(	 	
			input		logic		clk,
			input		logic		resetN,
			
			input		logic		drawingRequestPlayer,
			input		logic		drawingRequestMonster,
			input		logic		drawingRequestMonsterMissile,
			input		logic		drawingfRequestPlayerMissile,
			input		logic		drawingRequestShields,
			input		logic		drawingRequestLifebar,
			input		logic		[7:0] RGBPlayer,	
			input		logic		[7:0] RGBMonster,
			input		logic		[7:0] RGBBackground,
			input		logic		[7:0] RGBMonsterMissile,
			input		logic		[7:0] RGBPlayerMissile,
			input		logic		[7:0] RGBShields,
			input		logic		[7:0] RGBLifebar,
			input		logic		[7:0] RGBMIF,
			  
		   output	logic		[7:0] RGBOut
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut <= 8'b0 ;
	end
	
	else begin
		if (drawingRequestPlayer == 1'b1) begin
			RGBOut <= RGBPlayer ;  //first priority 
			end
			
		else if (drawingRequestMonster == 1'b1) begin
			RGBOut <= RGBMonster ;
			end
			
		else if (drawingRequestShields == 1'b1) begin
			RGBOut <= RGBShields ;
			end
			
		else if (drawingfRequestPlayerMissile == 1'b1) begin
			RGBOut <= RGBPlayerMissile ;
			end
			
		else if (drawingRequestMonsterMissile == 1'b1) begin
			RGBOut <= RGBMonsterMissile ;
			end
			
		else if (drawingRequestLifebar == 1'b1) begin
			RGBOut <= RGBLifebar ;
			end

		else RGBOut <= RGBBackground ;
	
	end
	
end

endmodule


