/*
本实验实现一个能显示小时，分钟，秒的数字时钟。
*/
module clock(clk,rst,dataout,en);

input clk,rst;
output[7:0] dataout;
reg[7:0] dataout;
output[7:0] en;
reg[7:0] en;

reg[3:0] dataout_buf[7:0];
reg[25:0] cnt;
reg[15:0] cnt_scan;
reg[3:0] dataout_code;

wire[5:0] cal; //各级进位标志
assign cal[0]=(dataout_buf[0]==9)?1:0;
assign cal[1]=(cal[0]&&dataout_buf[1]==5)?1:0;
assign cal[2]=(cal[1]&&dataout_buf[3]==9)?1:0;
assign cal[3]=(cal[2]&&dataout_buf[4]==5)?1:0;
assign cal[4]=(cal[3]&&dataout_buf[6]==9)?1:0;
assign cal[5]=(cal[3]&&dataout_buf[6]==2&&dataout_buf[7]==1)?1:0;

always@(posedge clk or negedge rst)
begin
	if(!rst) begin
		 cnt_scan<=0;
		 en<=8'b1111_1110;
	 end
	else begin
		cnt_scan<=cnt_scan+1;
		if(cnt_scan==16'hffff) begin 
			en[7:1]<=en[6:0];
			en[0]<=en[7];
		 end
	 end
end

always@(*)
begin
	case(en)
		8'b1111_1110:
			dataout_code=dataout_buf[0];
		8'b1111_1101:
			dataout_code=dataout_buf[1];
		8'b1111_1011:
			dataout_code=dataout_buf[2];
		8'b1111_0111:
			dataout_code=dataout_buf[3];
		8'b1110_1111:
			dataout_code=dataout_buf[4];
		8'b1101_1111:
			dataout_code=dataout_buf[5];
		8'b1011_1111:
			dataout_code=dataout_buf[6];
		8'b0111_1111:
			dataout_code=dataout_buf[7];
		default:
			dataout_code=dataout_buf[0];
	 endcase
end

always@(posedge clk or negedge rst)
begin
	if(!rst) 
		cnt<=0;
	else if(cnt!=40000000)
		cnt<=cnt+1;
	else
		cnt<=0;
end

always@(posedge clk or negedge rst)   //实现计数和进位的功能
begin
	if(!rst) begin
		dataout_buf[0]<=0;
		dataout_buf[1]<=0;
		dataout_buf[2]<=15;
		dataout_buf[3]<=0;
		dataout_buf[4]<=0;
		dataout_buf[5]<=15;
		dataout_buf[6]<=2;
		dataout_buf[7]<=1;
	 end
	else begin
		if(cnt==26'd40000000) begin
			if(!cal[0]) 
				dataout_buf[0]<=dataout_buf[0]+1;
			else begin
				dataout_buf[0]<=0;
				if(!cal[1])
					dataout_buf[1]<=dataout_buf[1]+1;
				else begin
					dataout_buf[1]<=0;
					if(!cal[2])
						dataout_buf[3]<=dataout_buf[3]+1;
					else begin
						dataout_buf[3]<=0;
						if(!cal[3])
							dataout_buf[4]<=dataout_buf[4]+1;
						else begin
							dataout_buf[4]<=0;
							if(!cal[4])
								dataout_buf[6]<=dataout_buf[6]+1;
							else begin
								dataout_buf[6]<=0;
								if(!cal[5])
									dataout_buf[7]<=dataout_buf[7]+1;
								else
									dataout_buf[7]<=0;
							 end
						 end
					end
				end
			end
		end
	end
end

always@(dataout_code)
begin
	case(dataout_code)
		4'b0000:
			dataout=8'b1100_0000;
		4'b0001:
			dataout=8'b1111_1001;
		4'b0010:
			dataout=8'b1010_0100;
		4'b0011:
			dataout=8'b1011_0000;
		4'b0100:
			dataout=8'b1001_1001;
		4'b0101:
			dataout=8'b1001_0010;
		4'b0110:
			dataout=8'b1000_0010;
		4'b0111:
			dataout=8'b1111_1000;
		4'b1000:
			dataout=8'b1000_0000;
		
	 endcase
end

endmodule 
						
			

	