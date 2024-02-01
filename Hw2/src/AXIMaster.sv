`include "../include/AXI_define.svh"
//READ state
`define state_IDLE_r    2'd0
`define state_AR        2'd1
`define state_R         2'd2
//Write state
`define state_IDLE_w    3'd0
`define state_AW        3'd1
`define state_W         3'd2
`define state_B         3'd3

module AXIMaster (
    input                               clk, rst,
    //CPU
    input  [31:0]                       addr,
    input                               read_en,
    input  [3:0]                        write_en,
    input  [31:0]                       data_write,
    output logic [31:0]                 data_read,
    output logic                        stall,
    //AR
    output logic [`AXI_ID_BITS-1:0]     ARID,
    output logic [`AXI_ADDR_BITS-1:0]   ARADDR,
    output logic [`AXI_LEN_BITS-1:0]    ARLEN,
    output logic [`AXI_SIZE_BITS-1:0]   ARSIZE,
    output logic [1:0]                  ARBURST,
    output logic                        ARVALID,
    input                               ARREADY,
    //R
    input  [`AXI_ID_BITS-1:0]           RID,
    input  [`AXI_DATA_BITS-1:0]         RDATA,        
    input  [1:0]                        RRESP,              
    input                               RLAST,
    input                               RVALID,
    output logic                        RREADY,
    //AW
    output logic [`AXI_ID_BITS-1:0]     AWID,
    output logic [`AXI_ADDR_BITS-1:0]   AWADDR,
    output logic [`AXI_LEN_BITS-1:0]    AWLEN,
    output logic [`AXI_SIZE_BITS-1:0]   AWSIZE,
    output logic [1:0]                  AWBURST,
    output logic                        AWVALID,
    input                               AWREADY,
    //W
    output logic  [`AXI_DATA_BITS-1:0]  WDATA,   
    output logic  [`AXI_STRB_BITS-1:0]  WSTRB,   
    output logic                        WLAST,
    output logic                        WVALID,
    input                               WREADY,
    //B
    input  [`AXI_ID_BITS-1:0]           BID,
    input  [1:0]                        BRESP,
    input                               BVALID,
    output logic                        BREADY
);
/////////////////////////////////////////////////////////////////
//READ
logic [`AXI_ID_BITS-1:0]   ARID_reg;
logic [`AXI_ADDR_BITS-1:0] ARADDR_reg;
logic [`AXI_LEN_BITS-1:0]  ARLEN_reg;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_reg;
logic [1:0]                ARBURST_reg;
logic                      ARVALID_reg;
logic                      stall_read;
//read state
logic [1:0] cs_r, ns_r;
always_ff @(posedge clk or posedge rst) begin
    if (rst)    cs_r <= `state_IDLE_r;
    else    cs_r <= ns_r;
end
//FSM
always_comb begin
    case (cs_r)
        `state_IDLE_r : ns_r = (read_en)? ((ARREADY)? `state_R:`state_AR) : `state_IDLE_r;
        `state_AR     : ns_r = (ARREADY)? `state_R : `state_AR;
        `state_R      : ns_r = (RVALID && RLAST)? `state_IDLE_r : `state_R;
        default       : ns_r = 2'd3;   //default
    endcase
end
//state output
always_comb begin
    case (cs_r)
        `state_IDLE_r : begin
            ARID        = 4'b0;
            ARADDR      = addr;
            ARLEN       = 4'b0;
            ARSIZE      = 3'b010;   //byte
            ARBURST     = 2'b01;    //all INCR
            ARVALID     = read_en;
            RREADY      = 1'b0;
            data_read   = 32'b0;
            stall_read  = read_en;  //read, start stall
        end
        `state_AR : begin
            ARID        = ARID_reg;
            ARADDR      = ARADDR_reg;
            ARLEN       = ARLEN_reg;
            ARSIZE      = ARSIZE_reg;
            ARBURST     = ARBURST_reg;
            ARVALID     = ARVALID_reg;
            RREADY      = 1'b0;
            data_read   = 32'b0;
            stall_read  = 1'b1;
        end
        `state_R : begin
            ARID        = 4'b0;
            ARADDR      = 32'b0;
            ARLEN       = 4'b0;
            ARSIZE      = 3'b0;
            ARBURST     = 2'b0;
            ARVALID     = 1'b0;
            RREADY      = 1'b1;
            data_read   = (RVALID && RLAST && (RRESP != `AXI_RESP_DECERR))? RDATA:32'b0;
            stall_read  = (RVALID && RLAST && (RRESP != `AXI_RESP_DECERR))? 1'b0:1'b1;
        end
        default : begin
            ARID        = 4'b0;
            ARADDR      = 32'b0;
            ARLEN       = 4'b0;
            ARSIZE      = 3'b0;
            ARBURST     = 2'b0;
            ARVALID     = 1'b0;
            RREADY      = 1'b0;
            data_read   = 32'b0;
            stall_read  = 1'b0;
        end
    endcase
end
//reg, keep signal
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        ARID_reg    <= 4'b0;
        ARADDR_reg  <= 32'b0;
        ARLEN_reg   <= 4'b0;
        ARSIZE_reg  <= 3'b0;
        ARBURST_reg <= 2'b0;
        ARVALID_reg <= 1'b0;
    end
    else begin
        case (cs_r)
            `state_IDLE_r : begin  
                ARID_reg    <= ARID;
                ARADDR_reg  <= ARADDR;
                ARLEN_reg   <= ARLEN;
                ARSIZE_reg  <= ARSIZE;
                ARBURST_reg <= ARBURST;
                ARVALID_reg <= ARVALID;
            end
            `state_AR : begin //keep
                ARID_reg    <= ARID_reg   ;
                ARADDR_reg  <= ARADDR_reg ;
                ARLEN_reg   <= ARLEN_reg  ;
                ARSIZE_reg  <= ARSIZE_reg ;
                ARBURST_reg <= ARBURST_reg;
                ARVALID_reg <= ARVALID_reg;
            end
            `state_R : begin
                if (RVALID) begin   //read end
                    ARID_reg    <= 4'b0;
                    ARADDR_reg  <= 32'b0;
                    ARLEN_reg   <= 4'b0;
                    ARSIZE_reg  <= 3'b0;
                    ARBURST_reg <= 2'b0;
                    ARVALID_reg <= 1'b0;
                end
                else begin //keep
                    ARID_reg    <= ARID_reg   ;
                    ARADDR_reg  <= ARADDR_reg ;
                    ARLEN_reg   <= ARLEN_reg  ;
                    ARSIZE_reg  <= ARSIZE_reg ;
                    ARBURST_reg <= ARBURST_reg;
                    ARVALID_reg <= ARVALID_reg;
                end
            end
            default : begin     //default
                ARID_reg    <= 4'b0;
                ARADDR_reg  <= 32'b0;
                ARLEN_reg   <= 4'b0;
                ARSIZE_reg  <= 3'b0;
                ARBURST_reg <= 2'b0;
                ARVALID_reg <= 1'b0;
            end
        endcase
    end
end
////////////////////////////////////////////////////////////////
//WRITE
logic [`AXI_ID_BITS-1:0]   AWID_reg;
logic [`AXI_ADDR_BITS-1:0] AWADDR_reg;
logic [`AXI_LEN_BITS-1:0]  AWLEN_reg;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_reg;
logic [1:0]                AWBURST_reg;
logic                      AWVALID_reg;
logic [`AXI_DATA_BITS-1:0] WDATA_reg;
logic [`AXI_STRB_BITS-1:0] WSTRB_reg;
logic                      WLAST_reg;
logic                      WVALID_reg;
logic                      stall_write;
//write state
logic [2:0] cs_w, ns_w;
always_ff @(posedge clk or posedge rst) begin
    if (rst)    cs_w <= `state_IDLE_w;
    else    cs_w <= ns_w;
end
//FSM
always_comb begin
    case (cs_w)
        `state_IDLE_w : ns_w = (write_en!=4'b1111)? ((AWREADY)? `state_W:`state_AW) : `state_IDLE_w;
        `state_AW     : ns_w = (AWREADY&&WREADY)? `state_B : ((AWREADY)? `state_W:`state_AW);
        `state_W      : ns_w = (WREADY)? `state_B : `state_W;
        `state_B      : ns_w = (BVALID)? `state_IDLE_w : `state_B;
        default       : ns_w = 3'b111;      //default
    endcase
end
//state output
always_comb begin
    case (cs_w)
        `state_IDLE_w : begin
            AWID        = 4'b0;
            AWADDR      = addr;     //addr
            AWLEN       = 4'b0;
            AWSIZE      = 3'b010;   //4 bytes
            AWBURST     = 2'b01;    //INCR
            AWVALID     = (write_en == 4'b1111)? 1'b0:1'b1;
            WDATA       = 32'd0;
            WSTRB       = 4'd0;
            WLAST       = 1'b0;
            WVALID      = 1'b0;
            BREADY      = 1'b0;
            stall_write = (write_en != 4'b1111)? 1'b1:1'b0;
        end
        `state_AW : begin
            AWID        = AWID_reg;
            AWADDR      = AWADDR_reg;
            AWLEN       = AWLEN_reg;
            AWSIZE      = AWSIZE_reg;
            AWBURST     = AWBURST_reg;
            AWVALID     = AWVALID_reg;
            WDATA       = (AWVALID && AWREADY)? data_write : 32'd0;
            WSTRB       = (AWVALID && AWREADY)? ~write_en : 4'd0;
            WLAST       = (AWVALID && AWREADY)? 1'b1 : 1'b0;
            WVALID      = (AWVALID && AWREADY)? 1'b1 : 1'b0;
            BREADY      = 1'b0;
            stall_write = 1'b1;
        end
        `state_W : begin
            AWID        = 4'b0;
            AWADDR      = 32'b0;
            AWLEN       = 4'b0;
            AWSIZE      = 3'b0;
            AWBURST     = 2'b0;
            AWVALID     = 1'b0;
            WDATA       = WDATA_reg;
            WSTRB       = WSTRB_reg;
            WLAST       = WLAST_reg;
            WVALID      = WVALID_reg;
            BREADY      = 1'b0;
            stall_write = 1'b1;
        end
        `state_B : begin
            AWID        = 4'b0;
            AWADDR      = 32'b0;
            AWLEN       = 4'b0;
            AWSIZE      = 3'b0;
            AWBURST     = 2'b0;
            AWVALID     = 1'b0;
            WDATA       = 32'b0;
            WSTRB       = 4'b0;
            WLAST       = 1'b0;
            WVALID      = 1'b0;
            BREADY      = 1'b1;
            stall_write = (BVALID && (BRESP != `AXI_RESP_DECERR))? 1'b0 : 1'b1;
        end
        default : begin
            AWID        = 4'b0;
            AWADDR      = 32'b0;
            AWLEN       = 4'b0;
            AWSIZE      = 3'b0;
            AWBURST     = 2'b0;
            AWVALID     = 1'b0;
            WDATA       = 32'b0;
            WSTRB       = 4'b0;
            WLAST       = 1'b0;
            WVALID      = 1'b0;
            BREADY      = 1'b0;
            stall_write = 1'b0;
        end
    endcase
end
//reg, keep signal
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        AWID_reg        <= 4'b0;
        AWADDR_reg      <= 32'b0;
        AWLEN_reg       <= 4'b0;
        AWSIZE_reg      <= 3'b0;
        AWBURST_reg     <= 2'b0;
        AWVALID_reg     <= 1'b0;
        WDATA_reg       <= 32'b0;
        WSTRB_reg       <= 4'b0;
        WLAST_reg       <= 1'b0;
        WVALID_reg      <= 1'b0;
    end
    else begin
        case (cs_w)
            `state_IDLE_w : begin   //start write
                AWID_reg        <= AWID;
                AWADDR_reg      <= AWADDR;
                AWLEN_reg       <= AWLEN;
                AWSIZE_reg      <= AWSIZE;
                AWBURST_reg     <= AWBURST;
                AWVALID_reg     <= AWVALID;
                WDATA_reg       <= WDATA;
                WSTRB_reg       <= WSTRB;
                WLAST_reg       <= WLAST;
                WVALID_reg      <= WVALID;
            end
            `state_AW : begin   //AW keep
                AWID_reg        <= AWID_reg   ;
                AWADDR_reg      <= AWADDR_reg ;
                AWLEN_reg       <= AWLEN_reg  ;
                AWSIZE_reg      <= AWSIZE_reg ;
                AWBURST_reg     <= AWBURST_reg;
                AWVALID_reg     <= AWVALID_reg;
                WDATA_reg       <= WDATA;
                WSTRB_reg       <= WSTRB;
                WLAST_reg       <= WLAST;
                WVALID_reg      <= WVALID;
            end
            `state_W : begin    //keep, wait WREADY
                AWID_reg        <= AWID_reg   ;
                AWADDR_reg      <= AWADDR_reg ;
                AWLEN_reg       <= AWLEN_reg  ;
                AWSIZE_reg      <= AWSIZE_reg ;
                AWBURST_reg     <= AWBURST_reg;
                AWVALID_reg     <= AWVALID_reg;
                WDATA_reg       <= WDATA_reg  ;
                WSTRB_reg       <= WSTRB_reg  ;
                WLAST_reg       <= WLAST_reg  ;
                WVALID_reg      <= WVALID_reg ;
            end
            `state_B : begin    //end, wait BVALID
                AWID_reg        <= 4'b0;
                AWADDR_reg      <= 32'b0;
                AWLEN_reg       <= 4'b0;
                AWSIZE_reg      <= 3'b0;
                AWBURST_reg     <= 2'b0;
                AWVALID_reg     <= 1'b0;
                WDATA_reg       <= 32'b0;
                WSTRB_reg       <= 4'b0;
                WLAST_reg       <= 1'b0;
                WVALID_reg      <= 1'b0;
            end
            default : begin
                AWID_reg        <= 4'b0;
                AWADDR_reg      <= 32'b0;
                AWLEN_reg       <= 4'b0;
                AWSIZE_reg      <= 3'b0;
                AWBURST_reg     <= 2'b0;
                AWVALID_reg     <= 1'b0;
                WDATA_reg       <= 32'b0;
                WSTRB_reg       <= 4'b0;
                WLAST_reg       <= 1'b0;
                WVALID_reg      <= 1'b0;
            end
        endcase
    end
end
assign stall = stall_read || stall_write;

endmodule