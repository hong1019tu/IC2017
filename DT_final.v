module DT(clk,reset,done,sti_rd,sti_addr,sti_di,res_wr,res_rd,res_addr,res_do,res_di);
	input 			clk;
	input			reset;
	output	reg		done;
	output	reg		sti_rd;
	output	reg 	[9:0]	sti_addr;
	input		[15:0]	sti_di;
	output	reg		res_wr;
	output	reg		res_rd;
	output	reg 	[13:0]	res_addr;
	output	reg 	[7:0]	res_do;
	input		[7:0]	res_di;
	reg [10:0] x;
	reg fp,bp,process,next;
	reg [3:0] y,load;
	reg [2:0]step;
	reg [7:0]min1;
	reg [7:0] temp[4:0];
always @(posedge clk or negedge reset) begin
	if(!reset)begin
	  process <= 1'd1;
	  done <= 1'd0;
	  sti_rd <= 1'd1;
	  res_wr <= 1'd1;
	  res_rd <= 1'd0;
	  sti_addr <= 10'd0;
	  fp <= 1'd0;
	  bp <= 1'd0;
	  x <= 11'd0;
	  y <= 4'd0;
	  step <= 3'd0;
	  res_addr <= -14'd1;
	end
	else if(done == 1'd0)begin
		if(fp == 1'd0 && bp == 1'd0 )begin
			res_addr <= res_addr + 14'd1;
			if (load == 15) begin
				sti_addr <= sti_addr + 10'd1;
			end	
			if (res_addr == 14'd16383 && next == 1'd1 ) begin
				res_addr <= 14'd0;
				fp <= 1'd1;
				process <= 1'd0;
				res_wr <= 1'd0;
				sti_rd <= 1'd0;
				res_rd <= 1'd1;
			end
		end
		else if (fp == 1'd1 && bp == 1'd0) begin
			res_rd <= 1'd1;
			res_wr <= 1'd0;
			process <= 1'd1;
			if(process == 1'd0)begin
				temp[0] <= res_di;
			end
			else if(process == 1'd1)begin
				step <= step + 3'd1;
				if (temp[0] != 8'd0) begin
					case (step)
						5'd0:begin
							res_addr <= res_addr - 14'd1;
						end
						5'd1:begin
							temp[1] <= res_di;
							res_addr <= res_addr - 14'd126;
						end
						5'd2:begin
							temp[2] <= res_di;
							res_addr <= res_addr - 14'd1;
						end
						5'd3:begin
							temp[3] <= res_di;
							res_addr <= res_addr - 14'd1;
							min1 <= (temp[1]<temp[2])?temp[1]:temp[2];
						end
						5'd4:begin
							temp[4] <= res_di;
							min1 <= (min1<temp[3])?min1:temp[3];
							res_addr <= res_addr + 129;
						end
						5'd5:begin
							min1 <= (min1<temp[4])?min1+1:temp[4]+1;
							res_wr <= 1'd1;
							res_rd <= 1'd0;
							if (x == 11'd1023 && y == 4'd15) begin
							
							end
							else if (y < 4'd15) begin
								y <= y + 4'd1;
							end
							else if (y == 4'd15) begin
								y <= 4'd0;
								x <= x + 11'd1;
							end
						end
						5'd6:begin
							if (x == 11'd1023 && y == 4'd15) begin
								fp <= 1'd0;
								bp <= 1'd1;
							end
							step <= 3'd0;
							process <= 1'd0;
							res_addr <= (x << 4) + y;
						end
					endcase	 
				end
				else begin
					if (step == 3'd0) begin
						if (x == 11'd1023 && y == 4'd15) begin
						fp <= 1'd0;
						bp <= 1'd1;
						step <= 3'd0;
						process <= 1'd0;
					end
					else if (y < 4'd15) begin
						y <= y + 4'd1;
					end
					else if (y == 4'd15) begin
						y <= 4'd0;
						x <= x + 11'd1;
					end
					end
					else if (step == 3'd1) begin
						step <= 3'd0;
						process <= 1'd0;
						res_addr <= (x << 4) + y;
					end	
				end
			end
		end

		else if (bp) begin
			res_rd <= 1'd1;
			res_wr <= 1'd0;
			process <= 1'd1;
			if(process == 1'd0)begin
				temp[0] <= res_di;
			end
			else if(process == 1'd1)begin
				step <= step + 3'd1;
				if (temp[0] != 8'd0) begin
					case (step)
						5'd0:begin
							res_addr <= res_addr + 14'd1;
						end
						5'd1:begin
							temp[1] <= res_di;
							res_addr <= res_addr + 14'd126;
						end
						5'd2:begin
							temp[2] <= res_di;
							res_addr <= res_addr + 14'd1;
							min1 <= (temp[0]<temp[1]+1)?temp[0]:temp[1]+1;
						end
						5'd3:begin
							temp[3] <= res_di;
							res_addr <= res_addr + 14'd1;
							min1 <= (min1<temp[2]+1)?min1:temp[2]+1;
						end
						5'd4:begin
							temp[4] <= res_di;
							min1 <= (min1<temp[3]+1)?min1:temp[3]+1;
							res_addr <= res_addr - 14'd129;
						end
						5'd5:begin
							min1 <= (min1<temp[4]+1)?min1:temp[4]+1;
							res_rd <= 1'd0;
							res_wr <= 1'd1;
							if (x == 11'd0 && y == 5'd0) begin
								
							end
							else if (y > 5'd0) begin
								y <= y - 5'd1;
							end
							else if (y == 5'd0) begin
								y <= 5'd15;
								x <= x - 11'd1;
							end
						end
						5'd6:begin
							if (x == 11'd0 && y == 5'd0) begin
								done <= 1'd1;
							end
							step <= 3'd0;
							process <= 1'd0;
							res_addr <= (x << 4) + y;
						end
					endcase	 
				end
				else begin
					if (step == 3'd0) begin
						if (x == 11'd0 && y == 5'd0) begin
							done <= 1'd1;
						end
						else if (y > 5'd0) begin
							y <= y - 5'd1;
						end
						else if (y == 5'd0) begin
							y <= 5'd15;
							x <= x - 11'd1;
						end
					end
					else if (step == 3'd1) begin
						step <= 3'd0;
						process <= 1'd0;
						res_addr <= (x << 4) + y;	
					end	
				end
		end
	  end
end
end
always @(negedge clk or negedge reset) begin
	if (!reset) begin
		next <= 1'd0;
		load <= 4'd0;
	end
	else if(fp == 0 && bp == 0&& done ==0) begin
		load <= load + 4'd1;
		res_do <= {7'd0,sti_di[15-load]};
		if (load == 4'd15) begin
			next <= 1'd1;
			load <= 4'd0;
		end
	end
	else if (step == 3'd6) begin
		res_do <= min1;
	end
end
endmodule
