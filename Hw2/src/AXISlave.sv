`include "../include/AXI_define.svh"

`define state_AR  1'b0
`define state_R   1'b1
`define state_w   1'b0
`define state_B   1'b1

module AXISlave (
    input                               clk, rst,

    input  [`AXI_IDS_BITS-1:0]          ARID,
    input  [`AXI_ADDR_BITS-1:0]         ARADDR,
    input  [`AXI_LEN_BITS-1:0]          ARLEN,
    input  [`AXI_SIZE_BITS-1:0]         ARSIZE,
    input  [1:0]                        ARBURST,
    input                               ARVALID,
    output logic                        ARREADY,

    output logic [`AXI_IDS_BITS-1:0]    RID,
    output logic [`AXI_DATA_BITS-1:0]   RDATA,
    output logic [1:0]                  RRESP,
    output logic                        RLAST,
    output logic                        RVALID,
    input                               RREADY,

    input  [`AXI_IDS_BITS-1:0]          AWID,
    input  [`AXI_ADDR_BITS-1:0]         AWADDR,
    input  [`AXI_LEN_BITS-1:0]          AWLEN,
    input  [`AXI_SIZE_BITS-1:0]         AWSIZE,
    input  [1:0]                        AWBURST,
    input                               AWVALID,
    output logic                        AWREADY,

    input  [`AXI_DATA_BITS-1:0]         WDATA,
    input  [`AXI_STRB_BITS-1:0]         WSTRB,
    input                               WLAST,
    input                               WVALID,
    output logic                        WREADY,

    output logic [`AXI_IDS_BITS-1:0]    BID,
    output logic [1:0]                  BRESP,
    output logic                        BVALID,
    input                               BREADY,

    output logic [13:0]                 Addr,
    output logic                        Read_en,
    input  [`AXI_DATA_BITS-1:0]         Data_read,
    output logic [3:0]                  Write_en,
    output logic [`AXI_DATA_BITS-1:0]   Data_write
);

logic cs_global, ns_global;     //IDLE:0, RUN:1
logic [1:0]  mode, mode_reg;    //IDLE:0, READ:1, WRITE:2

logic                      read;
logic [`AXI_STRB_BITS-1:0] write;
logic [`AXI_DATA_BITS-1:0] data_w;
logic [13:0]               addr_r, addr_w;
logic                      finish_r, finish_w;
//state
always_ff @(posedge clk or negedge rst) begin
    if (!rst)   cs_global <= 1'b0;
    else    cs_global <= ns_global;
end
//FSM
always_comb begin
    case (cs_global)
        1'b0 : ns_global = (ARVALID||AWVALID)? 1'b1 : 1'b0;     //keeo IDLE or turn run
        1'b1 : ns_global = (((mode_reg==2'd1)&&~finish_r)||((mode_reg==2'd2)&&~finish_w))? 1'b1 : 1'b0;     //keep run or turn IDLE
    endcase
end
//MODE
always_comb begin
    mode = (cs_global)? mode_reg : (ARVALID? 2'd1:(AWVALID? 2'd2:2'd0));
end
//output
always_comb begin
    case (mode)
        2'd0 : begin    //IDLE
            Addr        = 14'b0;
            Read_en     = 1'b0;
            Write_en    = 4'b1111;
            Data_write  = 32'd0;
        end
        2'd1 : begin    //read
            Addr        = addr_r;
            Read_en     = read;
            Write_en    = 4'b1111;
            Data_write  = 32'd0;
        end
        2'd2 :begin     //write
            Addr        = addr_w;
            Read_en     = 1'b0;
            Write_en    = write;
            Data_write  = data_w;
        end
        default : begin //default
            Addr        = 14'd0;
            Read_en     = 1'b0;
            Write_en    = 4'b1111;
            Data_write  = 32'd0;
        end
    endcase
end
//MODE
always_ff @(posedge clk  or negedge rst) begin
    if (!rst)   mode_reg <= 2'd0;   //IDLE
    else if (~cs_global && ns_global)  mode_reg <= mode;   //turn run
    else if (cs_global && ~ns_global)  mode_reg <= 2'd0;   //turn IDLE
    else if (cs_global)     mode_reg <= mode_reg;   //still run
    else    mode_reg <= 2'd0;       //still IDLE
end
/////////////////////////////////////////////////////////////////////////////////////////////
//Read
//wait, keep signal
logic [`AXI_IDS_BITS-1:0]   ARID_reg;
logic [`AXI_ADDR_BITS-1:0]  ARADDR_reg;
logic [`AXI_LEN_BITS-1:0]   ARLEN_reg;
logic [`AXI_SIZE_BITS-1:0]  ARSIZE_reg;
logic [1:0]                 ARBURST_reg;
logic                       keep_r;
logic [`AXI_ADDR_BITS-1:0]  addr_temp_r;
//state
logic cs_r, ns_r;
always_ff @(posedge clk or negedge rst) begin
    if (!rst)   cs_r <= `state_AR;
    else    cs_r <= ns_r;
end
//FSM
always_comb begin
    case (cs_r)
        `state_AR : ns_r = ((mode==2'b1) && ARVALID)? `state_R : `state_AR;
        `state_R : ns_r = (RREADY && RLAST)? `state_AR : `state_R;
    endcase 
end
//state output
always_comb begin
    case (cs_r)
        `state_AR : begin
            ARREADY     = (mode!=2'd2)? 1'b1 : 1'b0; //ARREADY high except write mode
            addr_r      = ((mode==2'd1)&&ARVALID)? ARADDR[15:2] : 14'd0; //read && ARVALID
            read        = 1'b0;

            RID         = 8'b0;
            RDATA       = 32'b0;
            RRESP       = 2'b0;
            RLAST       = 1'b0;
            RVALID      = 1'b0;

            finish_r    = 1'b0;
            keep_r      = 1'b0;
            addr_temp_r = 32'b0;  
        end
        `state_R : begin
            ARREADY     = 1'b0;
            read        = 1'b1;

            RID         = ARID_reg;
            RDATA       = Data_read;
            RRESP       = `AXI_RESP_OKAY;
            RLAST       = (ARLEN_reg==4'b0)? 1'b1 : 1'b0;
            RVALID      = 1'b1;

            finish_r    = (RREADY&&(ARLEN_reg==4'b0))? 1'b1 : 1'b0;    //ARLEN_reg==0, read end
            keep_r      = (RREADY&&(ARLEN_reg!=4'b0))? 1'b1 : 1'b0;    //ARLEN_reg!=0, keep read
            addr_temp_r = (keep_r)? (ARADDR_reg + (32'd1 << ARSIZE_reg)) : ARADDR_reg;
            addr_r      = addr_temp_r [15:2];
        end
    endcase
end
//REG
always_ff @(posedge clk or negedge rst) begin
    if (!rst) begin
        ARID_reg     <= 8'b0;
        ARADDR_reg   <= 32'b0;
        ARLEN_reg    <= 4'b0;
        ARSIZE_reg   <= 3'b0;
        ARBURST_reg  <= 2'b0;
    end
    else if ((cs_r==`state_AR)&&(ns_r==`state_R)) begin //turn R
        ARID_reg     <= ARID;
        ARADDR_reg   <= ARADDR;
        ARLEN_reg    <= ARLEN;
        ARSIZE_reg   <= ARSIZE;
        ARBURST_reg  <= ARBURST;
    end
    else if (cs_r == `state_R) begin    //still R
        if (keep_r) begin
            ARADDR_reg   <= ARADDR_reg + (32'd1 << ARSIZE_reg);
            ARLEN_reg    <= ARLEN_reg - 4'd1;
        end
        else begin
            ARADDR_reg   <= ARADDR_reg ;
            ARLEN_reg    <= ARLEN_reg  ;
        end
        ARID_reg     <= ARID_reg;
        ARSIZE_reg   <= ARSIZE_reg;
        ARBURST_reg  <= ARBURST_reg;
    end
    else if ((cs_r==`state_R)&&(ns_r==`state_AR)) begin  //turn AR
        ARID_reg     <= 8'b0;
        ARADDR_reg   <= 32'b0;
        ARLEN_reg    <= 4'b0;
        ARSIZE_reg   <= 3'b0;
        ARBURST_reg  <= 2'b0;
    end
end
/////////////////////////////////////////////////////////////////////////////////////////////
//write
logic [`AXI_IDS_BITS-1:0]  AWID_reg;
logic [`AXI_ADDR_BITS-1:0] AWADDR_reg;
logic [`AXI_LEN_BITS-1:0]  AWLEN_reg;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_reg;
logic [1:0]                AWBURST_reg;
logic [`AXI_ADDR_BITS-1:0] addr_temp_w;
logic                      AW_finish, AW_finish_reg;
logic                      keep_w;
//state
logic cs_w, ns_w;
always_ff @(posedge clk or negedge rst) begin
    if (!rst)   cs_w <= `state_w;
    else    cs_w <= ns_w;
end
//FSM
always_comb begin
    case (cs_w)
        `state_w : ns_w = ((mode==2'd2)&&WVALID&&WLAST&&(AW_finish||AW_finish_reg))? `state_B : `state_w;
        `state_B : ns_w = (BREADY)? `state_w : `state_B;
    endcase
end
//state output
always_comb begin
    case(cs_w)
        `state_w : begin
            AW_finish   = ((mode==2'd2)&&(~AW_finish_reg)&&AWVALID)? 1'b1 : 1'b0;
            write       = ((mode==2'd2)&&WVALID&&(AW_finish||AW_finish_reg))? ~WSTRB : 4'b1111;
            addr_temp_w = ((mode==2'd2)&&WVALID&&AW_finish_reg)? AWADDR_reg+(32'd1<<AWSIZE_reg) : 14'b0;
            addr_w      = (mode==2'd2)? (AW_finish? AWADDR[15:2]:(AW_finish_reg? addr_temp_w[15:2]:14'b0)) : 14'b0;
            data_w      = ((mode==2'd2)&&WVALID&&(AW_finish||AW_finish_reg))? WDATA : 32'b0;
            keep_w      = ((mode==2'd2)&&WVALID&&(AW_finish||AW_finish_reg))? 1'b1 : 1'b0;
            finish_w    = 1'b0;

            AWREADY     = (((mode==2'd2)&&(~AW_finish_reg))||(mode==2'd0))? 1'b1 : 1'b0;
            WREADY      = ((mode==2'd2)&&(AW_finish||AW_finish_reg))? 1'b1 : 1'b0;
            BID         = 8'b0;
            BRESP       = 2'b0;
            BVALID      = 1'b0;
        end
        `state_B : begin
            write       = 4'b1111;
            addr_w      = 14'b0;
            data_w      = 32'b0;
            keep_w      = 1'b0;
            addr_temp_w = 32'b0;
            AW_finish   = 1'b0;
            finish_w    = (BREADY)? 1'b1 : 1'b0;

            AWREADY     = 1'b0;
            WREADY      = 1'b0;
            BID         = AWID_reg;
            BRESP       = `AXI_RESP_OKAY;
            BVALID      = 1'b1;
        end 
    endcase
end
//REG, keep signal
always_ff @(posedge clk or negedge rst) begin
    if (!rst) begin
        AWID_reg      <= 8'b0;
        AWADDR_reg    <= 32'b0;
        AWLEN_reg     <= 4'b0;
        AWSIZE_reg    <= 3'b0;
        AWBURST_reg   <= 2'b0;
        AW_finish_reg <= 1'b0;
    end
    else if (cs_w == `state_w) begin
        if (~AW_finish_reg&&AW_finish) begin    //AW
            AWID_reg      <= AWID;
            AWADDR_reg    <= AWADDR;
            AWLEN_reg     <= AWLEN;
            AWSIZE_reg    <= AWSIZE;
            AWBURST_reg   <= AWBURST;
            AW_finish_reg <= 1'b1;
        end
        else if (WVALID && WREADY && keep_w) begin  //W
            AWLEN_reg     <= AWLEN_reg-4'd1;
            AWADDR_reg    <= AWADDR_reg+(32'd1<<AWSIZE_reg);
            AWSIZE_reg    <= AWSIZE_reg ;
            AWBURST_reg   <= AWBURST_reg;
            AW_finish_reg <= 1'b0;
        end
        else begin
            AWID_reg      <= AWID_reg   ;
            AWADDR_reg    <= AWADDR_reg ;
            AWLEN_reg     <= AWLEN_reg  ;
            AWSIZE_reg    <= AWSIZE_reg ;
            AWBURST_reg   <= AWBURST_reg;
            AW_finish_reg <= 1'b0;
        end
    end
    else if ((cs_w==`state_B)&&(ns_w==`state_w)) begin
        AWID_reg      <= 8'b0;
        AWADDR_reg    <= 32'b0;
        AWLEN_reg     <= 4'b0;
        AWSIZE_reg    <= 3'b0;
        AWBURST_reg   <= 2'b0;
        AW_finish_reg <= 1'b0;
    end
end

endmodule
