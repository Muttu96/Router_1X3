module router_fifo_tb();
reg clock,reset_n,soft_reset,write_en,read_en,lfd_state;
reg [7:0]data_in;
wire full,empty;
wire [7:0]data_out;

integer k;

router_fifo DUT (.clock(clock), .reset_n(reset_n), .soft_reset(soft_reset),
					.write_en(write_en), .read_en(read_en), .data_in(data_in), 
					.lfd_state(lfd_state),.empty(empty), .full(full), .data_out(data_out));

initial 
begin
	clock = 1'b0;
	forever #5 clock = ~clock;
end

task rst;
	begin
		@(negedge clock)
		reset_n = 1'b0;
		@(negedge clock)
		reset_n = 1'b1;
	end
endtask

task sft_rst;
	begin
		@(negedge clock)
		soft_reset = 1'b1;
		@(negedge clock)
		soft_reset = 1'b0;
	end
endtask

task write;
	reg [7:0]payload_data,parity,header;
	reg [5:0]payload_len;
	reg [1:0]addr;

	begin
		@(negedge clock)
		payload_len = 6'd14;
		addr = 2'b01;
		header = {payload_len,addr};
		data_in = header;
		//parity = 1'b0 ^ header;
		lfd_state = 1'b1;
		write_en = 1'b1;
		for(k=0; k<payload_len; k=k+1)
		begin
			@(negedge clock)
			lfd_state = 1'b0;
			payload_data = {$random}%256;
			data_in = payload_data;
			//parity = parity ^payload_data;
		end
		@(negedge clock)
		parity = {$random}%256;
		data_in = parity;
		@(negedge clock)
		write_en = 1'b0;
	end
endtask

task read_data;
	begin
		@(negedge clock)
		read_en = 1'b1;
		repeat(16) @(negedge clock)
		@(negedge clock);
		//read_en = 1'b0;
	end
endtask

initial 
begin
	reset_n = 1'b0;
	soft_reset = 1'b1;
	write_en = 1'b0;
	read_en  = 1'b0;
	lfd_state = 1'b0;
	data_in = 8'd0;

	rst;
	sft_rst;
	write;
	read_data;
	rst;
end

endmodule