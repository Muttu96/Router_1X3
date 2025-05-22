module router_register(
	input clk,rstn,
	input pkt_valid,fifo_full,rst_int_reg,detect_addr,ld_state,laf_state,full_state,lfd_state,
	input [7:0] data_in,
	output reg parity_done,low_pkt_valid,error,
	output reg [7:0] data_out);

reg [7:0] header_reg;
reg [7:0] fifo_full_reg;
reg [7:0] packet_parity_reg;
reg [7:0] internal_parity_reg;


//header_reg logic
always @(posedge clk)
begin
	if(rstn == 1'b0)
		header_reg <= 0;
	else if((detect_addr && pkt_valid && data_in[1:0] != 3))
		header_reg <= data_in;
	else
		header_reg <= header_reg;
end


//fifo_full_reg logic
/*always @ (posedge clk)
begin
	if(rstn == 1'b0)
		fifo_full_reg <= 0;
	else if (ld_state && fifo_full)
		fifo_full_reg <= data_in;
	else 
		fifo_full_reg <= fifo_full_reg;
		
end*/


//internal_parity_reg logic
always @(posedge clk)
begin
	if(rstn == 1'b0)
		internal_parity_reg <= 0;
	else if(detect_addr == 1'b1)
		internal_parity_reg <= 0;
	else if (lfd_state == 1'b1)
		internal_parity_reg <= internal_parity_reg ^ header_reg;
	else if ((pkt_valid && ld_state && !full_state))
		internal_parity_reg <= internal_parity_reg ^ data_in;
	else 
		internal_parity_reg <= internal_parity_reg;
end


//packet_parity_reg logic
always @(posedge clk)
begin
	if(rstn == 1'b0)
		packet_parity_reg <= 0;
	else if (detect_addr == 1'b1)
		packet_parity_reg <= 0;
	else if (ld_state  && !pkt_valid)
		packet_parity_reg <= data_in;
	else 
		packet_parity_reg <= packet_parity_reg;
end


//data_out logic
always@(posedge clk)
begin
	if(rstn == 1'b0)
	begin
		data_out <= 0;
		fifo_full_reg <= 0;
	end
	else if(detect_addr && pkt_valid)
		data_out <= data_out;
	else if(lfd_state == 1'b1)
		data_out <= header_reg;
	else if (ld_state && ~fifo_full)
		data_out <= data_in;
	else if (ld_state && fifo_full)
		fifo_full_reg <= data_in;
	else if (laf_state )
		data_out <= fifo_full_reg;
	else 
		data_out <= data_out;
end


//parity_done logic 
always @(posedge clk)
begin
	if(rstn == 1'b0)
		parity_done <= 1'b0;
	else if(detect_addr == 1'b1)
		parity_done <= 1'b0;
	else if ((ld_state && !fifo_full && !pkt_valid) || (laf_state && low_pkt_valid && !parity_done))
		parity_done <= 1'b1;
	//else if (laf_state && low_pkt_valid && !parity_done)
		//parity_done <= 1;
	//else
		//parity_done <= parity_done;
end

//low_pkt_valid logic
always @ (posedge clk)
begin
	if (rstn == 1'b0)
		low_pkt_valid <= 0;
	else if (rst_int_reg == 1'b1)
		low_pkt_valid <= 0;
	else if (ld_state && !pkt_valid)
		low_pkt_valid <= 1;
	else 
		low_pkt_valid <= 1'b0;
end

//error logic
always @(posedge clk)
begin
	if(rstn == 1'b0)
		error <= 1'b0;
	else if ((packet_parity_reg != internal_parity_reg) && (parity_done))
		error <= 1'b1;
	else 
		error <= 1'b0;
end

endmodule