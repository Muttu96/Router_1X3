module router_synchronizer_tb();
	reg clk,rstn;
	reg write_en_reg,detect_addr;
	reg re0,re1,re2;
	reg full0,full1,full2;
	reg empty0,empty1,empty2;
	reg [1:0]data_in;
	wire [2:0] write_en;
	wire fifo_full;
	wire vld0,vld1,vld2;
	wire sft_rst0,sft_rst1,sft_rst2;

router_synchronizer DUT (.clk(clk), .rstn(rstn), .write_en_reg(write_en_reg), .detect_addr(detect_addr),
			.re0(re0), .re1(re1), .re2(re2), .full0(full0), .full1(full1), .full2(full2),
			.empty0(empty0), .empty1(empty1), .empty2(empty2), .data_in(data_in), .write_en(write_en),
			.fifo_full(fifo_full), .vld0(vld0), .vld1(vld1) ,.vld2(vld2), .sft_rst0(sft_rst0), .sft_rst1(sft_rst1),
			.sft_rst2(sft_rst2));

initial 
begin
	clk = 1'b0;
	forever #5 clk = ~clk;
end

initial 
begin
	{re0,re1,re2,full0,full1,full2,empty0,empty1,empty2} = 0;
	
	rstn = 1'b0;
	
	@(negedge clk)
	rstn = 1'b1;
	
	@(negedge clk)
	detect_addr = 1'b1;
	data_in = 2'b00;
	
	@(negedge clk)
	//detect_addr = 1'b0;
	write_en_reg = 1'b1;
	
	@(negedge clk)
	{full0,full1,full2} = 3'b100;
	
	@(negedge clk)
	{empty0,empty1,empty2} = 3'b011;
	
	@(negedge clk)
	{re0,re1,re2} = 3'b100;
	
	
	@(negedge clk)
	rstn = 1'b1;
	
	@(negedge clk)
	//detect_addr = 1'b1;
	data_in = 2'b01;
	
	@(negedge clk)
	//detect_addr = 1'b0;
	write_en_reg = 1'b1;	
	
	@(negedge clk)
	{full0,full1,full2} = 3'b010;
	
	@(negedge clk)
	{empty0,empty1,empty2} = 3'b101;
	
	@(negedge clk)
	{re0,re1,re2} = 3'b010;
	
	
	
	@(negedge clk)
	rstn = 1'b1;
	
	@(negedge clk)
	//detect_addr = 1'b1;
	data_in = 2'b10;	
	
	@(negedge clk)
	//detect_addr = 1'b0;
	write_en_reg = 1'b1;	
	
	@(negedge clk)
	{full0,full1,full2} = 3'b001;
	
	@(negedge clk)
	{empty0,empty1,empty2} = 3'b110;
	
	@(negedge clk)
	{re0,re1,re2} = 3'b001;
	
	
	
	@(negedge clk)
	rstn = 1'b1;	
	
	@(negedge clk)
	//detect_addr = 1'b1;
	data_in = 2'b11;	
	
	@(negedge clk)
	detect_addr = 1'b0;
	write_en_reg = 1'b1;
	
	@(negedge clk)
	{full0,full1,full2} = 3'b010;
	
	@(negedge clk)
	{empty0,empty1,empty2} = 3'b101;
	
	@(negedge clk)
	{re0,re1,re2} = 3'b010;
	
	//#1000;
end

endmodule