// 11/24 21:30
// version 4
`include "AXI_define.svh"

module DRAM_wrapper(
    input  logic                      ACLK,
    input  logic                      ARESETn,
    // READ ADDRESS 
    input  logic [ `AXI_IDS_BITS-1:0] ARID,
    input  logic [`AXI_ADDR_BITS-1:0] ARADDR,
    input  logic [ `AXI_LEN_BITS-1:0] ARLEN,
    input  logic [`AXI_SIZE_BITS-1:0] ARSIZE,
    input  logic [               1:0] ARBURST,
    input  logic                      ARVALID,
    output logic                      ARREADY,
    // READ DATA
    output logic [ `AXI_IDS_BITS-1:0] RID,
    output logic [`AXI_DATA_BITS-1:0] RDATA,
    output logic [               1:0] RRESP,
    output logic                      RLAST,
    output logic                      RVALID,
    input  logic                      RREADY,
    // WRITE ADDRESS
    input  logic [ `AXI_IDS_BITS-1:0] AWID,
    input  logic [`AXI_ADDR_BITS-1:0] AWADDR,
    input  logic [`AXI_LEN_BITS-1:0 ] AWLEN,
    input  logic [`AXI_SIZE_BITS-1:0] AWSIZE,
    input  logic [               1:0] AWBURST,
    input  logic                      AWVALID,
    output logic                      AWREADY,
    // WRITE DATA
    input  logic [`AXI_DATA_BITS-1:0] WDATA,
    input  logic [`AXI_STRB_BITS-1:0] WSTRB,
    input  logic                      WLAST,
    input  logic                      WVALID,
    output logic                      WREADY,
    // WRITE RESPONSE
    output logic [ `AXI_IDS_BITS-1:0] BID,
    output logic [               1:0] BRESP,
    output logic                      BVALID,
    input  logic                      BREADY,
    // DRAM interface
    output logic                      DRAM_CSn,
    output logic [               3:0] DRAM_WEn,
    output logic                      DRAM_RASn,
    output logic                      DRAM_CASn,
    output logic [              10:0] DRAM_A,
    output logic [              31:0] DRAM_D,
    input  logic [              31:0] DRAM_Q,
    input  logic                      DRAM_valid
)  ;

logic [31:0] ARADDR_buf, AWADDR_buf ;
logic [2:0]  cs_BUS, ns_BUS ;
logic [3:0]  cs_DRAM, ns_DRAM ;
logic [7:0]  AWID_buf, ARID_buf ;
logic [3:0]  B_counter, ARLEN_buf ;
logic [31:0] RDATA_buf ;
logic [2:0]  T_C, T_R2C, T_RP ;
logic [10:0] ROW_now ;
logic        ROW_hit ;
logic [31:0] DRAM_D_buf ;
logic [3:0]  DRAM_WEn_buf ;


// BUS FSM STATE PARAMETERS
parameter BUS_IDLE          = 3'd0 ;
parameter BUS_WAIT_READ_TC  = 3'd1 ;
parameter BUS_READ          = 3'd2 ;
parameter BUS_READ_BURST    = 3'd3 ; // wait TC
parameter BUS_WAIT_WRITE_TC = 3'd7 ;
parameter BUS_WRITE         = 3'd4 ;
parameter BUS_WRITE_BURST   = 3'd5 ;
parameter BUS_BRESP         = 3'd6 ;
// DRAM FSM STATE PARAMETERS
parameter DRAM_IDLE            = 4'd0  ;
parameter ACT_READ_COL_ACCESS  = 4'd1  ;
parameter ACT_READ_WAIT_TC     = 4'd2  ;
parameter ACT_READ_END         = 4'd3  ; // wait TC
parameter PRE_READ_ROW_ACCESS  = 4'd4  ;
parameter PRE_READ_WAIT_TRP    = 4'd5  ;
parameter ACT_READ_ROW_ACCESS  = 4'd6  ;
parameter ACT_READ_WAIT_TR2C   = 4'd7  ;
parameter PRE_WRITE_ROW_ACCESS = 4'd8  ;
parameter PRE_WRITE_WAIT_TRP   = 4'd9  ;
parameter ACT_WRITE_ROW_ACCESS = 4'd10 ;
parameter ACT_WRITE_WAIT_TR2C  = 4'd11 ;
parameter ACT_WRITE_IDLE       = 4'd12 ; // ???
parameter ACT_WRITE_COL_ACCESS = 4'd13 ;
parameter ACT_WRITE_WAIT_TC    = 4'd14 ;
parameter ACT_WRITE_END        = 4'd15 ;

always_comb begin
    if (ARVALID && ROW_now == ARADDR[22:12])
        ROW_hit = 1'b1 ;
    else if (AWVALID && ROW_now == AWADDR[22:12])
        ROW_hit = 1'b1 ;
    else if (cs_BUS == BUS_READ && ROW_now == ARADDR_buf[22:12])
        ROW_hit = 1'b1 ;
    else if (cs_BUS == BUS_WRITE && ROW_now == AWADDR_buf[22:12])
        ROW_hit = 1'b1 ;
    else
        ROW_hit = 1'b0 ;
end

// assign ROW_hit = (ARVALID && ROW_now == ARADDR[22:12])?1'b1:(AWVALID && ROW_now == AWADDR[22:12])?1'b1:
//     (cs_BUS == 3'b010 && ROW_now == add_save_R[22:12])?1'b1:(cs_BUS == 3'b100 && ROW_now == add_save_W[22:12])?1'b1:1'b0 ;
assign RLAST = (ARLEN_buf < B_counter) ? 1'b1 : 1'b0 ;
assign RDATA = (DRAM_valid) ? DRAM_Q : RDATA_buf ;

// Control signals
logic READ_DRAM ;
assign READ_DRAM = ( (cs_BUS == BUS_IDLE && ARVALID) || cs_BUS == BUS_READ) ;

/* =========================================    BUS FSM    ========================================= */ 
always_ff @ (posedge ACLK or negedge ARESETn) begin // ori: no ayn reset
    if (!ARESETn) 
        cs_BUS <= BUS_IDLE ;
    else
        cs_BUS <= ns_BUS   ;
end 
// NSG
always_comb begin
    case(cs_BUS)
        BUS_IDLE : begin
            if (ARVALID)
                ns_BUS = BUS_WAIT_READ_TC ;
            else if (AWVALID)
                ns_BUS = BUS_WAIT_WRITE_TC ;
            else
                ns_BUS = BUS_IDLE ;
        end
        BUS_WAIT_READ_TC : begin
            ns_BUS = (cs_DRAM == ACT_READ_END) ? BUS_READ : BUS_WAIT_READ_TC ; //READ_DRAM
        end
        BUS_READ : begin
            ns_BUS = (RREADY) ? (RLAST) ? BUS_IDLE : BUS_READ_BURST : BUS_READ ;
        end
        BUS_READ_BURST : begin
            ns_BUS = (cs_DRAM == ACT_READ_END) ? BUS_READ : BUS_READ_BURST ; //READ_burst
        end
        BUS_WAIT_WRITE_TC : begin
            ns_BUS = (cs_DRAM == ACT_WRITE_END) ? BUS_WRITE : BUS_WAIT_WRITE_TC ; //WRITE_DRAM
        end
        BUS_WRITE : begin 
            ns_BUS = (WVALID) ? (WLAST) ? BUS_BRESP : BUS_WRITE_BURST : BUS_WRITE ;
        end
        BUS_WRITE_BURST : begin 
            ns_BUS = (cs_DRAM == ACT_WRITE_END) ? BUS_WRITE : BUS_WRITE_BURST ; //WRITE_burst
        end
        BUS_BRESP : begin
            ns_BUS = (BREADY) ? BUS_IDLE : BUS_BRESP ;
        end
    endcase
end

/* =========================================    DRAM FSM    ========================================= */ 
always_ff @ (posedge ACLK or negedge ARESETn) begin // ori: no ayn reset
    if (!ARESETn) 
        cs_DRAM <= DRAM_IDLE ;
    else if (ns_BUS == 3'b0 || ns_BUS == BUS_READ || ns_BUS == BUS_WRITE || ns_BUS == BUS_BRESP)
        cs_DRAM <= DRAM_IDLE ;
    else
        cs_DRAM <= ns_DRAM   ;
end 
// NSG
always_comb begin
    case(cs_DRAM)
        DRAM_IDLE : begin
            ns_DRAM = (ROW_hit) ? (READ_DRAM) ? BUS_WAIT_READ_TC : ACT_WRITE_IDLE :
                      (READ_DRAM) ? PRE_READ_ROW_ACCESS : PRE_WRITE_ROW_ACCESS ;
        end

        ACT_READ_COL_ACCESS : begin 
            ns_DRAM = ACT_READ_WAIT_TC ;//C_change_initial
        end

        ACT_READ_WAIT_TC : begin
            ns_DRAM = (T_C == 3'd3) ? ACT_READ_END : ACT_READ_WAIT_TC ;//C_change
        end

        ACT_READ_END : begin
            ns_DRAM = DRAM_IDLE ;//end
        end

        ACT_WRITE_IDLE : begin
            ns_DRAM = ACT_WRITE_COL_ACCESS ;
        end

        ACT_WRITE_COL_ACCESS : begin
            ns_DRAM = ACT_WRITE_WAIT_TC ;//C_change_initial
        end

        ACT_WRITE_WAIT_TC : begin
            ns_DRAM = (T_C == 3'd3) ? ACT_WRITE_END : ACT_WRITE_WAIT_TC ;//C_change
        end

        ACT_WRITE_END : begin
            ns_DRAM = DRAM_IDLE ;//end
        end

        PRE_READ_ROW_ACCESS : begin
            ns_DRAM = PRE_READ_WAIT_TRP ;//R_change_initial
        end

        PRE_READ_WAIT_TRP : begin
            ns_DRAM = (T_RP == 3'd3) ? ACT_READ_ROW_ACCESS : PRE_READ_WAIT_TRP ;//R_change
        end

        ACT_READ_ROW_ACCESS : begin
            ns_DRAM = ACT_READ_WAIT_TR2C ;//RToC_initial
        end

        ACT_READ_WAIT_TR2C : begin
            ns_DRAM = (T_R2C == 3'd3)? BUS_WAIT_READ_TC : ACT_READ_WAIT_TR2C ;//RToC
        end

        PRE_WRITE_ROW_ACCESS : begin
            ns_DRAM = PRE_WRITE_WAIT_TRP ;//R_change_initial
        end

        PRE_WRITE_WAIT_TRP : begin
            ns_DRAM = (T_RP == 3'd3) ? ACT_WRITE_ROW_ACCESS : PRE_WRITE_WAIT_TRP ;//R_change
        end

        ACT_WRITE_ROW_ACCESS : begin
            ns_DRAM = ACT_WRITE_WAIT_TR2C ;//RToC_initial
        end

        ACT_WRITE_WAIT_TR2C : begin
            ns_DRAM = (T_R2C == 3'd3) ? ACT_WRITE_COL_ACCESS : ACT_WRITE_WAIT_TR2C ;//RToC
        end
    endcase
end

// BUFFERS & B_counter
always_ff @ (posedge ACLK or negedge ARESETn) begin // ori: no ayn reset
  if(!ARESETn)begin
      ARADDR_buf   <= 32'b0 ;
      AWADDR_buf   <= 32'b0 ;
      RDATA_buf    <= 32'b0 ;
      ARID_buf     <= 8'b0  ;
      AWID_buf     <= 8'b0  ;
      B_counter    <= 4'b0  ;
      ARLEN_buf    <= 4'b0  ;
      ROW_now      <= 11'b0 ;
      DRAM_D_buf   <= 32'b0 ;
      DRAM_WEn_buf <= 4'b0  ;
  end
  else begin
      ARADDR_buf   <= (cs_BUS==BUS_IDLE) ? ARADDR : (cs_BUS==BUS_READ) ? (ARADDR_buf+32'd4) : ARADDR_buf ;
      AWADDR_buf   <= (cs_BUS==BUS_IDLE) ? AWADDR : AWADDR_buf ;
      RDATA_buf    <= (DRAM_valid) ? DRAM_Q:RDATA_buf ;
      ARID_buf     <= (ARVALID) ? ARID:ARID_buf ;
      AWID_buf     <= (AWVALID) ? AWID:AWID_buf ;
      B_counter    <= (cs_BUS==BUS_IDLE) ? 4'b1 : (RVALID && RREADY) ? (B_counter +4'b1) : B_counter ;
      ARLEN_buf    <= (cs_BUS==BUS_IDLE) ? ARLEN : ARLEN_buf ;
      ROW_now      <= (cs_DRAM==ACT_WRITE_ROW_ACCESS)? AWADDR_buf[22:12] : (cs_DRAM==ACT_READ_ROW_ACCESS) ? ARADDR_buf[22:12] : ROW_now ;
      DRAM_D_buf   <= (WVALID) ? WDATA : DRAM_D_buf ;
      DRAM_WEn_buf <= (WVALID) ? WSTRB : DRAM_WEn_buf ;
  end
end

// DELAY TIME COUNTERS
always_ff @ (posedge ACLK or negedge ARESETn) begin
    if (!ARESETn) begin
        T_R2C <= 3'd0 ;
        T_RP  <= 3'd0 ;
        T_C   <= 3'd0 ;
    end
    else begin
        T_RP  <= (cs_DRAM==PRE_WRITE_ROW_ACCESS||cs_DRAM==PRE_READ_ROW_ACCESS) ? 3'b0 : (T_RP+3'b1)   ;
        T_C   <= (cs_DRAM==BUS_WAIT_READ_TC||cs_DRAM==ACT_WRITE_COL_ACCESS)    ? 3'b0 : (T_C+ 3'b1)   ;
        T_R2C <= (cs_DRAM==ACT_WRITE_ROW_ACCESS||cs_DRAM==ACT_READ_ROW_ACCESS) ? 3'b0 : (T_R2C+ 3'b1) ;
    end
end

/* =========================================    BUS output decoder    ========================================= */
always_comb begin
    case(cs_BUS)
        BUS_IDLE : begin
            AWREADY = 1'b1 ;
            WREADY  = 1'b0 ;
            BID     = 8'b0 ;
            BRESP   = 2'b0 ;
            BVALID  = 1'b0 ;
            ARREADY = 1'b1 ;
            RID     = 8'b0 ;
            RRESP   = 2'b0 ;
            RVALID  = 1'b0 ;
        end
        BUS_WAIT_READ_TC : begin
            AWREADY = 1'b0     ;
            WREADY  = 1'b0     ;
            BID     = 8'b0     ;
            BRESP   = 2'b0     ;
            BVALID  = 1'b0     ;
            ARREADY = 1'b0     ;
            RID     = ARID_buf ;
            RRESP   = 2'b0     ;
            RVALID  = 1'b0     ;
        end
        BUS_READ : begin
            AWREADY = 1'b0     ;
            WREADY  = 1'b0     ;
            BID     = 8'b0     ;
            BRESP   = 2'b0     ;
            BVALID  = 1'b0     ;
            ARREADY = 1'b0     ;
            RID     = ARID_buf ;
            RRESP   = 2'b0     ;
            RVALID  = 1'b1     ;
        end
        BUS_READ_BURST : begin
            AWREADY = 1'b0     ;
            WREADY  = 1'b0     ;
            BID     = 8'b0     ;
            BRESP   = 2'b0     ;
            BVALID  = 1'b0     ;
            ARREADY = 1'b0     ;
            RID     = ARID_buf ;
            RRESP   = 2'b00    ;
            RVALID  = 1'b0     ;
        end
        BUS_WRITE : begin
            AWREADY = 1'b0     ;
            WREADY  = 1'b1     ;
            BID     = AWID_buf ;
            BRESP   = 2'b0     ;
            BVALID  = 1'b0     ;
            ARREADY = 1'b0     ;
            RID     = 8'b0     ;
            RRESP   = 2'b0     ;
            RVALID  = 1'b0     ;
        end
        BUS_WRITE_BURST : begin
            AWREADY = 1'b0     ;
            WREADY  = 1'b0     ;
            BID     = AWID_buf ;
            BRESP   = 2'b0     ;
            BVALID  = 1'b0     ;
            ARREADY = 1'b0     ;
            RID     = 8'b0     ;
            RRESP   = 2'b0     ;
            RVALID  = 1'b0     ;
        end
        BUS_BRESP : begin
            AWREADY = 1'b0     ;
            WREADY  = 1'b0     ;
            BID     = AWID_buf ;
            BRESP   = 2'b0     ;
            BVALID  = 1'b1     ;
            ARREADY = 1'b0     ;
            RID     = 8'b0     ;
            RRESP   = 2'b0     ;
            RVALID  = 1'b0     ;
        end
        BUS_WAIT_WRITE_TC : begin
            AWREADY = 1'b0     ;
            WREADY  = 1'b0     ;
            BID     = AWID_buf ;
            BRESP   = 2'b0     ;
            BVALID  = 1'b0     ;
            ARREADY = 1'b0     ;
            RID     = 8'b0     ;
            RRESP   = 2'b0     ;
            RVALID  = 1'b0     ;
        end
    endcase
end

/* =========================================    DRAM output decoder    ========================================= */
always_comb begin
    case(cs_DRAM)
        DRAM_IDLE : begin
            DRAM_CSn  = 1'b0  ;
            DRAM_WEn  = 4'hf  ;
            DRAM_RASn = 1'b1  ;
            DRAM_CASn = 1'b1  ;
            DRAM_A    = 11'b0 ;
            DRAM_D    = 32'b0 ;
        end
        BUS_WAIT_READ_TC : begin
            DRAM_CSn  = 1'b0                    ;
            DRAM_WEn  = 4'hf                    ;
            DRAM_RASn = 1'b1                    ;
            DRAM_CASn = 1'b0                    ;
            DRAM_A    = {1'b0,ARADDR_buf[11:2]} ;
            DRAM_D    = 32'b0                   ;
        end
        ACT_READ_WAIT_TC : begin
            DRAM_CSn  = 1'b0                    ;
            DRAM_WEn  = 4'hf                    ;
            DRAM_RASn = 1'b1                    ;
            DRAM_CASn = 1'b1                    ;
            DRAM_A    = {1'b0,ARADDR_buf[11:2]} ;
            DRAM_D    = 32'b0                   ;
        end
        ACT_READ_END : begin
            DRAM_CSn  = 1'b0  ;
            DRAM_WEn  = 4'hf  ;
            DRAM_RASn = 1'b1  ;
            DRAM_CASn = 1'b1  ;
            DRAM_A    = 11'b0 ;
            DRAM_D    = 32'b0 ;
        end
        ACT_WRITE_IDLE : begin
            DRAM_CSn  = 1'b0  ;
            DRAM_WEn  = 4'hf  ;
            DRAM_RASn = 1'b1  ;
            DRAM_CASn = 1'b1  ; 
            DRAM_A    = 11'b0 ;
            DRAM_D    = 32'b0 ;
        end
        ACT_WRITE_COL_ACCESS : begin
            DRAM_CSn  = 1'b0                    ;
            DRAM_WEn  = DRAM_WEn_buf            ;
            DRAM_RASn = 1'b1                    ;
            DRAM_CASn = 1'b0                    ;
            DRAM_A    = {1'b0,AWADDR_buf[11:2]} ;
            DRAM_D    = DRAM_D_buf              ;
        end
        ACT_WRITE_WAIT_TC : begin
            DRAM_CSn  = 1'b0                    ;
            DRAM_WEn  = DRAM_WEn_buf            ;
            DRAM_RASn = 1'b1                    ;
            DRAM_CASn = 1'b1                    ;
            DRAM_A    = {1'b0,AWADDR_buf[11:2]} ;
            DRAM_D    = DRAM_D_buf              ;
        end
        ACT_WRITE_END : begin
            DRAM_CSn  = 1'b0  ;
            DRAM_WEn  = 4'hf  ;
            DRAM_RASn = 1'b1  ;
            DRAM_CASn = 1'b1  ;
            DRAM_A    = 11'b0 ;
            DRAM_D    = 32'b0 ;
        end
        PRE_READ_ROW_ACCESS : begin
            DRAM_CSn  = 1'b0    ;
            DRAM_WEn  = 4'b0    ;
            DRAM_RASn = 1'b0    ;
            DRAM_CASn = 1'b1    ;
            DRAM_A    = ROW_now ;
            DRAM_D    = 32'b0   ;
        end
        PRE_READ_WAIT_TRP : begin
            DRAM_CSn  = 1'b0    ;
            DRAM_WEn  = 4'hf    ;
            DRAM_RASn = 1'b1    ;
            DRAM_CASn = 1'b1    ;
            DRAM_A    = ROW_now ;
            DRAM_D    = 32'b0   ;
        end
        ACT_READ_ROW_ACCESS : begin
            DRAM_CSn  = 1'b0              ;
            DRAM_WEn  = 4'hf              ;
            DRAM_RASn = 1'b0              ;
            DRAM_CASn = 1'b1              ;
            DRAM_A    = ARADDR_buf[22:12] ;
            DRAM_D    = 32'b0             ;
        end
        ACT_READ_WAIT_TR2C : begin
            DRAM_CSn  = 1'b0              ;
            DRAM_WEn  = 4'hf              ;
            DRAM_RASn = 1'b1              ;
            DRAM_CASn = 1'b1              ;
            DRAM_A    = ARADDR_buf[22:12] ;
            DRAM_D    = 32'b0             ;
        end
        PRE_WRITE_ROW_ACCESS : begin
            DRAM_CSn  = 1'b0    ;
            DRAM_WEn  = 4'b0    ;
            DRAM_RASn = 1'b0    ;
            DRAM_CASn = 1'b1    ;
            DRAM_A    = ROW_now ;
            DRAM_D    = 32'b0   ;
        end
        PRE_WRITE_WAIT_TRP : begin
            DRAM_CSn  = 1'b0    ;
            DRAM_WEn  = 4'hf    ;
            DRAM_RASn = 1'b1    ;
            DRAM_CASn = 1'b1    ;
            DRAM_A    = ROW_now ;
            DRAM_D    = 32'b0   ;
        end
        ACT_WRITE_ROW_ACCESS : begin
            DRAM_CSn  = 1'b0              ;
            DRAM_WEn  = 4'hf              ;
            DRAM_RASn = 1'b0              ;
            DRAM_CASn = 1'b1              ;
            DRAM_A    = AWADDR_buf[22:12] ;
            DRAM_D    = 32'b0             ;
        end
        ACT_WRITE_WAIT_TR2C : begin
            DRAM_CSn  = 1'b0              ;
            DRAM_WEn  = 4'hf              ;
            DRAM_RASn = 1'b1              ;
            DRAM_CASn = 1'b1              ;
            DRAM_A    = AWADDR_buf[22:12] ;
            DRAM_D    = 32'b0             ;  
        end
    endcase
end

endmodule