module router_synchronizer (
	input clk,rstn,
	input write_en_reg,detect_addr,
	input re0,re1,re2,
	input full0,full1,full2,
	input empty0,empty1,empty2,
	input [1:0] data_in,
	output reg [2:0] write_en,
	output reg fifo_full,
	output vld0,vld1,vld2,
	output reg sft_rst0,sft_rst1,sft_rst2);

reg [1:0] addr;
always @(posedge clk)
begin
	if(rstn == 1'b0)
		addr <= 2'dz;
	else if (detect_addr == 1'b1)
		addr <= data_in;
end

always @(*)
begin
	if(write_en_reg == 1'b1)
	begin
		case(addr)
			2'b00 : write_en = 3'b001;
			2'b01 : write_en = 3'b010;
			2'b10 : write_en = 3'b100;
			default : write_en = 3'b000;
		endcase
	end
	else 
		write_en = 3'b000;
end

always @(*)
begin
	case(addr)
		2'b00 : fifo_full = full0;
		2'b01 : fifo_full = full1;
		2'b10 : fifo_full = full2;
		default : fifo_full = 1'b0;
	endcase
end

assign vld0 = (~empty0);
assign vld1 = (~empty1);
assign vld2 = (~empty2);

reg [4:0] count1;
always @(posedge clk)
begin
	if(rstn == 1'b0)
	begin
		count1 <= 5'd0;
		sft_rst0 <= 1'd0;
	end
	else if (vld0 == 1'b0)
	begin
		count1 <= 5'd0;
		sft_rst0 <= 1'd0;
	end
	else if (re0 == 1'b1)
	begin
		count1 <= 5'd0;
		sft_rst0 <= 1'd0;
	end
	else
		begin
		if(count1 == 5'd29)
		begin
			count1 <= 5'd0;
			sft_rst0 <= 1'b1;
		end
		else
			count1 <= count1 + 1'b1;
		end
end

reg [4:0] count2;
always @(posedge clk)
begin
	if(rstn == 1'b0)
	begin
		count2 <= 5'd0;
		sft_rst1 <= 1'd0;
	end
	else if (vld1 == 1'b0)
	begin
		count2 <= 5'd0;
		sft_rst1 <= 1'd0;
	end
	else if (re1 == 1'b1)
	begin
		count2 <= 5'd0;
		sft_rst1 <= 1'd0;
	end
	else
		begin
		if(count2 == 5'd29)
		begin
			count2 <= 5'd0;
			sft_rst1 <= 1'b1;
		end
		else
			count2 <= count2 + 1'b1;
		end
end

reg [4:0] count3;
always @(posedge clk)
begin
	if(rstn == 1'b0)
	begin
		count3 <= 5'd0;
		sft_rst2 <= 1'd0;
	end
	else if (vld2 == 1'b0)
	begin
		count3 <= 5'd0;
		sft_rst2 <= 1'd0;
	end
	else if (re2 == 1'b1)
	begin
		count3 <= 5'd0;
		sft_rst2 <= 1'd0;
	end
	else
		begin
		if(count3 == 5'd29)
		begin
			count3 <= 5'd0;
			sft_rst2 <= 1'b1;
		end
		else
			count3 <= count3 + 1'b1;
		end
end

endmodule