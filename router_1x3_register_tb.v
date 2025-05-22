module router_register_tb();
	reg clk,rstn;
	reg pkt_valid,fifo_full,rst_int_reg,detect_addr,ld_state,laf_state,full_state,lfd_state;
	reg [7:0] data_in;
	wire parity_done,low_pkt_valid;
	wire error;
	wire [7:0] data_out;

	integer i;

router_register DUT (.clk(clk), .rstn(rstn), .pkt_valid(pkt_valid), .fifo_full(fifo_full), 
		    .rst_int_reg(rst_int_reg), .detect_addr(detect_addr), .ld_state(ld_state),
		    .laf_state(laf_state), .full_state(full_state), .lfd_state(lfd_state), .data_in(data_in),
		    .parity_done(parity_done), .low_pkt_valid(low_pkt_valid), .error(error), .data_out(data_out));


initial 
begin
	clk = 1'b0;
	forever #5 clk = ~clk;
end

task resetn;
	begin
		@(negedge clk)
		rstn = 1'b0;
		@(negedge clk)
		rstn = 1'b1;
	end
endtask

task packet_generation;
	reg [7:0] payload_data,parity,header;
	reg [5:0]payload_len;
	reg [1:0]addr;
	begin
		@(negedge clk)
		payload_len = 6'd5;
		addr = 2'b10;
		pkt_valid = 1'b1;
		detect_addr = 1'b1;
		header = {payload_len , addr};
		parity = 8'h00 ^ header;
		@(negedge clk)
		detect_addr = 1'b0;
		lfd_state = 1'b1;
		full_state = 1'b0;
		fifo_full = 1'b0;
		laf_state = 1'b0;
		for(i=0 ; i<payload_len ; i = i+1)
		begin
			@(negedge clk)
			lfd_state = 1'b0;
			ld_state = 1'b1;
			payload_data = {$random} % 256;
			data_in = payload_data;
			parity = parity ^ data_in;
		end
		@(negedge clk)
		pkt_valid = 1'b0;
		//data_in = parity;
		data_in = 8'b1010101;
		@(negedge clk)
		ld_state = 1'b0;
	end
endtask

initial
begin
	{ pkt_valid,fifo_full,rst_int_reg,detect_addr,ld_state,laf_state,full_state,lfd_state } = 0;
	resetn;
	packet_generation;
end

endmodule