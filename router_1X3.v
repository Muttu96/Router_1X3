
`timescale 1ps/1fs

module router_1X3 (
	input clk, rstn, 
	input read_en0, read_en1, read_en2,
   input [7:0] data_in,
	input pkt_valid,
	output [7:0] data_out0, data_out1, data_out2,
	output vld_out0, vld_out1, vld_out2,
	output error, busy);


//FIFO BLOCK INSTANTIATION

wire [2:0] write_enb;
wire [7:0]din;

router_fifo FIFO_0 (.clk(clk), .rstn(rstn), .we(write_enb[0]), .sft_rst(sft_rst_0), .re(read_en0), .data_in(din), 
						 .lfd_state(lfd), .data_out(data_out0), .empty(empty_0), .full(full_0));
router_fifo FIFO_1 (.clk(clk), .rstn(rstn), .we(write_enb[1]), .sft_rst(sft_rst_1), .re(read_en1), .data_in(din), 
						 .lfd_state(lfd), .data_out(data_out1), .empty(empty_1), .full(full_1));
router_fifo FIFO_2 (.clk(clk), .rstn(rstn), .we(write_enb[2]), .sft_rst(sft_rst_2), .re(read_en2), .data_in(din), 
						 .lfd_state(lfd), .data_out(data_out2), .empty(empty_2), .full(full_2));

//SYNCHRONIZER BLOCK INSTANTIATION

router_synchronizer SYNCHRONIZER (.clk(clk), .rstn(rstn),  .detect_addr(detect_addr), .data_in(data_in[1:0]), .write_en_reg(write_en_reg), 
											 .vld0(vld_out0), .vld1(vld_out1), .vld2(vld_out2), .re0(read_en0),  .re1(read_en1),  .re2(read_en2), 
											 .write_en(write_enb), .fifo_full(fifo_full), .empty0(empty_0), .empty1(empty_1), .empty2(empty_2), 
								.sft_rst0(sft_rst_0), .sft_rst1(sft_rst_1), .sft_rst2(sft_rst_2), .full0(full_0), .full1(full_1), .full2(full_2));
			 

//FSM BLOCK INSTANTIATION 

router_fsm FSM (.clk(clk), .rstn(rstn),  .pkt_vld(pkt_valid), .busy(busy), .parity_done(parity_done), .data_in(data_in[1:0]), 
					 .sft_rst0(sft_rst_0), .sft_rst1(sft_rst_1), .sft_rst2(sft_rst_2), .fifo_full(fifo_full), .low_pkt_vld(low_pkt_vld), 
					 .fifo_empty0(empty_0), .fifo_empty1(empty_1), .fifo_empty2(empty_2), .detect_addr(detect_addr), .ld_state(ld_state), 
					 .laf_state(laf_state), .full_state(full_state), .write_en_reg(write_en_reg), .rst_int_reg(rst_int_reg), .lfd_state(lfd));


//REGISTER BLOCK INSTANTIATION 

router_register REGISTER (.clk(clk), .rstn(rstn), .pkt_vld(pkt_valid), .data_in(data_in), .fifo_full(fifo_full), .rst_int_reg(rst_int_reg), 
								  .det_addr(detect_addr), .ld_state(ld_state), .laf_state(laf_state), .full_state(full_state), .lfd_state(lfd), 
								  .parity_done(parity_done), .low_pkt_vld(low_pkt_vld), .error(error), .data_out(din));

endmodule




//FIFO BLOCK 

module router_fifo(clk, rstn, we, re, sft_rst, lfd_state, data_in, empty, full, data_out);
	input clk,rstn,we,re,sft_rst,lfd_state;
	input [7:0] data_in;
	output empty,full;
	output reg [7:0] data_out;
	
reg [8:0]mem[15:0];
integer i;
reg [5:0]temp;
reg [4:0] w_ptr, r_ptr;
reg lfd_s;

assign full = (w_ptr=={~r_ptr[4],r_ptr[3:0]})?1'b1:1'b0;
//assign full = (w_ptr == 5'd16 && r_ptr == 5'd0);
assign empty = (w_ptr == r_ptr);

always@(posedge clk)
begin
	if(rstn == 1'b0)
	begin
		w_ptr <= 5'd0;
		for(i=0;i<16;i=i+1)
			mem[i] <= 9'd0; 
	end
	else if(sft_rst == 1'b1)
	begin
		w_ptr <= 5'd0; 
		for(i=0;i<16;i=i+1)
			mem[i] <= 9'd0;
	end
	else if(we == 1'b1 && full == 1'b0)
	begin
		mem[w_ptr[3:0]] <= {lfd_s,data_in};
		w_ptr <= w_ptr+1'b1;
	end
end

always@(posedge clk)
	begin
	if(rstn == 1'b0)
	begin
		data_out <= 8'd0;
		r_ptr <= 5'd0;
	end

	else if(sft_rst == 1'b1)
	begin
		data_out <= 8'dz;
		r_ptr <= 5'd0;
	end

	else if (temp == 6'b0)
		data_out <= 8'bz;

	else if(re == 1'b1 && empty == 1'b0)
	begin
			data_out <= mem[r_ptr[3:0]][7:0];
			r_ptr <= r_ptr + 1'b1;
	end
end

always@(posedge clk)
begin
	if(rstn == 1'b0)
		lfd_s <= 1'b0;
	else if(sft_rst)
		lfd_s <= 1'b0;
	else
		lfd_s <= lfd_state;
end

always@(posedge clk)
begin
	if(rstn == 1'b0)
		temp <= 6'b0;
	else if(sft_rst == 1'b1)
		temp <= 6'b0;
	else if( !empty && re )
	begin
		if ( mem[r_ptr[4]][8] == 1)
		temp <= mem[r_ptr[4]][7:2]+1'b1;
	else if(temp != 6'd0)
		temp <= temp - 1'b1;
	end
end

endmodule




//SYNCHRONIZER BLOCK 

module router_synchronizer( 
	input clk,rstn, 
	input write_en_reg,detect_addr, 
	input re0, re1, re2,
   input full0, full1, full2,
	input empty0,empty1,empty2,
	input [1:0] data_in,
	output reg [2:0] write_en,
	output reg fifo_full,
	output vld0,vld1,vld2,
	output reg sft_rst0, sft_rst1, sft_rst2);

reg [1:0]addr;

always@(posedge clk)
begin
	if(rstn == 1'b0)
		addr <= 2'bz;
	else if (detect_addr == 1'b1)
		addr <= data_in;
end

always@(*)
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

always@(*)
begin
	case(addr)
		2'b00 : fifo_full = full0;
		2'b01 : fifo_full = full1;
		2'b10 : fifo_full = full2;
		default : fifo_full = 1'b0;
	endcase
end

assign vld0 = (~empty0),
		 vld1 = (~empty1),
		 vld2 = (~empty2);

reg [4:0]count1;

always@(posedge clk)
begin
	if(rstn == 1'b0)
		{count1, sft_rst0} <= 0;
	else if (vld0 == 1'b0)
		{ count1, sft_rst0} <= 0;
	else if(re0 == 1'b1)
		{count1,sft_rst0} <= 0;
	else begin
		if(count1 == 29)
		begin
			count1 <= 0;
			sft_rst0 <= 1'b1;
		end
		else
			count1 <= count1+1'b1;
	end
end

reg [4:0]count2;

always@(posedge clk)
begin
	if(rstn == 1'b0)
		{count2, sft_rst1} <= 0;
	else if (vld1 == 1'b0)
		{ count2, sft_rst1} <= 0;
	else if(re1 == 1'b1)
		{count2,sft_rst1} <= 0;
	else begin
		if(count2 == 29)
		begin
			count2 <= 0;
			sft_rst1 <= 1'b1;
		end
		else
			count2 <= count2+1'b1;
	end
end

reg [4:0]count3;

always@(posedge clk)
begin
	if(rstn == 1'b0)
		{count3, sft_rst2} <= 0;
	else if (vld2 == 1'b0)
		{ count3, sft_rst2} <= 0;
	else if(re2 == 1'b1)
		{count3,sft_rst2} <= 0;
	else begin
		if(count3 == 29)
		begin
			count3 <= 0;
			sft_rst2 <= 1'b1;
		end
		else
			count3 <= count3+1'b1;
	end
end


endmodule



//FSM BLOCK
module router_fsm(
	input clk,rstn,pkt_vld, parity_done, sft_rst0,sft_rst1,sft_rst2, fifo_full, low_pkt_vld, fifo_empty0, fifo_empty1, fifo_empty2,
	input [1:0] data_in,
	output busy, detect_addr, ld_state, laf_state, full_state, write_en_reg, rst_int_reg, lfd_state );

parameter DECODE_ADDR = 3'b000,
	  LOAD_FIRST_DATA = 3'b001,
	  LOAD_DATA = 3'b010,
	  LOAD_PARITY = 3'b011,
	  CHECK_PARITY_ERROR = 3'b100,
	  FIFO_FULL_STATE = 3'b101,
	  LOAD_AFTER_FULL = 3'b110,
	  WAIT_TILL_EMPTY = 3'b111;

reg [2:0] PS, NS;
reg [1:0] addr;

always@(posedge clk) 
begin
	if(!rstn )
		addr <= 2'b0;
	else
		addr <= data_in;
end

always@(posedge clk)
begin
	if(!rstn)
		PS <= DECODE_ADDR;
	else if(sft_rst0 || sft_rst1 || sft_rst2)
		PS <= DECODE_ADDR;
	else 
		PS <= NS;
end

always@(*)
begin
	NS = DECODE_ADDR;

	case(PS)
		DECODE_ADDR : 
		begin
			if((pkt_vld & (data_in[1:0] == 0) & fifo_empty0 ) | 
			   (pkt_vld & (data_in[1:0] == 1) & fifo_empty1 ) | 
			   (pkt_vld & (data_in[1:0] == 2) & fifo_empty2 ) )

			   	NS = LOAD_FIRST_DATA;

			else if ((pkt_vld & (data_in[1:0] == 0) & !fifo_empty0 ) | 
						(pkt_vld & (data_in[1:0] == 1) & !fifo_empty1 ) | 
			         (pkt_vld & (data_in[1:0] == 2) & !fifo_empty2 ) )

				 NS = WAIT_TILL_EMPTY;

			else 
				NS = DECODE_ADDR;
		end

		LOAD_FIRST_DATA : 
			NS = LOAD_DATA;
		
		LOAD_DATA :
		begin
			if(fifo_full)
				NS = FIFO_FULL_STATE;

			else if(!fifo_full && !pkt_vld)
				NS = LOAD_PARITY ;
			else
				NS = LOAD_DATA;
		end

		LOAD_PARITY :
			NS = CHECK_PARITY_ERROR;

		CHECK_PARITY_ERROR :
		begin
			if(fifo_full)
				NS = FIFO_FULL_STATE;
			else if(!fifo_full)
				NS = DECODE_ADDR;
		end

		FIFO_FULL_STATE : 
		begin
			if(fifo_full)
				NS = FIFO_FULL_STATE;
				
			else if (!fifo_full)
				NS = LOAD_AFTER_FULL;
		
		end

		LOAD_AFTER_FULL :
		begin
			if(!parity_done && !low_pkt_vld)
				NS = LOAD_DATA;
				
			else if (!parity_done && low_pkt_vld)
				NS = LOAD_PARITY;
				
			else if(parity_done)
				NS = DECODE_ADDR;
				
			else
				NS = LOAD_AFTER_FULL;
		end

		WAIT_TILL_EMPTY :
		begin
			if((fifo_empty0 && (addr == 2'd0)) || (fifo_empty1 && (addr == 2'd1) || (fifo_empty2 && ( addr == 2'd2))))
				NS = LOAD_FIRST_DATA;
			else
				NS = WAIT_TILL_EMPTY;
		end

	endcase
	end


assign busy = ((PS == LOAD_FIRST_DATA) || (PS == FIFO_FULL_STATE) || (PS == LOAD_PARITY) || 
		( PS == CHECK_PARITY_ERROR) || 	( PS == LOAD_AFTER_FULL) || (PS == WAIT_TILL_EMPTY));

assign detect_addr = ( PS == DECODE_ADDR );

assign ld_state = ( PS == LOAD_DATA);

assign laf_state = (PS == LOAD_AFTER_FULL);

assign full_state = ( PS == FIFO_FULL_STATE);

assign write_en_reg = ( (PS == LOAD_PARITY) || ( PS == LOAD_AFTER_FULL)|| (PS == LOAD_DATA));

assign rst_int_reg = ( PS == CHECK_PARITY_ERROR);

assign lfd_state = ( PS == LOAD_FIRST_DATA);

endmodule




//REGISTER BLOCK

module router_register(
	input clk, rstn,
	input pkt_vld, fifo_full, rst_int_reg, det_addr, ld_state, laf_state, full_state, lfd_state,
	input [7:0] data_in,
	output reg parity_done, low_pkt_vld, 
	output reg error,
	output reg [7:0] data_out);

reg  [7:0] header_reg;
reg  [7:0] fifo_full_reg;
reg  [7:0] pkt_parity_reg;
reg  [7:0] internal_parity_reg;

//Header_reg logic
always@(posedge clk)
begin
	if(!rstn)
		header_reg <= 0;
	else if(det_addr && pkt_vld && data_in[1:0] != 3)
		header_reg <= data_in;
	else
		header_reg <= header_reg;
end

//fifo_full_reg logic
/*always@(posedge clk)
begin
	if(!rstn)
		fifo_full_reg <= 0;
	else if (fifo_full && ld_state)
		fifo_full_reg <= data_in;
	else
		fifo_full_reg <= fifo_full_reg;
end*/

//internal_parity_reg logic
always@(posedge clk)
begin
	if(!rstn)
		internal_parity_reg <= 1'b0;
	else if(det_addr)
		internal_parity_reg <= 1'b0;
   else if(lfd_state)
		internal_parity_reg <= (internal_parity_reg ^ header_reg);
	else if(pkt_vld && ld_state && !full_state)
		internal_parity_reg <= (internal_parity_reg ^ data_in);
	else
		internal_parity_reg <= internal_parity_reg;
end

//packet_parity_reg logic
always@(posedge clk)
begin
	if(!rstn)
		pkt_parity_reg <= 0;
	else if(det_addr)
		pkt_parity_reg <= 0;
	else if(ld_state && !pkt_vld)
		pkt_parity_reg <= data_in;
	else
		pkt_parity_reg <= pkt_parity_reg;
end


//data_out logic
always@(posedge clk)
begin
	if(!rstn)
	begin
		data_out <= 0;
		fifo_full_reg <= 0;
	end
	else if(det_addr && pkt_vld && data_in[1:0] != 3)
	       data_out <= data_out;
	else if(lfd_state)
	   data_out <= header_reg;
	else if(ld_state && !fifo_full)  
	       data_out <= data_in;
	else if(ld_state && fifo_full) 
	       fifo_full_reg <= data_in;
	else if(laf_state)
	 data_out <= fifo_full_reg;
	else
		 data_out <= data_out;		

end


//parity_done logic
always@(posedge clk)
begin
	if(!rstn)
		parity_done <= 0;
	else if(det_addr)
		parity_done <= 0;
	else if( (ld_state && !fifo_full && !pkt_vld)  || (laf_state && low_pkt_vld && !parity_done) )
		parity_done <= 1;
	else
		parity_done <= parity_done;
end

//low_paket_valid logic
always@(posedge clk)
begin
	if(!rstn)
		low_pkt_vld <= 1'b0;
	else if(rst_int_reg)
		low_pkt_vld <= 0;
	else if(ld_state && !pkt_vld)
		low_pkt_vld <= 1'b1;
	else
		low_pkt_vld <= 1'b0;
end


//error logic
always@(posedge clk)
begin
	if(!rstn)
		error <= 1'b0;
	else if(parity_done)
	   begin
	        if(internal_parity_reg != pkt_parity_reg)
		      error <= 1'b1;
	   end
	 else
		      error <= 1'b0;
end

endmodule
	
		
