
`timescale 1ps/1fs

module router_1X3_tb();
reg clk, rstn;
reg read_en0, read_en1, read_en2;
reg [7:0] data_in;
reg pkt_valid;
wire [7:0] data_out0, data_out1, data_out2;
wire vld_out0, vld_out1, vld_out2;
wire error, busy;
integer k;

router_1X3 DUT(.clk(clk), .rstn(rstn), .read_en0(read_en0), .read_en1(read_en1), .read_en2(read_en2), .data_in(data_in), .pkt_valid(pkt_valid), 
	       .data_out0(data_out0),  .data_out1(data_out1), .data_out2(data_out2), .vld_out0(vld_out0), .vld_out1(vld_out1), .vld_out2(vld_out2),
	       .error(error), .busy(busy));
       

initial begin
	clk = 1'b0;
	forever #5 clk =~clk;
end

task reset();
	begin
		@(negedge clk);
		rstn = 1'b0;
		@(negedge clk);
		rstn = 1'b1;
	end
endtask

task initialize();
{rstn, read_en0, read_en1, read_en2,  pkt_valid} = 0;
endtask

task pkt_gen_14;
	reg [7:0] payload_data,parity,header;
	reg [5:0] payload_len;
	reg [1:0] addr;

	begin
		@(negedge clk);
		wait(~busy)
		@(negedge clk);
		payload_len = 6'd14;
		addr = 2'b00;
		header = { payload_len,addr};
		data_in = header;
		pkt_valid = 1'b1;
		parity = 1'b0 ^ header;
		@(negedge clk);
		wait(~busy)
		for(k = 0; k<payload_len ; k=k+1)
		begin
			@(negedge clk);
			wait(~busy)
			payload_data = {$random}%256;
			data_in = payload_data;
			parity = parity ^ payload_data;
		end
		@(negedge clk);
		wait(~busy)
		pkt_valid = 1'b0;
		data_in = parity;
		
	end
endtask

task pkt_gen_8;
	reg [7:0] payload_data,parity,header;
	reg [5:0] payload_len;
	reg [1:0] addr;

	begin
		@(negedge clk);
		wait(~busy)
		@(negedge clk);
		payload_len = 6'd8;
		addr = 2'b01;
		header = { payload_len,addr};
		data_in = header;
		pkt_valid = 1'b1;
		parity = 1'b0 ^ header;
		@(negedge clk);
		wait(~busy)
		for(k = 0; k<payload_len ; k=k+1)
		begin
			@(negedge clk);
			wait(~busy)
			payload_data = {$random}%256;
			data_in = payload_data;
			parity = parity ^ payload_data;
		end
		@(negedge clk);
		wait(~busy)
		pkt_valid = 1'b0;
		data_in = parity;
		
	end
endtask

task pkt_gen_16;
	reg [7:0] payload_data,parity,header;
	reg [5:0] payload_len;
	reg [1:0] addr;

	begin
		@(negedge clk);
		wait(~busy)
		@(negedge clk);
		payload_len = 6'd16;
		addr = 2'b10;
		header = { payload_len,addr};
		data_in = header;
		pkt_valid = 1'b1;
		parity = 1'b0 ^ header;
		@(negedge clk);
		wait(~busy)
		for(k = 0; k<payload_len; k=k+1)
		begin
			@(negedge clk);
			wait(~busy)
			payload_data = {$random}%256;
			data_in = payload_data;
			parity = parity ^ payload_data;
		end
		@(negedge clk);
		wait(~busy)
		pkt_valid = 1'b0;
		data_in = parity;
		
	end
endtask

event E1; 
task pkt_gen_21;
	reg [7:0] payload_data,parity,header;
	reg [5:0] payload_len;
	reg [1:0] addr;

	begin
		-> E1;
		@(negedge clk);
		wait(~busy)
		@(negedge clk);
		payload_len = 6'd21;
		addr = 2'b00;
		header = { payload_len,addr};
		data_in = header;
		pkt_valid = 1'b1;
		parity = 1'b0 ^ header;
		@(negedge clk);
		wait(~busy)
		for(k = 0; k<payload_len; k=k+1)
		begin
			@(negedge clk);
			wait(~busy)
			payload_data = {$random}%256;
			data_in = payload_data;
			parity = parity ^ payload_data;
		end
		@(negedge clk);
		wait(~busy)
		pkt_valid = 1'b0;
		data_in = parity;
		
	end
endtask

event E2;

task pkt_gen_random;
	reg [7:0] payload_data,parity,header;
	reg [5:0] payload_len;
	reg [1:0] addr;

	begin
		-> E2;
		@(negedge clk);
		wait(~busy)
		@(negedge clk);
		payload_len = {$random}%64;
		addr = 2'b01;
		header = { payload_len,addr};
		data_in = header;
		pkt_valid = 1'b1;
		parity = 1'b0 ^ header;
		@(negedge clk);
		wait(~busy)
		for(k = 0; k<payload_len; k=k+1)
		begin
			@(negedge clk);
			wait(~busy)
			payload_data = {$random}%256;
			data_in = payload_data;
			parity = parity ^ payload_data;
		end
		@(negedge clk);
		wait(~busy)
		pkt_valid = 1'b0;
		data_in = parity;
		
	end
endtask

initial begin
initialize;

reset;
pkt_gen_14;
repeat(3) 
@(negedge clk);
@(negedge clk);
read_en0 = 1'b1;
wait(~vld_out0)
@(negedge clk)
read_en0 = 1'b0;

pkt_gen_8;
@(negedge clk);
read_en1 = 1'b1;
wait(~vld_out1)
@(negedge clk)
read_en1 = 1'b0;	

reset;
pkt_gen_16;
repeat(3) 
@(negedge clk);
@(negedge clk);
read_en2 = 1'b1;
wait(~vld_out2)
@(negedge clk)
read_en2 = 1'b0;

reset;
pkt_gen_21;
pkt_gen_random;

#100; $finish;
end


initial begin
@(E1)
@(negedge clk);
read_en0 = 1'b1;
wait(~vld_out0)
@(negedge clk);
//read_en0= 1'b0;
end

initial begin
@(E2)
@(negedge clk);
read_en1 = 1'b1;
wait(~vld_out1)
@(negedge clk);
//read_en1= 1'b0;
end

endmodule
	

