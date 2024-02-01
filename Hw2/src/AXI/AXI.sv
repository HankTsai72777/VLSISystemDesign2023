// 1031 after fsm
`include "../include/AXI_define.svh"


module AXI(

	input ACLK,
	input ARESETn,

	//SLAVE INTERFACE FOR MASTERS
	//WRITE ADDRESS
	input [`AXI_ID_BITS-1:0] AWID_M1,
	input [`AXI_ADDR_BITS-1:0] AWADDR_M1, 
	input [`AXI_LEN_BITS-1:0] AWLEN_M1,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
	input [1:0] AWBURST_M1,
	input AWVALID_M1,
	output logic AWREADY_M1,
	//WRITE DATA
	input [`AXI_DATA_BITS-1:0] WDATA_M1,
	input [`AXI_STRB_BITS-1:0] WSTRB_M1,
	input WLAST_M1,
	input WVALID_M1,
	output logic WREADY_M1,
	//WRITE RESPONSE
	output logic [`AXI_ID_BITS-1:0] BID_M1,
	output logic [1:0] BRESP_M1,
	output logic BVALID_M1,
	input BREADY_M1,//error

	//READ ADDRESS0
	input [`AXI_ID_BITS-1:0] ARID_M0,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M0,
	input [`AXI_LEN_BITS-1:0] ARLEN_M0,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
	input [1:0] ARBURST_M0,
	input ARVALID_M0,
	output logic ARREADY_M0,
	//READ DATA0
	output logic [`AXI_ID_BITS-1:0] RID_M0,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M0,
	output logic [1:0] RRESP_M0,
	output logic RLAST_M0,
	output logic RVALID_M0,
	input RREADY_M0,

	//READ ADDRESS1
	input [`AXI_ID_BITS-1:0] ARID_M1,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	input [`AXI_LEN_BITS-1:0] ARLEN_M1,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
	input [1:0] ARBURST_M1,
	input ARVALID_M1,
	output logic ARREADY_M1,
	//READ DATA1
	output logic [`AXI_ID_BITS-1:0] RID_M1,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M1,
	output logic [1:0] RRESP_M1,
	output logic RLAST_M1,
	output logic RVALID_M1,
	input RREADY_M1,
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
	//MASTER INTERFACE FOR SLAVES
	//WRITE ADDRESS0
	output logic [`AXI_IDS_BITS-1:0] AWID_S0,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S0,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S0,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S0,
	output logic [1:0] AWBURST_S0,
	output logic AWVALID_S0,
	input AWREADY_S0,
	//WRITE DATA0
	output logic [`AXI_DATA_BITS-1:0] WDATA_S0,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S0,
	output logic WLAST_S0,
	output logic WVALID_S0,
	input WREADY_S0,
	//WRITE RESPONSE0
	input [`AXI_IDS_BITS-1:0] BID_S0,
	input [1:0] BRESP_S0,
	input BVALID_S0,
	output logic BREADY_S0,
	
	//WRITE ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] AWID_S1,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S1,
	output logic [1:0] AWBURST_S1,
	output logic AWVALID_S1,
	input AWREADY_S1,
	//WRITE DATA1
	output logic [`AXI_DATA_BITS-1:0] WDATA_S1,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S1,
	output logic WLAST_S1,
	output logic WVALID_S1,
	input WREADY_S1,
	//WRITE RESPONSE1
	input [`AXI_IDS_BITS-1:0] BID_S1,
	input [1:0] BRESP_S1,
	input BVALID_S1,
	output logic BREADY_S1,
	
	//READ ADDRESS0
	output logic [`AXI_IDS_BITS-1:0] ARID_S0,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S0,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S0,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S0,
	output logic [1:0] ARBURST_S0,
	output logic ARVALID_S0,
	input ARREADY_S0,
	//READ DATA0
	input [`AXI_IDS_BITS-1:0] RID_S0,
	input [`AXI_DATA_BITS-1:0] RDATA_S0,
	input [1:0] RRESP_S0,
	input RLAST_S0,
	input RVALID_S0,
	output logic RREADY_S0,

	//READ ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] ARID_S1,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S1,
	output logic [1:0] ARBURST_S1,
	output logic ARVALID_S1,
	input ARREADY_S1,
	//READ DATA1
	input [`AXI_IDS_BITS-1:0] RID_S1,
	input [`AXI_DATA_BITS-1:0] RDATA_S1,
	input [1:0] RRESP_S1,
	input RLAST_S1,
	input RVALID_S1,
	output logic RREADY_S1
	
);
    //---------- you should put your design here ----------//
	logic RST ;

	logic [31:0] ARADDR_M0_reg  ;
	logic [3:0]  ARLEN_M0_reg   ;
    logic [2:0]  ARSIZE_M0_reg  ;
    logic [1:0]  ARBURST_M0_reg ;
    logic [31:0] ARADDR_M1_reg  ;
    logic [3:0]  ARLEN_M1_reg   ;
    logic [2:0]  ARSIZE_M1_reg  ;
    logic [1:0]  ARBURST_M1_reg ;

	logic [31:0] AWADDR_M1_reg ;
    
	logic [2:0]  cs_axi_R, ns_axi_R ; 
	logic [1:0]  cs_axi_W, ns_axi_W ;
	logic [1:0]  AR_sel ;
	logic [1:0]  AW_sel ;
	logic [1:0]  R_sel  ; 
	logic [1:0]  W_sel  ;
	// arbiter
	logic ARREADY_M0_arb, ARREADY_M1_arb ;
	logic RVALID_M0_arb,  RVALID_M1_arb  ;
	logic AWREADY_M1_arb ;
	logic WREADY_M1_arb  ;
	logic BVALID_M1_arb  ;

	assign RST = ~ARESETn ;

	assign ARREADY_M0_arb = (ARADDR_M0[31:17] == 15'b0) ? (ARADDR_M0[16]) ? ARREADY_S1 : ARREADY_S0 : 1'b0 ;
	assign ARREADY_M1_arb = (ARADDR_M1[31:17] == 15'b0) ? (ARADDR_M1[16]) ? ARREADY_S1 : ARREADY_S0 : 1'b0 ;
	assign RVALID_M0_arb  = (ARADDR_M0_reg[16]) ? RVALID_S1 : RVALID_S0 ;
	assign RVALID_M1_arb  = (ARADDR_M1_reg[16]) ? RVALID_S1 : RVALID_S0 ;

	assign AWREADY_M1_arb = (AWADDR_M1[31:17] == 15'b0) ? (AWADDR_M1[16]) ? AWREADY_S1 : AWREADY_S0 : 1'b0 ;
	assign WREADY_M1_arb  = (AWADDR_M1_reg[16]) ? WREADY_S1 : WREADY_S0 ;
	assign BVALID_M1_arb  = (AWADDR_M1_reg[16]) ? BVALID_S1 : BVALID_S0 ;

	parameter IDLE_R = 3'd0 ,
			  AR_M0  = 3'd1 ,
			  R_M0   = 3'd2 ,
			  AR_M1  = 3'd3 ,
			  R_M1   = 3'd4 ;
	// WRITE FSM
	parameter IDLE_W = 2'd0 ,
			  AW_M1  = 2'd1 ,
			  W_M1   = 2'd2 ;

	always_ff @ (posedge ACLK or negedge ARESETn) begin
		if (!ARESETn) begin
			cs_axi_R <= IDLE_R ;
			cs_axi_W <= IDLE_W ;
		end
		else begin
			cs_axi_R <= ns_axi_R ;
			cs_axi_W <= ns_axi_W ;
		end
	end
	// AR & AW registers
	always_ff @ (posedge ACLK or posedge RST) begin
		if (RST) begin
			AWADDR_M1_reg  <= 32'b0 ;
			ARADDR_M0_reg  <= 32'b0 ;
			ARADDR_M1_reg  <= 32'b0 ;
			ARLEN_M0_reg   <= 4'b0  ;
            ARSIZE_M0_reg  <= 3'b0  ;
            ARBURST_M0_reg <= 2'b0  ;
			ARLEN_M1_reg   <= 4'b0  ;
            ARSIZE_M1_reg  <= 3'b0  ;
            ARBURST_M1_reg <= 2'b0  ;
		end
		else begin
			ARADDR_M0_reg <= (RVALID_M0 && RREADY_M0 && RLAST_M0) ? 32'b0 :
			    			 (ns_axi_R == AR_M0) ? ARADDR_M0 : ARADDR_M0_reg ;

			ARLEN_M0_reg  <= (ns_axi_R == AR_M0) ? ARLEN_M0 : ARLEN_M0_reg ;

            ARSIZE_M0_reg <= (ns_axi_R == AR_M0) ? ARSIZE_M0 : ARSIZE_M0_reg ;

            ARBURST_M0_reg <= (ns_axi_R == AR_M0) ? ARBURST_M0 : ARBURST_M0_reg ;

			ARADDR_M1_reg <= (RVALID_M1 && RREADY_M1 && RLAST_M1) ? 32'b0 :
			    			 (ns_axi_R == AR_M1) ? ARADDR_M1 : ARADDR_M1_reg ;

		    ARLEN_M1_reg <= (ns_axi_R == AR_M1) ? ARLEN_M1 : ARLEN_M1_reg ;

            ARSIZE_M1_reg <= (ns_axi_R == AR_M1) ? ARSIZE_M1 : ARSIZE_M1_reg ;

            ARBURST_M1_reg <= (ns_axi_R == AR_M1) ? ARBURST_M1 : ARBURST_M1_reg ;

            AWADDR_M1_reg <= (BVALID_M1_arb && BREADY_M1) ? 32'b0 :
			    			 (ns_axi_W == AW_M1) ? AWADDR_M1 : AWADDR_M1_reg ;
		end
	end

	always_comb begin
		case(cs_axi_R)
			IDLE_R : ns_axi_R = (ARVALID_M0 && ARADDR_M0[31:17] == 15'b0) ? AR_M0 :
			    				(ARVALID_M1 && ARADDR_M1[31:17] == 15'b0) ? AR_M1 : IDLE_R ;

			R_M0   : ns_axi_R = (RVALID_M0_arb && RREADY_M0 && RLAST_M0)  ?
			    				(ARVALID_M1 && ARADDR_M1[31:17] == 15'b0) ? AR_M1 :
			    				(ARVALID_M0 && ARADDR_M0[31:17] == 15'b0) ? AR_M0 : IDLE_R :
																			R_M0  ;
			R_M1   : ns_axi_R = (RVALID_M1_arb && RREADY_M1 && RLAST_M1)  ?
			    			    (ARVALID_M0 && ARADDR_M0[31:17] == 15'b0) ? AR_M0 :
			      			    (ARVALID_M1 && ARADDR_M1[31:17] == 15'b0) ? AR_M1:IDLE_R : R_M1 ;

			AR_M1  : ns_axi_R = (ARVALID_M1 && ARREADY_M1_arb) ? R_M1 : AR_M1 ;

			AR_M0  : ns_axi_R = (ARVALID_M0 && ARREADY_M0_arb) ? R_M0 : AR_M0 ;
			default : ns_axi_R = IDLE_R;
		endcase
	end

	always_comb  begin 
		case(cs_axi_W)
			IDLE_W  : ns_axi_W = (AWVALID_M1 && AWADDR_M1[31:17] == 15'b0) ? AW_M1 : IDLE_W ;
			AW_M1   : ns_axi_W = (AWVALID_M1 && AWREADY_M1_arb) ? W_M1 : AW_M1 ;
			W_M1    : ns_axi_W = (BVALID_M1_arb && BREADY_M1) ?
			    				(AWVALID_M1 && AWADDR_M1[31:17] == 15'b0) ? AW_M1:IDLE_W : W_M1 ;
			default : ns_axi_W = IDLE_W ;
		endcase
	end

	always_comb  begin 
		case(cs_axi_R)
			IDLE_R  : AR_sel = 2'b10 ;
			R_M0    : AR_sel = 2'b00 ;
			R_M1    : AR_sel = 2'b01 ;
			AR_M1   : AR_sel = 2'b01 ;
			AR_M0   : AR_sel = 2'b00 ;	
			default : AR_sel = 2'b10 ;
		endcase
	end

	always_comb  begin 
		case(cs_axi_W)
			IDLE_W  : AW_sel = 2'b10 ;
			AW_M1   : AW_sel = 2'b01 ;
			W_M1    : AW_sel = 2'b01 ;
			default : AW_sel = 2'b10 ;
		endcase
	end

	always_comb  begin  // slave selection
		if(AR_sel == 2'b00 && ARADDR_M0_reg[31:17] == 15'b0) begin // M0 --> SX
			if(ARADDR_M0_reg[16] == 1'b0)
				R_sel = 2'b00;
			else if(ARADDR_M0_reg[16] == 1'b1)
				R_sel = 2'b01;
			else
				R_sel = 2'b10;
		end
		else if (AR_sel == 2'b01 && ARADDR_M1_reg[31:17] == 15'b0) begin // M1 --> SX
			if(ARADDR_M1_reg[16] == 1'b0)
				R_sel = 2'b00;
			else if(ARADDR_M1_reg[16] == 1'b1)
				R_sel = 2'b01;
			else
				R_sel = 2'b10;
		end
		else
			R_sel = 2'b10;
	end

	always_comb  begin 
		if(AW_sel == 2'b01 && AWADDR_M1_reg[31:17] == 15'b0) begin // M1 --> SX
		    if(AWADDR_M1_reg[16] == 1'b0)
				W_sel = 2'b00;
			else if(AWADDR_M1_reg[16] == 1'b1)
				W_sel = 2'b01;
			else
				W_sel = 2'b10;
		end
		else
		    W_sel = 2'b10;
	end

/////////////////////////////////////////////////////////////	
	//SLAVE INTERFACE FOR MASTERS
	//WRITE ADDRESS
	assign AWREADY_M1 = (AW_sel == 2'b01) ? (AWADDR_M1_reg[16]) ? AWREADY_S1 : AWREADY_S0 : 1'b0 ;
	//WRITE DATA
	assign WREADY_M1 = (AW_sel == 2'b01) ? (AWADDR_M1_reg[16]) ? WREADY_S1 : WREADY_S0 : 1'b0 ;
	//WRITE RESPONSE
	assign BID_M1    = (AW_sel == 2'b01) ? (AWADDR_M1_reg[16]) ? BID_S1[3:0] : BID_S0[3:0] : 4'b0 ;
	assign BRESP_M1  = (AW_sel == 2'b01) ? (AWADDR_M1_reg[16]) ? BRESP_S1 : BRESP_S0 : 2'b0 ;
	assign BVALID_M1 = (AW_sel == 2'b01) ? (AWADDR_M1_reg[16]) ? BVALID_S1 :BVALID_S0 : 1'b0 ;

	//READ ADDRESS0
	assign ARREADY_M0 = (AR_sel == 2'b00) ? (ARADDR_M0_reg[16]) ? ARREADY_S1 : ARREADY_S0 : 1'b0 ;
	//READ DATA0
	assign RID_M0 = (AR_sel == 2'b00) ? (ARADDR_M0_reg[16]) ? RID_S1[3:0] : RID_S0[3:0] : 4'b0 ;
	assign RDATA_M0 = (AR_sel == 2'b00) ? (ARADDR_M0_reg[16]) ? RDATA_S1 : RDATA_S0 : 32'b0 ;
	assign RRESP_M0 = (AR_sel == 2'b00) ? (ARADDR_M0_reg[16]) ? RRESP_S1 : RRESP_S0 : 2'b0 ;
	assign RLAST_M0 = (AR_sel == 2'b00) ? (ARADDR_M0_reg[16]) ? RLAST_S1 : RLAST_S0 : 1'b0 ;
	assign RVALID_M0 = (AR_sel == 2'b00) ? (ARADDR_M0_reg[16]) ? RVALID_S1 : RVALID_S0 : 1'b0 ;
	//READ ADDRESS1
	assign ARREADY_M1 = (AR_sel == 2'b01) ? (ARADDR_M1_reg[16]) ? ARREADY_S1 : ARREADY_S0 : 1'b0 ;
	//READ DATA1
	assign RID_M1 = (AR_sel == 2'b01) ? (ARADDR_M1_reg[16]) ? RID_S1[3:0] : RID_S0[3:0] : 4'b0 ;
	assign RDATA_M1 = (AR_sel == 2'b01) ? (ARADDR_M1_reg[16]) ? RDATA_S1 : RDATA_S0 : 32'b0 ;
	assign RRESP_M1 = (AR_sel == 2'b01) ? (ARADDR_M1_reg[16]) ? RRESP_S1 : RRESP_S0 : 2'b00 ;
	assign RLAST_M1 = (AR_sel == 2'b01) ? (ARADDR_M1_reg[16]) ? RLAST_S1 : RLAST_S0 : 1'b0 ;
	assign RVALID_M1 = (AR_sel == 2'b01) ? (ARADDR_M1_reg[16]) ? RVALID_S1 : RVALID_S0 : 1'b0 ;
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
	//MASTER INTERFACE FOR SLAVES
	//WRITE ADDRESS0
	assign AWID_S0 = (AW_sel[0]) ? {4'b0,AWID_M1} : 8'b0 ;
	assign AWADDR_S0 = (AW_sel[0]) ? AWADDR_M1_reg : 32'b0 ;
	assign AWLEN_S0 = (AW_sel[0]) ? AWLEN_M1 : 4'b0 ;
	assign AWSIZE_S0 = (AW_sel[0]) ? AWSIZE_M1 : 3'b0 ;
	assign AWBURST_S0 = (AW_sel[0]) ? AWBURST_M1 : 2'b0 ;
	assign AWVALID_S0 = (W_sel == 2'b00) ?
	    				(AW_sel[0]) ? AWVALID_M1 : 1'b0 : 1'b0 ;
	//WRITE DATA1
	assign WDATA_S0 = (AW_sel[0]) ? (W_sel == 2'b00) ? WDATA_M1 : 32'b0 : 32'b0 ;
	assign WSTRB_S0 = (AW_sel[0]) ? (W_sel == 2'b00) ? WSTRB_M1 : 4'hf : 4'hf ;
	assign WLAST_S0 = (AW_sel[0]) ? (W_sel == 2'b00) ? WLAST_M1 : 1'b0 : 1'b0 ; 
	assign WVALID_S0 = (AW_sel[0]) ? (W_sel == 2'b00) ? WVALID_M1 : 1'b0 : 1'b0 ;
	//WRITE RESPONSE1
	assign BREADY_S0 = (AW_sel[0]) ? (W_sel == 2'b00) ? BREADY_M1 : 1'b0 : 1'b0 ;
	//WRITE ADDRESS1
	assign AWID_S1 = (AW_sel[0]) ? {4'b0,AWID_M1} : 8'b0 ;
	assign AWADDR_S1 = (AW_sel[0]) ? AWADDR_M1_reg : 32'b0 ;
	assign AWLEN_S1 = (AW_sel[0]) ? AWLEN_M1 : 4'b0 ;
	assign AWSIZE_S1 = (AW_sel[0]) ? AWSIZE_M1 : 3'b0 ;
	assign AWBURST_S1 = (AW_sel[0]) ? AWBURST_M1 : 2'b0 ;
	assign AWVALID_S1 = (W_sel == 2'b01) ?
	    				(AW_sel[0]) ? AWVALID_M1 : 1'b0 : 1'b0 ;
	//WRITE DATA1
	assign WDATA_S1 = (AW_sel[0]) ? (W_sel == 2'b01) ? WDATA_M1 : 32'b0 : 32'b0 ;
	assign WSTRB_S1 = (AW_sel[0]) ? (W_sel == 2'b01) ? WSTRB_M1 : 4'hf  : 4'hf  ;
	assign WLAST_S1 = (AW_sel[0]) ? (W_sel == 2'b01) ? WLAST_M1 : 1'b0  : 1'b0  ;
	assign WVALID_S1 = (AW_sel[0]) ? (W_sel == 2'b01) ? WVALID_M1:1'b0  : 1'b0  ;
	//WRITE RESPONSE1
	assign BREADY_S1 = (AW_sel[0]) ? (W_sel == 2'b01) ? BREADY_M1 : 1'b0 : 1'b0 ;
	
	//READ ADDRESS0
	assign ARID_S0 = (AR_sel[0])  ? {4'b0,ARID_M1} : {4'b0,ARID_M0} ;
	assign ARADDR_S0 = (AR_sel[0]) ? ARADDR_M1_reg : ARADDR_M0_reg ;
	assign ARLEN_S0 = (AR_sel[0]) ? ARLEN_M1_reg : ARLEN_M0_reg ;
	assign ARSIZE_S0 = (AR_sel[0]) ? ARSIZE_M1_reg : ARSIZE_M0_reg ;
	assign ARBURST_S0 = (AR_sel[0]) ? ARBURST_M1_reg : ARBURST_M0_reg ;
	assign ARVALID_S0 = (R_sel == 2'b00) ?
	    				(AR_sel[0]) ? ARVALID_M1 : ARVALID_M0 : 1'b0 ;
	//READ DATA0
	assign RREADY_S0 = (AR_sel[0]) ? RREADY_M1 : RREADY_M0 ;
	//READ ADDRESS1
	assign ARID_S1 = (AR_sel[0]) ? {4'b0,ARID_M1} : {4'b0,ARID_M0} ;
	assign ARADDR_S1 = (AR_sel[0]) ? ARADDR_M1_reg : ARADDR_M0_reg ;
	assign ARLEN_S1 = (AR_sel[0]) ? ARLEN_M1_reg : ARLEN_M0_reg    ;
	assign ARSIZE_S1 = (AR_sel[0]) ? ARSIZE_M1_reg : ARSIZE_M0_reg ;
	assign ARBURST_S1 = (AR_sel[0]) ?ARBURST_M1_reg:ARBURST_M0_reg ;
	assign ARVALID_S1 = (R_sel == 2'b01) ?
	    				(AR_sel[0]) ? ARVALID_M1 : ARVALID_M0 : 1'b0 ;
	//READ DATA1
	assign RREADY_S1 = (AR_sel[0]) ? RREADY_M1 : RREADY_M0 ;

endmodule
