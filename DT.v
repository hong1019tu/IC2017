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
	reg  [7:0]temp [16383:0];
	reg [10:0] load,x;
	reg fp,bp,finish;
	reg [4:0] y,step;
	reg [20:0] addr,addr1;
	reg [7:0]min1,min2;

always @(*) begin
		addr1 = sti_addr * 16;
		addr = x * 16 + y;
end
always @(posedge clk or negedge reset) begin
	if(!reset)begin
	  //done <= 1'd0;
	  sti_rd <= 1'd0;
	  res_wr <= 1'd0;
	  res_rd <= 1'd0;
	  sti_addr <= -10'd1;
	  load <= 11'd0;
	  fp <= 1'd1;
	  bp <= 1'd0;
	  x <= 11'd0;
	  y <= 5'd0;
	  step <= 5'd0;
	  res_addr <= 14'd0;
	  finish <= 1'd0;
	end
	else begin
		if (load <= 11'd1024 ||  fp == 1'd1) begin
			if(load <= 11'd1024)begin
				sti_rd <= 1'd1;
				load <= load + 11'd1;
				sti_addr <= sti_addr + 10'd1;
				temp[addr1] <= {7'd0,sti_di[15]};
				temp[addr1+1] <= {7'd0,sti_di[14]};
				temp[addr1+2] <= {7'd0,sti_di[13]};
				temp[addr1+3] <= {7'd0,sti_di[12]};
				temp[addr1+4] <= {7'd0,sti_di[11]};
				temp[addr1+5] <= {7'd0,sti_di[10]};
				temp[addr1+6] <= {7'd0,sti_di[9]};
				temp[addr1+7] <= {7'd0,sti_di[8]};
				temp[addr1+8] <= {7'd0,sti_di[7]};
				temp[addr1+9] <= {7'd0,sti_di[6]};
				temp[addr1+10] <= {7'd0,sti_di[5]};
				temp[addr1+11] <= {7'd0,sti_di[4]};
				temp[addr1+12] <= {7'd0,sti_di[3]};
				temp[addr1+13] <= {7'd0,sti_di[2]};
				temp[addr1+14] <= {7'd0,sti_di[1]};
				temp[addr1+15] <= {7'd0,sti_di[0]};
			end
			else if (temp[addr] != 8'd0) begin
				step <= step + 5'd1;
				case (step)
					5'd0:begin
					min1 <= (temp[addr-1]<temp[addr-129])?temp[addr-1]:temp[addr-129];
					min2 <= (temp[addr-128]<temp[addr-127])?temp[addr-128]:temp[addr-127];
					end 
					5'd1:begin
					min1 <= (min1 < min2)?min1:min2;
					end
					5'd2:begin
						step <= 5'd0;
						temp[addr] <= min1 + 8'd1;
						if (x == 11'd1023 && y == 5'd15) begin
							fp <= 1'd0;
							bp <= 1'd1;
							res_rd <= 1'd1;
							res_wr <= 1'd1;
						end
						else if (y < 5'd15) begin
							y <= y + 5'd1;
						end
						else if (y == 5'd15) begin
							y <= 5'd0;
							x <= x + 11'd1;
						end
					end 
				endcase
			end
			else begin
				if (x == 11'd1023 && y == 5'd15) begin
					fp <= 1'd0;
					bp <= 1'd1;
					res_rd <= 1'd1;
					res_wr <= 1'd1;
				end
				else if (y < 5'd15) begin
					y <= y + 5'd1;
				end
				else if (y == 5'd15) begin
					y <= 5'd0;
					x <= x + 11'd1;
				end
			end
			end 

		else if (bp) begin
			if (temp[addr] != 8'd0) begin
				step <= step + 5'd1;
				case (step)
					5'd0:begin
					min1 <= (temp[addr+1]+1<temp[addr+129]+1)?temp[addr+1]+1:temp[addr+129]+1;
					min2 <= (temp[addr+128]+1<temp[addr+127]+1)?temp[addr+128]+1:temp[addr+127]+1;
					end 
					5'd1:begin
					min1 <= (min1 < min2)?min1:min2;
					end
					5'd2:begin
					min1 <= (min1<temp[addr])?min1:temp[addr];
					res_rd <= 1'd1;
					res_wr <= 1'd1;
					end
					5'd3:begin
						step <= 5'd0;
						finish <= 1'd1;
						temp[addr] <= min1;
						res_addr <= res_addr - 14'd1;
						if (x == 11'd0 && y == 5'd0) begin
							fp <= 1'd0;
							bp <= 1'd0;
						end
						else if (y > 5'd0) begin
							y <= y - 5'd1;
						end
						else if (y == 5'd0) begin
							y <= 5'd15;
							x <= x - 11'd1;
						end
					end 
				endcase
			end
			else begin
				finish <= 1'd1;
				res_addr <= res_addr - 14'd1;
				if (x == 11'd0 && y == 5'd0) begin
					fp <= 1'd0;
					bp <= 1'd0;
				end 
				else if (y > 5'd0) begin
				y <= y - 5'd1;
				end
				else if (y == 5'd0) begin
				y <= 5'd15;
				x <= x - 11'd1;
				end
			end 
		end
	  end
end

always @(negedge clk) begin
	if (!fp) begin
		res_do = temp[res_addr];
	end
end

always @(*) begin
	if (res_addr == 14'd0 && finish == 1'd1) begin
				done = 1'd1;
			end
	else begin
		done = 1'd0;
	end
end
endmodule
