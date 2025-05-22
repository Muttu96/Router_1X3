module router_fsm_tb();
	reg clk,rstn,pkt_valid,parity_done,sft_rst0,sft_rst1,sft_rst2,fifo_full,low_pkt_valid,fifo_empty0,fifo_empty1,fifo_empty2;
	reg [1:0]data_in;
	wire busy,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state;

parameter DECODE_ADDR = 3'b000,
	LOAD_FIRST_DATA = 3'b001,
	LOAD_DATA = 3'b010,
	LOAD_PARITY = 3'b011,
	CHECK_PARITY_ERROR = 3'b100,
	FIFO_FULL_STATE = 3'b101,
	LOAD_AFTER_FULL = 3'b110,
	WAIT_TILL_EMPTY = 3'b111;


router_fsm DUT (.clk(clk), .rstn(rstn), .pkt_valid(pkt_valid), .parity_done(parity_done), .sft_rst0(sft_rst0), .sft_rst1(sft_rst1), .sft_rst2(sft_rst2),
		.fifo_full(fifo_full), .low_pkt_valid(low_pkt_valid), .fifo_empty0(fifo_empty0), .fifo_empty1(fifo_empty1), .fifo_empty2(fifo_empty2),
		.data_in(data_in), .busy(busy), .detect_add(detect_add), .ld_state(ld_state), .laf_state(laf_state), .full_state(full_state), 
		.write_enb_reg(write_enb_reg), .rst_int_reg(rst_int_reg), .lfd_state(lfd_state));

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

task t1;
	begin
		@(negedge clk)
		pkt_valid = 1'b1;
		data_in = 2'b01;
		fifo_empty1 = 1'b1;
		@(negedge clk)
		@(negedge clk)
		fifo_full = 1'b0;
		pkt_valid = 1'b0;
		@(negedge clk)
		@(negedge clk)
		fifo_full = 1'b0;
	end
endtask

task t2;
	begin
		@(negedge clk)
		pkt_valid = 1'b1;
		data_in = 2'b01;
		fifo_empty1 = 1'b1;
		@(negedge clk)
		@(negedge clk)
		fifo_full = 1'b1;
		@(negedge clk)
		fifo_full = 1'b0;
		@(negedge clk)
		parity_done = 1'b0;
		low_pkt_valid = 1'b1;
		@(negedge clk)
		@(negedge clk)
		fifo_full = 1'b0;
	end
endtask

task t3;
	begin
		@(negedge clk)
		pkt_valid = 1'b1;
		data_in = 2'b01;
		fifo_empty1 = 1'b1;
		@(negedge clk)
		@(negedge clk)
		fifo_full =1'b1;
		@(negedge clk)
		fifo_full = 1'b0;
		@(negedge clk)
		parity_done = 1'b0;
		low_pkt_valid = 1'b0;
		@(negedge clk)
		fifo_full = 1'b0;
		pkt_valid = 1'b0;
		@(negedge clk)
		@(negedge clk)
		fifo_full = 1'b0;
	end
endtask

task t4;
	begin
		@(negedge clk)
		pkt_valid = 1'b1;
		data_in = 2'b01;
		fifo_empty1 = 1'b1;
		@(negedge clk)
		@(negedge clk)
		fifo_full = 1'b0;
		pkt_valid = 1'b0;
		@(negedge clk)
		@(negedge clk)
		fifo_full = 1'b1;
		@(negedge clk)
		fifo_full = 1'b0;
		@(negedge clk)
		parity_done = 1'b1;
	end
endtask

initial
begin
	rstn =  1'b0;
	{pkt_valid,parity_done,sft_rst0,sft_rst1,sft_rst2,fifo_full,low_pkt_valid,fifo_empty0,fifo_empty1,fifo_empty2} = 0;
	resetn;
	t1;
	t2;
	t3;
	t4;
end

endmodule