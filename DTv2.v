module DT(
	input 			clk, 
	input			reset,
	output	reg		done ,
	output	reg		sti_rd ,
	output	wire 	[9:0]	sti_addr ,
	input		[15:0]	sti_di,
	output	reg		res_wr ,
	output	reg		res_rd ,
	output	reg 	[13:0]	res_addr ,
	output	reg 	[7:0]	res_do,
	input		[7:0]	res_di
	);

//**********************//
reg [7:0] sub [4:0];
reg [4:0] state,nextstate;
reg [13:0] sub_addr;
reg [13:0] fixed_addr;
reg bk;
//reg [9:0] rom_id;
wire [4:0] data_id;
wire [7:0] min_f0,min_f1,min_f,min_b;
//Comparison for forward
assign min_f0=(sub[0]>=sub[1])?sub[1]:sub[0];
assign min_f1=(sub[2]>=sub[3])?sub[3]:sub[2];
assign min_f=(min_f0>=min_f1)?min_f1:min_f0;
//Addition comparison in backward
assign min_b=(sub[4]>=min_f+1)?min_f+1:sub[4];


//deciding the input address,  ex: sub_addr=110 >> rom_id=6(110) , data_id=15(1110) ; sub_addr=258(10000 0010) >> rom_id=16(10000) , data_id=2(0010)
assign sti_addr=sub_addr[13:4];
assign data_id=15-sub_addr[3:0];

//assign res_addr=fixed_addr+5;

always@(*)begin
	case(state)
		0:	nextstate = 1 ;
		1:	nextstate = 2 ;
		2:	nextstate = 3 ;
		3:	nextstate = 4 ;
		4:	nextstate = 5 ;
		5:	nextstate = 6 ;
		6:	begin
				if(!bk)begin
					if(fixed_addr[6:0]==125)begin
						nextstate=0;
					end
					else begin
						nextstate=7;
					end
				end
				else begin
					if(fixed_addr[6:0]==2)begin
						nextstate=0;
					end
					else begin
						nextstate=7;
					end
				end
			end
		7:	nextstate = 8;
		8:	nextstate = 5;
		default: nextstate = 0;
	endcase
end


always@(posedge clk or negedge reset)
begin
	if(!reset)begin
		done<=0;
		bk<=0;
		sti_rd<=1;
		sub_addr<=0;
		fixed_addr<=0;
		res_wr<=0;
		res_rd<=1;
		state<=3;
		sub[0]<=0;
		sub[1]<=0;
		sub[2]<=0;
	end
	else begin
		state <= nextstate;
		case(state)
			0:	begin
					sub[0]<=res_di;
					if(!bk)
						res_addr<=fixed_addr+1;
					else
						res_addr<=fixed_addr-1;
				end
			1:	begin
					sub[1]<=res_di;
					if(!bk)
						res_addr<=fixed_addr+2;
					else
						res_addr<=fixed_addr-2;
				end
			2:	begin
					sub[2]<=res_di;
					if(!bk)
						sub_addr<=fixed_addr+128;
					else
						res_addr<=fixed_addr-128;
				end
			3:	begin
					
					if(!bk)begin
						sub_addr<=fixed_addr+129;
						sub[3]<=sti_di[data_id];
					end
					else begin
						res_addr<=fixed_addr-129;
						sub[3]<=res_di;
					end
				end
			4:	begin
					
					if(!bk)
						sub[4]<=sti_di[data_id];
					else
						sub[4]<=res_di;
					//sub_addr<=fixed_addr+130;
				end
			//Output state for forward;
			5:	begin
					
					
					if(sub[4]!=0)begin
						if(!bk)begin
							res_addr<=fixed_addr+129;
							sub[4]<=min_f+1;
							res_do<=min_f+1;
							
						end
						else begin
							res_addr<=fixed_addr-129;
							sub[4]<=min_b;
							res_do<=min_b;
						end
						res_wr<=1;
					end
					
					
					
				end
			//Decide where to go
			6:	begin
					//sub[3]<=min_f+1;
					res_wr<=0;
					if(!bk)begin
						if(fixed_addr[6:0]==125)begin
							if(fixed_addr==16253)begin
								//done<=1;
								sti_rd<=0;
								bk<=1;
							end
							fixed_addr<=fixed_addr+3;
							res_addr<=fixed_addr+3;
						end
						else begin
							fixed_addr<=fixed_addr+1;
							res_addr<=fixed_addr+3;
						end
					end
					else begin
						if(fixed_addr[6:0]==2)begin
							if(fixed_addr==2)begin
								done<=1;
								sti_rd<=0;
								res_rd<=0;
							end
							fixed_addr<=fixed_addr-3;
							res_addr<=fixed_addr-3;
						end
						else begin
							fixed_addr<=fixed_addr-1;
							res_addr<=fixed_addr-3;
						end

					end
					
				end
			7:	begin
					
					sub[2]<=res_di;
					if(!bk)
						sub_addr<=fixed_addr+129;
					else
						res_addr<=fixed_addr-129;

					sub[0]<=sub[1];
					sub[1]<=sub[2];
					sub[3]<=sub[4];
					
				end
			8:	begin
					if(!bk)
						sub[4]<=sti_di[data_id];
					else
						sub[4]<=res_di;
				end
			9:	begin
				
				end
				
	default: 	begin

				end			
		endcase
	end


end


endmodule

