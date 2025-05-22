module router_fifo(clock,reset_n,soft_reset,write_en,read_en,data_in,lfd_state,empty,full,data_out);

input clock,reset_n,soft_reset,write_en,read_en,lfd_state;
input [7:0]data_in;
output empty,full;
output reg [7:0]data_out;

reg [8:0]fifo_mem[0:15];
reg [4:0]wptr,rptr;
reg [5:0]temp;
reg lfd_s;
integer i;

assign full = (wptr == {~rptr[4],rptr[3:0]})? 1'b1 : 1'b0;
//assign full = (wptr == 5'd16 && rptr == 5'd0)? 1'b1 : 1'b0;
assign empty = (rptr == wptr)? 1'b1 : 1'b0;


always @ (posedge clock)
begin
	if(reset_n == 1'b0)
		lfd_s <= 1'b0;
	else if (soft_reset == 1'b1)
		lfd_s <= 1'd0;
	else 
		lfd_s <= lfd_state;
end

always @(posedge clock)
begin
	if(reset_n == 1'b0)
	begin
	    wptr <= 5'd0;
		for(i=0;i<16;i=i+1)
		begin
			fifo_mem[i] <= 9'd0;
		end
	end
	else if (soft_reset == 1'b1)
	begin
	    wptr <= 5'd0;
		for(i=0;i<16;i=i+1)
		begin
			fifo_mem[i] <= 9'd0;
		end
	end
	else if (write_en == 1'b1 && full == 1'b0)
	begin
		fifo_mem[wptr[3:0]] <= {lfd_s,data_in};
		wptr <= wptr + 1'b1;
	end
end

always @(posedge clock)
begin
	if(reset_n == 1'b0)
	begin
		data_out <= 8'd0;
		rptr <= 5'd0;
	end
	else if(soft_reset == 1'b1)
	begin
		data_out <= 8'dz;
		//rptr <= 5'd0;
	end
	else if (temp == 6'd0)
		data_out <= 8'dz;
	else if (read_en == 1'b1 && empty == 1'b0)
	begin
		data_out <= fifo_mem[rptr[3:0]][7:0];
		rptr <= rptr + 1'b1;	
	end
end

always @ (posedge clock)
begin
	if (reset_n == 1'b0)
		temp <= 6'd0; 
	else if (soft_reset == 1'b1)
		temp <= 6'd0;
	else if(empty == 1'b0 && read_en==1'b1)
	begin
		if(fifo_mem[rptr[4]][8] == 1'b1)
			temp <= fifo_mem[rptr[4]][7:2]+1'b1;
	   else if(temp != 6'd0)
			temp <= temp - 1'b1;
	end
end

endmodule