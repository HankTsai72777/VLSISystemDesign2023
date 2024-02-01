`include "cpu.sv"
`include "AXIMaster.sv"

module CPU_wrapper (
    input                             clk, rst,
    //WRITE ADDRESS
    output logic [`AXI_ID_BITS-1:0]   AWID_M1,
    output logic [`AXI_ADDR_BITS-1:0] AWADDR_M1,
    output logic [`AXI_LEN_BITS-1:0]  AWLEN_M1,
    output logic [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
    output logic [1:0]                AWBURST_M1,
    output logic                      AWVALID_M1,
    input                             AWREADY_M1,
    //WRITE DATA
    output logic [`AXI_DATA_BITS-1:0] WDATA_M1,
    output logic [`AXI_STRB_BITS-1:0] WSTRB_M1,
    output logic                      WLAST_M1,
    output logic                      WVALID_M1,
    input                             WREADY_M1,
    //WRITE RESPONSE
	input [`AXI_ID_BITS-1:0]          BID_M1,
	input [1:0]                       BRESP_M1,
	input                             BVALID_M1,
	output logic                      BREADY_M1,
    //READ ADDRESS0
    output logic [`AXI_ID_BITS-1:0]   ARID_M0,
    output logic [`AXI_ADDR_BITS-1:0] ARADDR_M0,
    output logic [`AXI_LEN_BITS-1:0]  ARLEN_M0,
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
    output logic [1:0]                ARBURST_M0,
    output logic                      ARVALID_M0,
    input                             ARREADY_M0,
    //READ DATA0
    input [`AXI_ID_BITS-1:0]          RID_M0,
    input [`AXI_DATA_BITS-1:0]        RDATA_M0,
    input [1:0]                       RRESP_M0,
    input                             RLAST_M0,
    input                             RVALID_M0,
    output logic                      RREADY_M0,
    //READ ADDRESS1
    output logic [`AXI_ID_BITS-1:0]   ARID_M1,
    output logic [`AXI_ADDR_BITS-1:0] ARADDR_M1,
    output logic [`AXI_LEN_BITS-1:0]  ARLEN_M1,
    output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
    output logic [1:0]                ARBURST_M1,
    output logic                      ARVALID_M1,
    input                             ARREADY_M1,
    //READ DATA1
    input [`AXI_ID_BITS-1:0]          RID_M1,
    input [`AXI_DATA_BITS-1:0]        RDATA_M1,
    input [1:0]                       RRESP_M1,
    input                             RLAST_M1,
    input                             RVALID_M1,
    output logic                      RREADY_M1,

    input                             intr_ex,
    input                             intr_tr
);

logic        AXI_IM_stall, AXI_DM_stall;
logic [31:0] IM_out, DM_out, DM_in;
logic        IM_read, DM_read;
logic [31:0] IM_addr, DM_addr;
logic [3:0]  DM_w_en;

cpu CPU1(
    .clk            (clk),
    .rst            (rst),
    .IM_stall       (AXI_IM_stall),
    .DM_stall       (AXI_DM_stall),
    .IM_out         (IM_out),
    .DM_out         (DM_out),
    .IM_read        (IM_read),
    .IM_addr        (IM_addr),
    .DM_read        (DM_read),
    .DM_addr        (DM_addr),
    .DM_wen         (DM_w_en),
    .DM_in          (DM_in),

    .intr_ex        (intr_ex),
    .intr_tr        (intr_tr)
);

logic [`AXI_ID_BITS-1:0]   AWID_M0;
logic [`AXI_ADDR_BITS-1:0] AWADDR_M0;
logic [`AXI_LEN_BITS-1:0]  AWLEN_M0;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_M0;
logic [1:0]                AWBURST_M0;
logic                      AWVALID_M0;
logic [`AXI_DATA_BITS-1:0] WDATA_M0;
logic [`AXI_STRB_BITS-1:0] WSTRB_M0;
logic                      WLAST_M0;
logic                      WVALID_M0;
logic                      BREADY_M0;

AXIMaster axi_master0 (
    .clk        (clk),
    .rst        (rst),

    .addr       (IM_addr),
    .read_en    (IM_read),
    .write_en   (4'b1111),
    .data_write (32'b0),
    .data_read  (IM_out),
    .stall      (AXI_IM_stall),

    .ARID       (ARID_M0),
    .ARADDR     (ARADDR_M0),
    .ARLEN      (ARLEN_M0),
    .ARSIZE     (ARSIZE_M0),
    .ARBURST    (ARBURST_M0),
    .ARVALID    (ARVALID_M0),
    .ARREADY    (ARREADY_M0),

    .RID        (RID_M0),
    .RDATA      (RDATA_M0),
    .RRESP      (RRESP_M0),
    .RLAST      (RLAST_M0),
    .RVALID     (RVALID_M0),
    .RREADY     (RREADY_M0),
    
    .AWID       (AWID_M0),
    .AWADDR     (AWADDR_M0),
    .AWLEN      (AWLEN_M0),
    .AWSIZE     (AWSIZE_M0),
    .AWBURST    (AWBURST_M0),
    .AWVALID    (AWVALID_M0),
    .AWREADY    (1'b0),

    .WDATA      (WDATA_M0),
    .WSTRB      (WSTRB_M0),
    .WLAST      (WLAST_M0),
    .WVALID     (WVALID_M0),
    .WREADY     (1'b0), 

    .BID        (4'b0),
    .BRESP      (2'b0),
    .BVALID     (1'b0),
    .BREADY     (BREADY_M0)
);

AXIMaster axi_master1(
    .clk        (clk),
    .rst        (rst),

    .addr       (DM_addr),
    .read_en    (DM_read),
    .write_en   (DM_w_en),
    .data_write (DM_in),
    .data_read  (DM_out),
    .stall      (AXI_DM_stall),
    
    .ARID       (ARID_M1),
    .ARADDR     (ARADDR_M1),
    .ARLEN      (ARLEN_M1),
    .ARSIZE     (ARSIZE_M1),
    .ARBURST    (ARBURST_M1),
    .ARVALID    (ARVALID_M1),
    .ARREADY    (ARREADY_M1),
    
    .RID        (RID_M1),
    .RDATA      (RDATA_M1),
    .RRESP      (RRESP_M1),
    .RLAST      (RLAST_M1),
    .RVALID     (RVALID_M1),
    .RREADY     (RREADY_M1),

    .AWID       (AWID_M1),
    .AWADDR     (AWADDR_M1),
    .AWLEN      (AWLEN_M1),
    .AWSIZE     (AWSIZE_M1),
    .AWBURST    (AWBURST_M1),
    .AWVALID    (AWVALID_M1),
    .AWREADY    (AWREADY_M1),
    
    .WDATA      (WDATA_M1),
    .WSTRB      (WSTRB_M1),
    .WLAST      (WLAST_M1),
    .WVALID     (WVALID_M1),
    .WREADY     (WREADY_M1), 
    
    .BID        (BID_M1),
    .BRESP      (BRESP_M1),
    .BVALID     (BVALID_M1),
    .BREADY     (BREADY_M1)
);

endmodule