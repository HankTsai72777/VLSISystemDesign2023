// DATA : 12/01 00:00

/* ========      MEMORY ADDRESS SPECIFICATION      ======== */
/*                2-bit for checking address                */
/*						v  v  								*/ 
/* ======== S0: ROM   0x0000_0000 ~ 0x0000_1FFF    ======== */
/* ======== S1: IM    0x0001_0000 ~ 0x0001_FFFF    ======== */
/* ======== S2: DM    0x0002_0000 ~ 0x0002_FFFF    ======== */
/* ======== S3: Sctrl 0x1000_0000 ~ 0x1000_03FF    ======== */
/* ======== S4: WDT   0x1001_0000 ~ 0x1001_03FF    ======== */
/* ======== S5: DRAM  0x2000_0000 ~ 0x201F_FFFF    ======== */
`include "AXI_define.svh"
module AXI (
	input ACLK,
	input ARESETn,
	//MASTER INTERFACE
	// M0
	// READ
	input [`AXI_ID_BITS-1:0]          ARID_M0,
	input [`AXI_ADDR_BITS-1:0]        ARADDR_M0,
	input [`AXI_LEN_BITS-1:0]         ARLEN_M0,
	input [`AXI_SIZE_BITS-1:0]        ARSIZE_M0,
	input [1:0]                       ARBURST_M0,
	input                             ARVALID_M0,
	output logic                      ARREADY_M0,
	output logic [`AXI_ID_BITS-1:0]   RID_M0,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M0,
	output logic [1:0]                RRESP_M0,
	output logic                      RLAST_M0,
	output logic                      RVALID_M0,
	input                             RREADY_M0,
	// M1
	// WRITE
	input [`AXI_ID_BITS-1:0]          AWID_M1,
	input [`AXI_ADDR_BITS-1:0]        AWADDR_M1,
	input [`AXI_LEN_BITS-1:0]         AWLEN_M1,
	input [`AXI_SIZE_BITS-1:0]        AWSIZE_M1,
	input [1:0]                       AWBURST_M1,
	input                             AWVALID_M1,
	output logic                      AWREADY_M1,
	input [`AXI_DATA_BITS-1:0]        WDATA_M1,
	input [`AXI_STRB_BITS-1:0]        WSTRB_M1,
	input                             WLAST_M1,
	input                             WVALID_M1,
	output logic                      WREADY_M1,
	output logic [`AXI_ID_BITS-1:0]   BID_M1,
	output logic [1:0]                BRESP_M1,
	output logic                      BVALID_M1,
	input                             BREADY_M1,
	// READ
	input [`AXI_ID_BITS-1:0]          ARID_M1,
	input [`AXI_ADDR_BITS-1:0]        ARADDR_M1,
	input [`AXI_LEN_BITS-1:0]         ARLEN_M1,
	input [`AXI_SIZE_BITS-1:0]        ARSIZE_M1,
	input [1:0]                       ARBURST_M1,
	input                             ARVALID_M1,
	output logic                      ARREADY_M1,
	output logic [`AXI_ID_BITS-1:0]   RID_M1,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M1,
	output logic [1:0]                RRESP_M1,
	output logic                      RLAST_M1,
	output logic                      RVALID_M1,
	input                             RREADY_M1,
	//SLAVE INTERFACE
	// S0
	// READ
	output logic [`AXI_IDS_BITS-1:0]  ARID_S0,
	output [`AXI_ADDR_BITS-1:0]       ARADDR_S0,
	output [`AXI_LEN_BITS-1:0]        ARLEN_S0,
	output [`AXI_SIZE_BITS-1:0]       ARSIZE_S0,
	output [1:0]                      ARBURST_S0,
	output logic                      ARVALID_S0,
	input                             ARREADY_S0,
	input [`AXI_IDS_BITS-1:0]         RID_S0,
	input [`AXI_DATA_BITS-1:0]        RDATA_S0,
	input [1:0]                       RRESP_S0,
	input                             RLAST_S0,
	input                             RVALID_S0,
	output logic                      RREADY_S0,
	// S1
	// WRITE
	output logic [`AXI_IDS_BITS-1:0]  AWID_S1,
	output [`AXI_ADDR_BITS-1:0]       AWADDR_S1,
	output [`AXI_LEN_BITS-1:0]        AWLEN_S1,
	output [`AXI_SIZE_BITS-1:0]       AWSIZE_S1,
	output [1:0]                      AWBURST_S1,
	output logic                      AWVALID_S1,
	input                             AWREADY_S1,
	output logic [`AXI_DATA_BITS-1:0] WDATA_S1,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S1,
	output logic                      WLAST_S1,
	output logic                      WVALID_S1,
	input                             WREADY_S1,
	input [`AXI_IDS_BITS-1:0]         BID_S1,
	input [1:0]                       BRESP_S1,
	input                             BVALID_S1,
	output logic                      BREADY_S1,
	// READ
	output logic [`AXI_IDS_BITS-1:0]  ARID_S1,
	output [`AXI_ADDR_BITS-1:0]       ARADDR_S1,
	output [`AXI_LEN_BITS-1:0]        ARLEN_S1,
	output [`AXI_SIZE_BITS-1:0]       ARSIZE_S1,
	output [1:0]                      ARBURST_S1,
	output logic                      ARVALID_S1,
	input                             ARREADY_S1,
	input [`AXI_IDS_BITS-1:0]         RID_S1,
	input [`AXI_DATA_BITS-1:0]        RDATA_S1,
	input [1:0]                       RRESP_S1,
	input                             RLAST_S1,
	input                             RVALID_S1,
	output logic                      RREADY_S1,
	// S2
	// WRITE
	output logic [`AXI_IDS_BITS-1:0]  AWID_S2,
	output [`AXI_ADDR_BITS-1:0]       AWADDR_S2,
	output [`AXI_LEN_BITS-1:0]        AWLEN_S2,
	output [`AXI_SIZE_BITS-1:0]       AWSIZE_S2,
	output [1:0]                      AWBURST_S2,
	output logic                      AWVALID_S2,
	input                             AWREADY_S2,
	output logic [`AXI_DATA_BITS-1:0] WDATA_S2,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S2,
	output logic                      WLAST_S2,
	output logic                      WVALID_S2,
	input                             WREADY_S2,
	input [`AXI_IDS_BITS-1:0]         BID_S2,
	input [1:0]                       BRESP_S2,
	input                             BVALID_S2,
	output logic                      BREADY_S2,
	// READ
	output logic [`AXI_IDS_BITS-1:0]  ARID_S2,
	output [`AXI_ADDR_BITS-1:0]       ARADDR_S2,
	output [`AXI_LEN_BITS-1:0]        ARLEN_S2,
	output [`AXI_SIZE_BITS-1:0]       ARSIZE_S2,
	output logic [1:0]                ARBURST_S2,
	output logic                      ARVALID_S2,
	input                             ARREADY_S2,
	input [`AXI_IDS_BITS-1:0]         RID_S2,
	input [`AXI_DATA_BITS-1:0]        RDATA_S2,
	input [1:0]                       RRESP_S2,
	input                             RLAST_S2,
	input                             RVALID_S2,
	output logic                      RREADY_S2,
	// S3
	// WRITE
	output logic [`AXI_IDS_BITS-1:0]  AWID_S3,
	output [`AXI_ADDR_BITS-1:0]       AWADDR_S3,
	output [`AXI_LEN_BITS-1:0]        AWLEN_S3,
	output [`AXI_SIZE_BITS-1:0]       AWSIZE_S3,
	output [1:0]                      AWBURST_S3,
	output logic                      AWVALID_S3,
	input                             AWREADY_S3,
	output logic [`AXI_DATA_BITS-1:0] WDATA_S3,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S3,
	output logic                      WLAST_S3,
	output logic                      WVALID_S3,
	input                             WREADY_S3,
	input [`AXI_IDS_BITS-1:0]         BID_S3,
	input [1:0]                       BRESP_S3,
	input                             BVALID_S3,
	output  logic                     BREADY_S3,
	// READ
	output logic [`AXI_IDS_BITS-1:0]  ARID_S3,
	output [`AXI_ADDR_BITS-1:0]       ARADDR_S3,
	output [`AXI_LEN_BITS-1:0]        ARLEN_S3,
	output [`AXI_SIZE_BITS-1:0]       ARSIZE_S3,
	output logic [1:0]                ARBURST_S3,
	output logic                      ARVALID_S3,
	input                             ARREADY_S3,
	input [`AXI_IDS_BITS-1:0]         RID_S3,
	input [`AXI_DATA_BITS-1:0]        RDATA_S3,
	input [1:0]                       RRESP_S3,
	input                             RLAST_S3,
	input                             RVALID_S3,
	output logic                      RREADY_S3,
	// S4
	// WRITE
	output logic [`AXI_IDS_BITS-1:0]  AWID_S4,
	output [`AXI_ADDR_BITS-1:0]       AWADDR_S4,
	output [`AXI_LEN_BITS-1:0]        AWLEN_S4,
	output [`AXI_SIZE_BITS-1:0]       AWSIZE_S4,
	output [1:0]                      AWBURST_S4,
	output logic                      AWVALID_S4,
	input                             AWREADY_S4,
	output logic [`AXI_DATA_BITS-1:0] WDATA_S4,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S4,
	output logic                      WLAST_S4,
	output logic                      WVALID_S4,
	input                             WREADY_S4,
	input [`AXI_IDS_BITS-1:0]         BID_S4,
	input [1:0]                       BRESP_S4,
	input                             BVALID_S4,
	output logic                      BREADY_S4,
	// READ
	output logic [`AXI_IDS_BITS-1:0]  ARID_S4,
	output [`AXI_ADDR_BITS-1:0]       ARADDR_S4,
	output [`AXI_LEN_BITS-1:0]        ARLEN_S4,
	output [`AXI_SIZE_BITS-1:0]       ARSIZE_S4,
	output [1:0]                      ARBURST_S4,
	output logic                      ARVALID_S4,
	input                             ARREADY_S4,
	input [`AXI_IDS_BITS-1:0]         RID_S4,
	input [`AXI_DATA_BITS-1:0]        RDATA_S4,
	input [1:0]                       RRESP_S4,
	input                             RLAST_S4,
	input                             RVALID_S4,
	output logic                      RREADY_S4,
	// S5
	// WRITE
	
	output logic [`AXI_IDS_BITS-1:0]  AWID_S5,
	output [`AXI_ADDR_BITS-1:0]       AWADDR_S5,
	output [`AXI_LEN_BITS-1:0]        AWLEN_S5,
	output [`AXI_SIZE_BITS-1:0]       AWSIZE_S5,
	output [1:0]                      AWBURST_S5,
	output logic                      AWVALID_S5,
	input                             AWREADY_S5,
	output logic [`AXI_DATA_BITS-1:0] WDATA_S5,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S5,
	output logic                      WLAST_S5,
	output logic                      WVALID_S5,
	input                             WREADY_S5,
	input [`AXI_IDS_BITS-1:0]         BID_S5,
	input [1:0]                       BRESP_S5,
	input                             BVALID_S5,
	output logic                      BREADY_S5,
	// READ
	output logic [`AXI_IDS_BITS-1:0]  ARID_S5,
	output [`AXI_ADDR_BITS-1:0]       ARADDR_S5,
	output [`AXI_LEN_BITS-1:0]        ARLEN_S5,
	output [`AXI_SIZE_BITS-1:0]       ARSIZE_S5,
	output [1:0]                      ARBURST_S5,
	output logic                      ARVALID_S5,
	input                             ARREADY_S5,
	input [`AXI_IDS_BITS-1:0]         RID_S5,
	input [`AXI_DATA_BITS-1:0]        RDATA_S5,
	input [1:0]                       RRESP_S5,
	input                             RLAST_S5,
	input                             RVALID_S5,
	output logic                      RREADY_S5
) ;
    
logic [31:0] ARADDR_M0_buf  ;
logic [3:0]  ARLEN_M0_buf   ;
logic [2:0]  ARSIZE_M0_buf  ;
logic [1:0]  ARBURST_M0_buf ;
logic [31:0] ARADDR_M1_buf  ;
logic [3:0]  ARLEN_M1_buf   ;
logic [2:0]  ARSIZE_M1_buf  ;
logic [1:0]  ARBURST_M1_buf ;
logic [31:0] AWADDR_M1_buf  ;

logic [2:0]  cs_AXI_W, cs_AXI_R, ns_AXI_W, ns_AXI_R ;
logic [2:0]  AR_sel ;
logic [1:0]  AW_sel ;
logic [2:0]  R_sel,W_sel ;
logic 		 AR_M0_check, AR_M1_check, AW_M1_check ;
// 6 SLAVES MEMORY ADDRESS --> { AxADDR_Mx[31:28] , AxADDR_Mx[19:16] }
parameter ADDR_ROM		   = 8'h00 ;
parameter ADDR_IM  		   = 8'h01 ;
parameter ADDR_DM		   = 8'h02 ;
parameter ADDR_Sensor_ctrl = 8'h10 ;
parameter ADDR_WDT 		   = 8'h11 ;
parameter ADDR_DRAM 	   = 8'h20 ;
// Slave selection
parameter ROM		  	   = 3'd0  ;
parameter IM  		  	   = 3'd1  ;
parameter DM		  	   = 3'd2  ;
parameter Sensor_ctrl 	   = 3'd3  ; 
parameter WDT 		  	   = 3'd4  ; 
parameter DRAM 	      	   = 3'd5  ; 
parameter WRONG_SLAVE 	   = 3'd7  ;
/* ==========================================    AR/AW check    ========================================== */

always_comb begin
	priority if (ARADDR_M0 < 32'h0000_2000) // ROM
		AR_M0_check = 1'b1 ;
	else if (ARADDR_M0 >= 32'h0001_0000 && ARADDR_M0 <= 32'h0002_FFFF)  // IM or DM
		AR_M0_check = 1'b1 ;
	else if (ARADDR_M0 >= 32'h1000_0000 && ARADDR_M0 <= 32'h1000_03FF)  // Sensor_ctrl
		AR_M0_check = 1'b1 ;
	else if (ARADDR_M0 >= 32'h1001_0000 && ARADDR_M0 <= 32'h1001_03FF)  // WDT
		AR_M0_check = 1'b1 ;
	else if (ARADDR_M0 >= 32'h2000_0000 && ARADDR_M0 <= 32'h201F_FFFF)  // DRAM ARADDR_M0[31:16] > 16'h1FFF && ARADDR_M0[31:16] < 16'h2020
		AR_M0_check = 1'b1 ;
	else
		AR_M0_check = 1'b0 ;
end

always_comb begin
	priority if (ARADDR_M1 < 32'h0000_2000) // ROM
		AR_M1_check = 1'b1 ;
	else if (ARADDR_M1 >= 32'h0001_0000 && ARADDR_M1 <= 32'h0002_FFFF)  // IM or DM
		AR_M1_check = 1'b1 ;
	else if (ARADDR_M1 >= 32'h1000_0000 && ARADDR_M1 <= 32'h1000_03FF)  // Sensor_ctrl
		AR_M1_check = 1'b1 ;
	else if (ARADDR_M1 >= 32'h1001_0000 && ARADDR_M1 <= 32'h1001_03FF)  // WDT
		AR_M1_check = 1'b1 ;
	else if (ARADDR_M1 >= 32'h2000_0000 && ARADDR_M1 <= 32'h201F_FFFF)  // DRAM ARADDR_M0[31:16] > 16'h1FFF && ARADDR_M0[31:16] < 16'h2020
		AR_M1_check = 1'b1 ;
	else
		AR_M1_check = 1'b0 ;
end

always_comb begin
	priority if (AWADDR_M1 < 32'h0000_2000) // ROM
		AW_M1_check = 1'b0 ;
	else if (AWADDR_M1 >= 32'h0001_0000 && AWADDR_M1 <= 32'h0002_FFFF)  // IM or DM
		AW_M1_check = 1'b1 ;
	else if (AWADDR_M1 >= 32'h1000_0000 && AWADDR_M1 <= 32'h1000_03FF)  // Sensor_ctrl
		AW_M1_check = 1'b1 ;
	else if (AWADDR_M1 >= 32'h1001_0000 && AWADDR_M1 <= 32'h1001_03FF)  // WDT
		AW_M1_check = 1'b1 ;
	else if (AWADDR_M1 >= 32'h2000_0000 && AWADDR_M1 <= 32'h201F_FFFF)  // DRAM ARADDR_M0[31:16] > 16'h1FFF && ARADDR_M0[31:16] < 16'h2020
		AW_M1_check = 1'b1 ;
	else
		AW_M1_check = 1'b0 ;
end

/* ==========================================    BUS READ FSM    ========================================== */
// PARAMETERS OF READ STATES
parameter READ_IDLE = 3'd0 ;
parameter AR_M0     = 3'd1 ; 
parameter R_M0      = 3'd2 ; 
parameter AR_M1     = 3'd3 ; 
parameter R_M1      = 3'd4 ; 
// PARAMETERS OF READ STATES
parameter WRITE_IDLE = 3'd0 ;
parameter AW_M1      = 3'd1 ;
parameter W_M1       = 3'd2 ; 
// FSM OF READ
always_ff @ (posedge ACLK or negedge ARESETn) begin
	if (!ARESETn) 
        cs_AXI_R <= READ_IDLE ;
	else
		cs_AXI_R <= ns_AXI_R ;
end
// Next state generator (READ)
always_comb begin 
	case(cs_AXI_R)
		READ_IDLE : begin
			if (ARVALID_M0 && AR_M0_check)
				ns_AXI_R = AR_M0 ;
			else if (ARVALID_M1 && AR_M1_check) 
				ns_AXI_R = AR_M1 ;
			else
				ns_AXI_R = READ_IDLE ;
		end
		AR_M0 : begin
			if (ARVALID_M0 && ARREADY_M0)
				ns_AXI_R = R_M0 ;
			else 
				ns_AXI_R = AR_M0 ;
		end
		R_M0 : begin
			if (RVALID_M0 && RREADY_M0 && RLAST_M0) begin
				if (ARVALID_M1 && AR_M1_check)
					ns_AXI_R = AR_M1 ;
				else if (ARVALID_M0 && AR_M0_check)
					ns_AXI_R = AR_M0 ; 
				else 
					ns_AXI_R = READ_IDLE ;
			end
			else
				ns_AXI_R = R_M0 ;
		end
		AR_M1 : begin
			if (ARVALID_M1 && ARREADY_M1)
				ns_AXI_R = R_M1 ;
			else 
				ns_AXI_R = AR_M1 ;
		end
		R_M1 : begin
			if (RVALID_M1 && RREADY_M1 && RLAST_M1) begin
				if (ARVALID_M0 && AR_M0_check)
					ns_AXI_R = AR_M0 ;
				else if (ARVALID_M1 && AR_M1_check)
					ns_AXI_R = AR_M1 ; 
				else 
					ns_AXI_R = READ_IDLE ;
			end
			else
				ns_AXI_R = R_M1 ;
		end
		default: ns_AXI_R = READ_IDLE ;
	endcase
end
// FSM OF WRITE
always_ff @ (posedge ACLK or negedge ARESETn) begin
	if (!ARESETn) 
        cs_AXI_W <= WRITE_IDLE ;
	else
		cs_AXI_W <= ns_AXI_W ;
end
// Next state generator (WRITE)
always_comb begin
	case(cs_AXI_W)
		WRITE_IDLE : begin
			if (AWVALID_M1 && AW_M1_check)
				ns_AXI_W = AW_M1;
			else
				ns_AXI_W = WRITE_IDLE ;
		end
		AW_M1 : begin
			if (AWVALID_M1 && AWREADY_M1)
				ns_AXI_W = W_M1 ;
			else
				ns_AXI_W = AW_M1 ;
		end
		W_M1 : begin
			if (BVALID_M1 && BREADY_M1) begin
				if (AWVALID_M1 && AW_M1_check)
					ns_AXI_W = AW_M1 ;
				else
					ns_AXI_W = WRITE_IDLE ;
			end
			else 
				ns_AXI_W = W_M1 ;
		end
		default : ns_AXI_W = WRITE_IDLE ;
	endcase
end

// BUFFERS
always_ff @ (posedge ACLK or negedge ARESETn)begin
	if (!ARESETn) begin
		ARADDR_M0_buf  <= 32'd0 ;
		ARLEN_M0_buf   <= 4'd0  ;
        ARSIZE_M0_buf  <= 3'd0  ;
        ARBURST_M0_buf <= 2'd0  ;
		ARADDR_M1_buf  <= 32'd0 ;
        ARLEN_M1_buf   <= 4'd0  ;
        ARSIZE_M1_buf  <= 3'd0  ;
        ARBURST_M1_buf <= 2'd0  ;
        AWADDR_M1_buf  <= 32'd0 ;
	end
	else begin
		ARADDR_M0_buf  <= (RVALID_M0 && RREADY_M0 && RLAST_M0) ? 32'd0 :
		    			  (ns_AXI_R == AR_M0) ? ARADDR_M0  : ARADDR_M0_buf  ;
		ARLEN_M0_buf   <= (ns_AXI_R == AR_M0) ? ARLEN_M0   : ARLEN_M0_buf   ;
        ARSIZE_M0_buf  <= (ns_AXI_R == AR_M0) ? ARSIZE_M0  : ARSIZE_M0_buf  ;
        ARBURST_M0_buf <= (ns_AXI_R == AR_M0) ? ARBURST_M0 : ARBURST_M0_buf ;
		ARADDR_M1_buf  <= (RVALID_M1 && RREADY_M1 && RLAST_M1) ? 32'd0 :
		                  (ns_AXI_R == AR_M1) ? ARADDR_M1  : ARADDR_M1_buf  ;
		ARLEN_M1_buf   <= (ns_AXI_R == AR_M1) ? ARLEN_M1   : ARLEN_M1_buf   ;
        ARSIZE_M1_buf  <= (ns_AXI_R == AR_M1) ? ARSIZE_M1  : ARSIZE_M1_buf  ;
        ARBURST_M1_buf <= (ns_AXI_R == AR_M1) ? ARBURST_M1 : ARBURST_M1_buf ;
        AWADDR_M1_buf  <= (BVALID_M1 && BREADY_M1) ? 32'd0 :
	         			  (ns_AXI_W == AW_M1) ? AWADDR_M1  : AWADDR_M1_buf  ;
	end
end
// AR_sel
always_comb begin 
	case(cs_AXI_R)
		READ_IDLE : AR_sel = 3'b010 ; // AR_sel[1:0] == 2'b10 --> Invalid
		AR_M0     : AR_sel = 3'b000 ;
		R_M0      : AR_sel = 3'b100 ;
		AR_M1     : AR_sel = 3'b001 ;
		R_M1      :	AR_sel = 3'b101 ;
		default   :	AR_sel = 3'b010 ; // AR_sel[1:0] == 2'b10 --> Invalid
	endcase
end
// R_sel
always_comb begin
	if (cs_AXI_R==AR_M0 || cs_AXI_R==R_M0) begin // if (AR_sel[1:0] == 2'b00) begin
		case({ ARADDR_M0_buf[31:28] , ARADDR_M0_buf[19:16] })
			ADDR_ROM 		 : R_sel = ROM 		  ;
			ADDR_IM  		 : R_sel = IM  		  ;
			ADDR_DM  		 : R_sel = DM  		  ;
			ADDR_Sensor_ctrl : R_sel = Sensor_ctrl ;
			ADDR_WDT		 : R_sel = WDT	      ;
			ADDR_DRAM		 : R_sel = DRAM		  ;
			default		     : R_sel = WRONG_SLAVE ;	   
		endcase
	end
	else if (cs_AXI_R==AR_M1 || cs_AXI_R==R_M1) begin // if (AR_sel[1:0] == 2'b01) begin
		case({ ARADDR_M1_buf[31:28] , ARADDR_M1_buf[19:16] })
			ADDR_ROM 		 : R_sel = ROM 		  ;
			ADDR_IM  		 : R_sel = IM 		  ;
			ADDR_DM  		 : R_sel = DM 		  ;
			ADDR_Sensor_ctrl : R_sel = Sensor_ctrl ;
			ADDR_WDT		 : R_sel = WDT  		  ;
			ADDR_DRAM		 : R_sel = DRAM 		  ;
			default		     : R_sel = WRONG_SLAVE ;	   
		endcase
	end
	else
		R_sel = WRONG_SLAVE ;
end
// AW_sel
always_comb begin
	case(cs_AXI_W)
		WRITE_IDLE : AW_sel = 2'b10 ;
		AW_M1      : AW_sel = 2'b01 ;
		W_M1       : AW_sel = 2'b01 ;
		default    : AW_sel = 2'b10 ;
	endcase
end
// W_sel
	always_comb begin		
		if (cs_AXI_W==AW_M1 || cs_AXI_W==W_M1) begin // if (AW_sel == 2'b01)
			case({ AWADDR_M1_buf[31:28] , AWADDR_M1_buf[19:16] })
				ADDR_IM 		 : W_sel = IM		   ;
				ADDR_DM 		 : W_sel = DM          ;
				ADDR_Sensor_ctrl : W_sel = Sensor_ctrl ;
				ADDR_WDT 		 : W_sel = WDT         ;
				ADDR_DRAM        : W_sel = DRAM        ;
			endcase
		end
		else
		    W_sel = WRONG_SLAVE ;
	end

/////////////////////////////////////////////////////////////	
//SLAVE INTERFACE FOR MASTERS
always_comb begin
	if (cs_AXI_W==AW_M1 || cs_AXI_W==W_M1) begin
		case(W_sel)
			IM : begin
				AWREADY_M1 = AWREADY_S1  ;
				WREADY_M1  = WREADY_S1   ;
				BID_M1     = BID_S1[3:0] ;
				BRESP_M1   = BRESP_S1    ;
				BVALID_M1  = BVALID_S1   ;
			end
			DM : begin
				AWREADY_M1 = AWREADY_S2 ;
				WREADY_M1 = WREADY_S2   ;
				BID_M1 = BID_S2[3:0]    ;
				BRESP_M1 = BRESP_S2     ;
				BVALID_M1 = BVALID_S2   ;
			end
			Sensor_ctrl : begin
				AWREADY_M1 = AWREADY_S3  ;
				WREADY_M1  = WREADY_S3   ;
				BID_M1     = BID_S3[3:0] ;
				BRESP_M1   = BRESP_S3    ;
				BVALID_M1  = BVALID_S3   ;
			end
			WDT : begin
				AWREADY_M1 = AWREADY_S4  ;
				WREADY_M1  = WREADY_S4   ;
				BID_M1     = BID_S4[3:0] ;
				BRESP_M1   = BRESP_S4    ;
				BVALID_M1  = BVALID_S4   ;
			end
			DRAM : begin
				AWREADY_M1 = AWREADY_S5  ;
				WREADY_M1  = WREADY_S5   ;
				BID_M1     = BID_S5[3:0] ;
				BRESP_M1   = BRESP_S5    ;
				BVALID_M1  = BVALID_S5   ;
			end
			default : begin
				AWREADY_M1 = 1'b0 ;
				WREADY_M1  = 1'b0 ;
				BID_M1     = 4'b0 ;
				BRESP_M1   = 2'b0 ;
				BVALID_M1  = 1'b0 ;
			end
		endcase
	end
	else begin
		AWREADY_M1 = 1'b0 ;
		WREADY_M1  = 1'b0 ;
		BID_M1     = 4'b0 ;
		BRESP_M1   = 2'b0 ;
		BVALID_M1  = 1'b0 ;
	end
end
always_comb begin
	if (cs_AXI_R==AR_M0 || cs_AXI_R==R_M0) begin
		ARREADY_M1 = 1'd0  ;
		RID_M1     = 4'd0  ;
		RDATA_M1   = 32'd0 ;
		RRESP_M1   = 2'd0  ;
		RLAST_M1   = 1'd0  ;
		RVALID_M1  = 1'd0  ;
		case(R_sel)
			ROM : begin
				ARREADY_M0 = ARREADY_S0 ;
				RID_M0 = RID_S0[3:0]    ;
				RDATA_M0 = RDATA_S0     ;
				RRESP_M0 = RRESP_S0     ;
				RLAST_M0 = RLAST_S0     ;
				RVALID_M0 = RVALID_S0   ;
			end
			IM : begin
				ARREADY_M0 = ARREADY_S1 ;
				RID_M0 = RID_S1[3:0]    ;
				RDATA_M0 = RDATA_S1 	;
				RRESP_M0 = RRESP_S1 	;
				RLAST_M0 = RLAST_S1 	;
				RVALID_M0 = RVALID_S1 	;
			end
			DM : begin
				ARREADY_M0 = ARREADY_S2 ;
				RID_M0 = RID_S2[3:0] 	;
				RDATA_M0 = RDATA_S2 	;
				RRESP_M0 = RRESP_S2 	;
				RLAST_M0 = RLAST_S2 	;
				RVALID_M0 = RVALID_S2 	;
			end
			Sensor_ctrl : begin
				ARREADY_M0 = ARREADY_S3 ;
				RID_M0 = RID_S3[3:0] 	;
				RDATA_M0 = RDATA_S3 	;
				RRESP_M0 = RRESP_S3 	;
				RLAST_M0 = RLAST_S3 	;
				RVALID_M0 = RVALID_S3 	;
			end
			WDT : begin
				ARREADY_M0 = ARREADY_S4 ;
				RID_M0 = RID_S4[3:0] 	;
				RDATA_M0 = RDATA_S4 	;
				RRESP_M0 = RRESP_S4 	;
				RLAST_M0 = RLAST_S4 	;
				RVALID_M0 = RVALID_S4 	;
			end
			DRAM : begin
				ARREADY_M0 = ARREADY_S5 ;
				RID_M0 = RID_S5[3:0] 	;
				RDATA_M0 = RDATA_S5 	;
				RRESP_M0 = RRESP_S5 	;
				RLAST_M0 = RLAST_S5 	;
				RVALID_M0 = RVALID_S5 	;
			end
			default : begin
				ARREADY_M0 = 1'b0  ;
				RID_M0     = 4'b0  ;
				RDATA_M0   = 32'b0 ;
				RRESP_M0   = 2'b0  ;
				RLAST_M0   = 1'b0  ;
				RVALID_M0  = 1'b0  ;
			end
		endcase
	end
	else if (cs_AXI_R==AR_M1 || cs_AXI_R==R_M1)begin
		ARREADY_M0 = 1'b0  ;
		RID_M0     = 4'b0  ;
		RDATA_M0   = 32'b0 ;
		RRESP_M0   = 2'b0  ;
		RLAST_M0   = 1'b0  ;
		RVALID_M0  = 1'b0  ;
		case(R_sel)
			ROM : begin
				ARREADY_M1 = ARREADY_S0  ;
				RID_M1     = RID_S0[3:0] ;
				RDATA_M1   = RDATA_S0    ;
				RRESP_M1   = RRESP_S0    ;
				RLAST_M1   = RLAST_S0    ;
				RVALID_M1  = RVALID_S0   ;
			end
			IM : begin
				ARREADY_M1 = ARREADY_S1 ;
				RID_M1 = RID_S1[3:0]    ;
				RDATA_M1 = RDATA_S1     ;
				RRESP_M1 = RRESP_S1     ;
				RLAST_M1 = RLAST_S1     ;
				RVALID_M1 = RVALID_S1   ;
			end
			DM : begin
				ARREADY_M1 = ARREADY_S2 ;
				RID_M1 = RID_S2[3:0]    ;
				RDATA_M1 = RDATA_S2	 	;
				RRESP_M1 = RRESP_S2 	;
				RLAST_M1 = RLAST_S2 	;
				RVALID_M1 = RVALID_S2 	;
			end
			Sensor_ctrl : begin
				ARREADY_M1 = ARREADY_S3 ;
				RID_M1 = RID_S3[3:0] 	;
				RDATA_M1 = RDATA_S3 	;
				RRESP_M1 = RRESP_S3 	;
				RLAST_M1 = RLAST_S3 	;
				RVALID_M1 = RVALID_S3 	;
			end
			WDT : begin
				ARREADY_M1 = ARREADY_S4 ;
				RID_M1 = RID_S4[3:0] 	;
				RDATA_M1 = RDATA_S4 	;
				RRESP_M1 = RRESP_S4 	;
				RLAST_M1 = RLAST_S4 	;
				RVALID_M1 = RVALID_S4 	;
			end
			DRAM : begin
				ARREADY_M1 = ARREADY_S5 ;
				RID_M1 = RID_S5[3:0] 	;
				RDATA_M1 = RDATA_S5 	;
				RRESP_M1 = RRESP_S5 	;
				RLAST_M1 = RLAST_S5 	;
				RVALID_M1 = RVALID_S5 	;
			end			
			default : begin
				ARREADY_M1 = 1'b0  ;
				RID_M1     = 4'b0  ;
				RDATA_M1   = 32'b0 ;
				RRESP_M1   = 2'b0  ;
				RLAST_M1   = 1'b0  ;
				RVALID_M1  = 1'b0  ;
			end
		endcase
	end
	else begin
		ARREADY_M0 = 1'b0  ;
		RID_M0     = 4'b0  ;
		RDATA_M0   = 32'b0 ;
		RRESP_M0   = 2'b0  ;
		RLAST_M0   = 1'b0  ;
		RVALID_M0  = 1'b0  ;
		ARREADY_M1 = 1'b0  ;
		RID_M1     = 4'b0  ;
		RDATA_M1   = 32'b0 ;
		RRESP_M1   = 2'b0  ;
		RLAST_M1   = 1'b0  ;
		RVALID_M1  = 1'b0  ;
	end
end


//MASTER INTERFACE FOR SLAVES

//READ ADDRESS0
assign ARID_S0    = (AR_sel[0]) ? {4'b0,ARID_M1} : {4'b0,ARID_M0} ;
assign ARADDR_S0  = (AR_sel[0]) ? ARADDR_M1_buf  : ARADDR_M0_buf  ;
assign ARLEN_S0   = (AR_sel[0]) ? ARLEN_M1_buf   : ARLEN_M0_buf   ;
assign ARSIZE_S0  = (AR_sel[0]) ? ARSIZE_M1_buf  : ARSIZE_M0_buf  ;
assign ARBURST_S0 = (AR_sel[0]) ? ARBURST_M1_buf : ARBURST_M0_buf ;
assign ARVALID_S0 = (R_sel == ROM) ?
	    			(AR_sel[0]) ? ARVALID_M1 : ARVALID_M0 : 1'b0 ;
//READ DATA0
assign RREADY_S0  = (AR_sel[0]) ? RREADY_M1 : RREADY_M0 ;

//READ ADDRESS1
assign ARID_S1    = (AR_sel[0]) ? {4'b0,ARID_M1} : {4'b0,ARID_M0} ;
assign ARADDR_S1  = (AR_sel[0]) ? ARADDR_M1_buf  : ARADDR_M0_buf  ;
assign ARLEN_S1   = (AR_sel[0]) ? ARLEN_M1_buf   : ARLEN_M0_buf   ;
assign ARSIZE_S1  = (AR_sel[0]) ? ARSIZE_M1_buf  : ARSIZE_M0_buf  ;
assign ARBURST_S1 = (AR_sel[0]) ? ARBURST_M1_buf : ARBURST_M0_buf ;
assign ARVALID_S1 = (R_sel == IM) ?
	    			(AR_sel[0]) ? ARVALID_M1 : ARVALID_M0 : 1'b0 ;
//READ DATA1
assign RREADY_S1  = (AR_sel[0]) ? RREADY_M1 : RREADY_M0 ;

//READ ADDRESS2
assign ARID_S2    = (AR_sel[0]) ? {4'b0,ARID_M1} : {4'b0,ARID_M0} ;
assign ARADDR_S2  = (AR_sel[0]) ? ARADDR_M1_buf  : ARADDR_M0_buf  ;
assign ARLEN_S2   = (AR_sel[0]) ? ARLEN_M1_buf   : ARLEN_M0_buf   ;
assign ARSIZE_S2  = (AR_sel[0]) ? ARSIZE_M1_buf  : ARSIZE_M0_buf  ;
assign ARBURST_S2 = (AR_sel[0]) ? ARBURST_M1_buf : ARBURST_M0_buf ;
assign ARVALID_S2 = (R_sel == DM) ?
	    			(AR_sel[0]) ? ARVALID_M1 : ARVALID_M0 : 1'b0 ;
//READ DATA2
assign RREADY_S2  = (AR_sel[0]) ? RREADY_M1 : RREADY_M0 ;

//READ ADDRESS3
assign ARID_S3    = (AR_sel[0]) ? {4'b0,ARID_M1} : {4'b0,ARID_M0} ;
assign ARADDR_S3  = (AR_sel[0]) ? ARADDR_M1_buf  : ARADDR_M0_buf  ;
assign ARLEN_S3   = (AR_sel[0]) ? ARLEN_M1_buf   : ARLEN_M0_buf   ;
assign ARSIZE_S3  = (AR_sel[0]) ? ARSIZE_M1_buf  : ARSIZE_M0_buf  ;
assign ARBURST_S3 = (AR_sel[0]) ? ARBURST_M1_buf : ARBURST_M0_buf ;
assign ARVALID_S3 = (R_sel == Sensor_ctrl) ?
	    			(AR_sel[0]) ? ARVALID_M1 : ARVALID_M0 : 1'b0 ;
//READ DATA3
assign RREADY_S3  = (AR_sel[0]) ? RREADY_M1 : RREADY_M0 ;

//READ ADDRESS4
assign ARID_S4    = (AR_sel[0]) ? {4'b0,ARID_M1} : {4'b0,ARID_M0} ;
assign ARADDR_S4  = (AR_sel[0]) ? ARADDR_M1_buf  : ARADDR_M0_buf  ;
assign ARLEN_S4   = (AR_sel[0]) ? ARLEN_M1_buf   : ARLEN_M0_buf   ;
assign ARSIZE_S4  = (AR_sel[0]) ? ARSIZE_M1_buf  : ARSIZE_M0_buf  ;
assign ARBURST_S4 = (AR_sel[0]) ? ARBURST_M1_buf : ARBURST_M0_buf ;
assign ARVALID_S4 = (R_sel == WDT) ?
	    			(AR_sel[0]) ? ARVALID_M1 : ARVALID_M0 : 1'b0 ;
//READ DATA4
assign RREADY_S4  = (AR_sel[0]) ? RREADY_M1 : RREADY_M0 ;

//READ ADDRESS5
assign ARID_S5    = (AR_sel[0]) ? {4'b0,ARID_M1} : {4'b0,ARID_M0} ;
assign ARADDR_S5  = (AR_sel[0]) ? ARADDR_M1_buf  : ARADDR_M0_buf  ;
assign ARLEN_S5   = (AR_sel[0]) ? ARLEN_M1_buf   : ARLEN_M0_buf   ;
assign ARSIZE_S5  = (AR_sel[0]) ? ARSIZE_M1_buf  : ARSIZE_M0_buf  ;
assign ARBURST_S5 = (AR_sel[0]) ? ARBURST_M1_buf : ARBURST_M0_buf ;
assign ARVALID_S5 = (R_sel == DRAM) ?
	    			(AR_sel[0]) ? ARVALID_M1 : ARVALID_M0 : 1'b0 ;
//READ DATA5
assign RREADY_S5  = (AR_sel[0]) ? RREADY_M1 : RREADY_M0 ;

//WRITE ADDRESS1
assign AWID_S1    = (AW_sel[0]) ? {4'b0,AWID_M1} : 8'b0  ;
assign AWADDR_S1  = (AW_sel[0]) ? AWADDR_M1_buf  : 32'b0 ;
assign AWLEN_S1   = (AW_sel[0]) ? AWLEN_M1       : 4'b0  ;
assign AWSIZE_S1  = (AW_sel[0]) ? AWSIZE_M1      : 3'b0  ;
assign AWBURST_S1 = (AW_sel[0]) ? AWBURST_M1     : 2'b0  ;
assign AWVALID_S1 = (W_sel == IM) ?
    				(AW_sel[0]) ? AWVALID_M1 : 1'b0 : 1'b0 ;
//WRITE DATA1
assign WDATA_S1   = (AW_sel[0]) ? (W_sel == IM) ? WDATA_M1  : 32'b0 : 32'b0 ;
assign WSTRB_S1   = (AW_sel[0]) ? (W_sel == IM) ? WSTRB_M1  : 4'hf  : 4'hf  ;
assign WLAST_S1   = (AW_sel[0]) ? (W_sel == IM) ? WLAST_M1  : 1'b0  : 1'b0  ;
assign WVALID_S1  = (AW_sel[0]) ? (W_sel == IM) ? WVALID_M1 : 1'b0  : 1'b0  ;
//WRITE RESPONSE1
assign BREADY_S1  = (AW_sel[0]) ? (W_sel == IM) ? BREADY_M1 : 1'b0 : 1'b0   ;

//WRITE ADDRESS2
assign AWID_S2    = (AW_sel[0]) ? {4'b0,AWID_M1} : 8'b0  ;
assign AWADDR_S2  = (AW_sel[0]) ? AWADDR_M1_buf  : 32'b0 ;
assign AWLEN_S2   = (AW_sel[0]) ? AWLEN_M1       : 4'b0  ;
assign AWSIZE_S2  = (AW_sel[0]) ? AWSIZE_M1      : 3'b0  ;
assign AWBURST_S2 = (AW_sel[0]) ? AWBURST_M1     : 2'b0  ;
assign AWVALID_S2 = (W_sel == DM) ?
    				(AW_sel[0]) ? AWVALID_M1 : 1'b0 : 1'b0 ;
//WRITE DATA2
assign WDATA_S2   = (AW_sel[0]) ? (W_sel == DM) ? WDATA_M1  : 32'b0 : 32'b0 ;
assign WSTRB_S2   = (AW_sel[0]) ? (W_sel == DM) ? WSTRB_M1  : 4'hf  : 4'hf  ;
assign WLAST_S2   = (AW_sel[0]) ? (W_sel == DM) ? WLAST_M1  : 1'b0  : 1'b0  ;
assign WVALID_S2  = (AW_sel[0]) ? (W_sel == DM) ? WVALID_M1 : 1'b0  : 1'b0  ;
//WRITE RESPONSE2
assign BREADY_S2  = (AW_sel[0]) ? (W_sel == DM) ? BREADY_M1 : 1'b0 : 1'b0   ;

//WRITE ADDRESS3
assign AWID_S3    = (AW_sel[0]) ? {4'b0,AWID_M1} : 8'b0  ;
assign AWADDR_S3  = (AW_sel[0]) ? AWADDR_M1_buf  : 32'b0 ;
assign AWLEN_S3   = (AW_sel[0]) ? AWLEN_M1       : 4'b0  ;
assign AWSIZE_S3  = (AW_sel[0]) ? AWSIZE_M1      : 3'b0  ;
assign AWBURST_S3 = (AW_sel[0]) ? AWBURST_M1     : 2'b0  ;
assign AWVALID_S3 = (W_sel == Sensor_ctrl) ?
    				(AW_sel[0]) ? AWVALID_M1 : 1'b0 : 1'b0 ;
//WRITE DATA3
assign WDATA_S3   = (AW_sel[0]) ? (W_sel == Sensor_ctrl) ? WDATA_M1  : 32'b0 : 32'b0 ;
assign WSTRB_S3   = (AW_sel[0]) ? (W_sel == Sensor_ctrl) ? WSTRB_M1  : 4'hf  : 4'hf  ;
assign WLAST_S3   = (AW_sel[0]) ? (W_sel == Sensor_ctrl) ? WLAST_M1  : 1'b0  : 1'b0  ;
assign WVALID_S3  = (AW_sel[0]) ? (W_sel == Sensor_ctrl) ? WVALID_M1 : 1'b0  : 1'b0  ;
//WRITE RESPONSE3
assign BREADY_S3  = (AW_sel[0]) ? (W_sel == Sensor_ctrl) ? BREADY_M1 : 1'b0 : 1'b0   ;

//WRITE ADDRESS4
assign AWID_S4    = (AW_sel[0]) ? {4'b0,AWID_M1} : 8'b0  ;
assign AWADDR_S4  = (AW_sel[0]) ? AWADDR_M1_buf  : 32'b0 ;
assign AWLEN_S4   = (AW_sel[0]) ? AWLEN_M1       : 4'b0  ;
assign AWSIZE_S4  = (AW_sel[0]) ? AWSIZE_M1      : 3'b0  ;
assign AWBURST_S4 = (AW_sel[0]) ? AWBURST_M1     : 2'b0  ;
assign AWVALID_S4 = (W_sel == WDT) ?
    				(AW_sel[0]) ? AWVALID_M1 : 1'b0 : 1'b0 ;
//WRITE DATA4
assign WDATA_S4   = (AW_sel[0]) ? (W_sel == WDT) ? WDATA_M1  : 32'b0 : 32'b0 ;
assign WSTRB_S4   = (AW_sel[0]) ? (W_sel == WDT) ? WSTRB_M1  : 4'hf  : 4'hf  ;
assign WLAST_S4   = (AW_sel[0]) ? (W_sel == WDT) ? WLAST_M1  : 1'b0  : 1'b0  ;
assign WVALID_S4  = (AW_sel[0]) ? (W_sel == WDT) ? WVALID_M1 : 1'b0  : 1'b0  ;
//WRITE RESPONSE4
assign BREADY_S4  = (AW_sel[0]) ? (W_sel == WDT) ? BREADY_M1 : 1'b0 : 1'b0   ;

//WRITE ADDRESS5
assign AWID_S5    = (AW_sel[0]) ? {4'b0,AWID_M1} : 8'b0  ;
assign AWADDR_S5  = (AW_sel[0]) ? AWADDR_M1_buf  : 32'b0 ;
assign AWLEN_S5   = (AW_sel[0]) ? AWLEN_M1       : 4'b0  ;
assign AWSIZE_S5  = (AW_sel[0]) ? AWSIZE_M1      : 3'b0  ;
assign AWBURST_S5 = (AW_sel[0]) ? AWBURST_M1     : 2'b0  ;
assign AWVALID_S5 = (W_sel == DRAM) ?
    				(AW_sel[0]) ? AWVALID_M1 : 1'b0 : 1'b0 ;
//WRITE DATA5
assign WDATA_S5   = (AW_sel[0]) ? (W_sel == DRAM) ? WDATA_M1  : 32'b0 : 32'b0 ;
assign WSTRB_S5   = (AW_sel[0]) ? (W_sel == DRAM) ? WSTRB_M1  : 4'hf  : 4'hf  ;
assign WLAST_S5   = (AW_sel[0]) ? (W_sel == DRAM) ? WLAST_M1  : 1'b0  : 1'b0  ;
assign WVALID_S5  = (AW_sel[0]) ? (W_sel == DRAM) ? WVALID_M1 : 1'b0  : 1'b0  ;
//WRITE RESPONSE5
assign BREADY_S5  = (AW_sel[0]) ? (W_sel == DRAM) ? BREADY_M1 : 1'b0 : 1'b0   ;
	
endmodule