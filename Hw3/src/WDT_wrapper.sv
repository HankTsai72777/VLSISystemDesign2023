`include "WDT.sv"

module WDT_wrapper (
  input CK,input arst,
  input clk2,input rst2,
  //WRITE ADDRESS0
  input [7:0] AWID_S0,
  input [31:0] AWADDR_S0,
  input [3:0] AWLEN_S0,
  input [2:0] AWSIZE_S0,
  input [1:0] AWBURST_S0,
  input AWVALID_S0,
  output logic AWREADY_S0,
	//WRITE DATA0
  input [31:0] WDATA_S0,
  input [3:0] WSTRB_S0,
  input WLAST_S0,
  input WVALID_S0,
  output logic WREADY_S0,
	//WRITE RESPONSE0
  output logic [7:0] BID_S0,
  output logic [1:0] BRESP_S0,
  output logic BVALID_S0,
  input BREADY_S0,
  //READ ADDRESS0
  input [7:0] ARID_S0,
  input [31:0] ARADDR_S0,
  input [3:0] ARLEN_S0,
  input [2:0] ARSIZE_S0,
  input [1:0] ARBURST_S0,
  input ARVALID_S0,
  output logic ARREADY_S0,
	//READ DATA0
  output logic [7:0] RID_S0,
  output logic [31:0] RDATA_S0,
  output logic [1:0] RRESP_S0,
  output logic RLAST_S0,
  output logic RVALID_S0,
  input RREADY_S0,
  output logic WTO
);
logic [5:0] S_addr,add_save;
//logic [31:0] S_out;
logic WD_en,WD_live;
logic [2:0] c_s,ns;
logic rst;
logic ARVALID_S0_s;
logic [7:0]AWID_s,ARID_s;
logic [3:0] B_counter,ARLEN_S0_s;
logic [31:0] WD_count_reg;
logic AR_check;
logic WDT_irupt,WDLIVE_s;


assign rst = ~arst;
assign S_addr = (c_s == 3'b00)?((AWVALID_S0)?AWADDR_S0[7:2]:
    (ARVALID_S0)?ARADDR_S0[7:2]:add_save):add_save;
assign WD_live = (AWADDR_S0 == 32'h1001_0200 && WDATA_S0 != 32'b0);
assign RLAST_S0 = (ARLEN_S0_s < B_counter)?1'b1:1'b0;
assign RDATA_S0 = 32'b0;//(AR_check)?S_out:RDATA_S0_s;
always @(posedge CK)begin
  if(rst)begin
      c_s <= 3'b0;
      add_save <= 6'b0;
      WD_count_reg <= 32'b0;
      ARVALID_S0_s <= 1'b0;
      ARID_s <= 8'b0;
      AWID_s <= 8'b0;
      B_counter <= 4'b0;
      ARLEN_S0_s <= 4'b0;
      AR_check <= 1'b0;
      WD_en <= 1'b0;
  end
  else begin
      c_s <= ns;
      add_save <= (c_s == 3'b000)?
          ((AWVALID_S0)?AWADDR_S0[7:2]:(ARVALID_S0)?(ARADDR_S0[7:2]+6'b1):add_save):
          (ns == 3'b010 || ns == 3'b101)?(add_save + 6'b1):add_save;
      WD_count_reg <= (AWADDR_S0 == 32'h1001_0300 && WVALID_S0)?
          WDATA_S0:WD_count_reg;
      ARVALID_S0_s <= (c_s == 3'b0)?ARVALID_S0:ARVALID_S0_s;
      ARID_s <= (ARVALID_S0)?ARID_S0:ARID_s;
      AWID_s <= (AWVALID_S0)?AWID_S0:AWID_s;
      B_counter <= (c_s == 3'b000)?4'b1:((RVALID_S0 && RREADY_S0)?(B_counter +4'b1):B_counter);
      ARLEN_S0_s <= (c_s == 3'b000)?ARLEN_S0:ARLEN_S0_s;
      AR_check <= (ARVALID_S0 && ARREADY_S0)?1'b1:
          (RVALID_S0 && RREADY_S0 && ~RLAST_S0)?1'b1:1'b0;
      WD_en <= (AWADDR_S0 == 32'h1001_0100 && WDATA_S0 != 32'b0 && WVALID_S0)?1'b1:WD_en;

  end
end

always @(*)begin
    if(WDT_irupt)
        WTO = 1'b1;
    else
        WTO = 1'b0;
end
always @(*)begin
  case(c_s)
      3'b000:ns = (ARVALID_S0)?3'b010:(AWVALID_S0)?3'b100:3'b000;
      3'b010:ns = (RREADY_S0)?((RLAST_S0)?3'b000:3'b010):3'b010;
      3'b011:ns = 3'b010;//READ_burst
      3'b100:ns = (WVALID_S0)?((WLAST_S0)?3'b110:3'b101):3'b100;
      3'b101:ns = 3'b100;//WRITE_burst
      3'b110:ns = (BREADY_S0)?3'b000:3'b110;
      default:ns = 3'b000;
  endcase
end

always @(*)begin
  case(c_s)
      3'b000:begin
          AWREADY_S0 =1'b1;//(AWVALID_S0)?1'b1:1'b0;
          WREADY_S0 = 1'b0;
          BID_S0 = 8'b0;
          BRESP_S0 =  2'b0;
          BVALID_S0 = 1'b0;
          ARREADY_S0 = 1'b1;//(ARVALID_S0)?1'b1:1'b0;
          RID_S0 = 8'b0;
          RRESP_S0 = 2'b0;
          RVALID_S0 = 1'b0;
      end
      3'b010:begin
          AWREADY_S0 =1'b0;
          WREADY_S0 = 1'b0;
          BID_S0 = 8'b0;
          BRESP_S0 =  2'b0;
          BVALID_S0 = 1'b0;
          ARREADY_S0 = 1'b0;
          RID_S0 = ARID_s;
          RRESP_S0 = 2'b0;
          RVALID_S0 = 1'b1;
      end
      3'b011:begin
          AWREADY_S0 = 1'b0;
          WREADY_S0 = 1'b0;
          BID_S0 = 8'b0;
          BRESP_S0 =  2'b0;
          BVALID_S0 = 1'b0;
          ARREADY_S0 = 1'b0;
          RID_S0 = ARID_s;
          RRESP_S0 = 2'b00;
          RVALID_S0 = 1'b0;
      end
      3'b100:begin
          AWREADY_S0 = 1'b0;
          WREADY_S0 = 1'b1;
          BID_S0 = AWID_s;
          BRESP_S0 =  2'b0;
          BVALID_S0 = 1'b0;
          ARREADY_S0 = 1'b0;
          RID_S0 = 8'b0;
          RRESP_S0 = 2'b0;
          RVALID_S0 = 1'b0;
      end
      3'b101:begin
          AWREADY_S0 = 1'b0;
          WREADY_S0 = 1'b0;
          BID_S0 = AWID_s;
          BRESP_S0 =  2'b0;
          BVALID_S0 = 1'b0;
          ARREADY_S0 = 1'b0;
          RID_S0 = 8'b0;
          RRESP_S0 = 2'b0;
          RVALID_S0 = 1'b0;
      end
      3'b110:begin
          AWREADY_S0 = 1'b0;
          WREADY_S0 = 1'b0;
          BID_S0 = AWID_s;
          BRESP_S0 =  2'b0;
          BVALID_S0 = 1'b1;
          ARREADY_S0 = 1'b0;
          RID_S0 = 8'b0;
          RRESP_S0 = 2'b0;
          RVALID_S0 = 1'b0;
      end
      default:begin
          AWREADY_S0 = 1'b0;
          WREADY_S0 = 1'b0;
          BID_S0 = 8'b0;
          BRESP_S0 =  2'b0;
          BVALID_S0 = 1'b0;
          ARREADY_S0 = 1'b0;
          RID_S0 = 8'b0;
          RRESP_S0 = 2'b0;
          RVALID_S0 = 1'b0;
      end
  endcase
end
////////////////WDT
always @(posedge CK)begin
    if (rst)
        WDLIVE_s <= 1'b0;
    else
        WDLIVE_s <= (WDT_irupt)?1'b1:WD_live;
end


WDT WD0(
  .clk(CK),
  .rst(rst),
  .clk2(clk2),
  .rst2(rst2),
  .WDEN(WD_en),
  .WDLIVE(WDLIVE_s),
  .WTOCNT(WD_count_reg),
  .WTO(WDT_irupt)
);  
endmodule
