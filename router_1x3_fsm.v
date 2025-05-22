module router_fsm(
	input clk,rstn,pkt_valid,parity_done,sft_rst0,sft_rst1,sft_rst2,fifo_full,low_pkt_valid,fifo_empty0,fifo_empty1,fifo_empty2,
	input [1:0]data_in,
	output busy,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state);

parameter DECODE_ADDR = 3'b000,
	LOAD_FIRST_DATA = 3'b001,
	LOAD_DATA = 3'b010,
	LOAD_PARITY = 3'b011,
	CHECK_PARITY_ERROR = 3'b100,
	FIFO_FULL_STATE = 3'b101,
	LOAD_AFTER_FULL = 3'b110,
	WAIT_TILL_EMPTY = 3'b111;

reg [2:0]PS,NS;
reg [1:0] addr;

always @ (posedge clk)
begin
	if(rstn == 1'b0)
		addr <= 2'dz;
	else
		addr <= data_in;
end

always @ (posedge clk)
begin
	if(rstn == 1'b0)
		PS <= DECODE_ADDR;
	else if(sft_rst0 || sft_rst1 || sft_rst2)
		PS <= DECODE_ADDR;
	else
		PS <= NS;
end

always @ (*)
begin
	NS = DECODE_ADDR;
	case(PS)
		DECODE_ADDR :
	       	begin
			if((pkt_valid==1'b1 & (data_in[1:0] == 0) & fifo_empty0==1'b1) | 
			   (pkt_valid==1'b1 & (data_in[1:0] == 1) & fifo_empty1==1'b1) | 
			   (pkt_valid==1'b1 & (data_in[1:0] == 2) & fifo_empty2==1'b1))
				NS = LOAD_FIRST_DATA;
			else if ((pkt_valid==1'b1 & (data_in[1:0] == 0) & fifo_empty0==1'b0) | 
					  (pkt_valid==1'b1 & (data_in[1:0] == 1) & fifo_empty1==1'b0) | 
				     (pkt_valid==1'b1 & (data_in[1:0] == 2) & fifo_empty2==1'b0))
				NS = WAIT_TILL_EMPTY;
			else
				NS = DECODE_ADDR;
		end

		LOAD_FIRST_DATA :
			NS = LOAD_DATA;

		LOAD_DATA :
		begin
			if(!fifo_full && !pkt_valid)
				NS = LOAD_PARITY;
			else if (fifo_full)
				NS = FIFO_FULL_STATE;
			else 
				NS = LOAD_DATA;
		end

		LOAD_PARITY :
			NS = CHECK_PARITY_ERROR;

		CHECK_PARITY_ERROR : 
		begin
			if(!fifo_full)
				NS = DECODE_ADDR;
			else if (fifo_full)
				NS = FIFO_FULL_STATE;
			//else
			   //NS = CHECK_PARITY_ERROR;
		end

		FIFO_FULL_STATE :
		begin
			if(!fifo_full)
				NS = LOAD_AFTER_FULL;
			else if (fifo_full)
				NS = FIFO_FULL_STATE;
			//else
				//NS = FIFO_FULL_STATE;
		end

		LOAD_AFTER_FULL :
		begin
			if(!parity_done && low_pkt_valid)
				NS = LOAD_PARITY;
			else if (parity_done)
				NS = DECODE_ADDR;
			else if (!parity_done && !low_pkt_valid)
				NS = LOAD_DATA;
			else 
				NS = LOAD_AFTER_FULL;
		end

		WAIT_TILL_EMPTY :
		begin
			if((fifo_empty0 && (addr == 0)) ||
			  (fifo_empty1 && (addr == 1)) ||
			  (fifo_empty2 && (addr == 2)))
				NS = LOAD_FIRST_DATA;
			else 
				NS = WAIT_TILL_EMPTY;
		end

	endcase
end


assign busy = ((PS == LOAD_FIRST_DATA)||(PS == LOAD_PARITY)||(PS == CHECK_PARITY_ERROR)||(PS == FIFO_FULL_STATE)||(PS == LOAD_AFTER_FULL) || (PS == WAIT_TILL_EMPTY));
assign detect_add = ((PS == DECODE_ADDR)) ;
assign ld_state = ((PS == LOAD_DATA)) ;
assign laf_state = ((PS == LOAD_AFTER_FULL)) ;
assign full_state = ((PS == FIFO_FULL_STATE));
assign write_enb_reg = ((PS == LOAD_DATA)||(PS == LOAD_PARITY)||(PS == LOAD_AFTER_FULL));
assign rst_int_reg = ((PS == CHECK_PARITY_ERROR));
assign lfd_state = ((PS == LOAD_FIRST_DATA));

endmodule