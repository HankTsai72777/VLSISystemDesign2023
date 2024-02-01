`include "sensor_ctrl.sv"

module SC_wrapper (
  input CK,input arst,
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
  input SEN_ready,
  input [31:0] SEN_out,
  output logic SEN_en,
  output logic SCTRL_irupt
);
logic [5:0] S_addr,add_save;
logic [31:0] S_out;
logic S_en,S_clear;
logic [2:0] c_s,ns;
logic rst;
logic ARVALID_S0_s;
logic [7:0]AWID_s,ARID_s;
logic [3:0] B_counter,ARLEN_S0_s;
logic [31:0] RDATA_S0_s;
logic AR_check;
assign rst = ~arst;
assign S_addr = (c_s == 3'b00)?((AWVALID_S0)?AWADDR_S0[7:2]:(ARVALID_S0)?ARADDR_S0[7:2]:add_save):add_save;
//assign OE = (ARVALID_S0 || ARVALID_S0_s)?1'b1:1'b0;
//assign S_en = 1'd1;
//assign DI = WDATA_S0;//do in stage2
//assign WEB = WSTRB_S0;//do in stage 2
assign S_clear = (AWADDR_S0 == 32'h1000_0200);
assign RLAST_S0 = (ARLEN_S0_s < B_counter)?1'b1:1'b0;
assign RDATA_S0 = (AR_check)?S_out:RDATA_S0_s;
always @(posedge CK)begin
  if(rst)begin
      c_s <= 3'b0;
      add_save <= 6'b0;
      RDATA_S0_s <= 32'b0;
      ARVALID_S0_s <= 1'b0;
      ARID_s <= 8'b0;
      AWID_s <= 8'b0;
      B_counter <= 4'b0;
      ARLEN_S0_s <= 4'b0;
      AR_check <= 1'b0;
      S_en <= 1'b0;
  end
  else begin
      c_s <= ns;
      add_save <= (c_s == 3'b000)?((AWVALID_S0)?AWADDR_S0[7:2]:(ARVALID_S0)?(ARADDR_S0[7:2]+6'b1):add_save):
        (ns == 3'b010 || ns == 3'b101)?(add_save + 6'b1):add_save;
      RDATA_S0_s <= (AR_check)?S_out:RDATA_S0_s;
      ARVALID_S0_s <= (c_s == 3'b0)?ARVALID_S0:ARVALID_S0_s;
      ARID_s <= (ARVALID_S0)?ARID_S0:ARID_s;
      AWID_s <= (AWVALID_S0)?AWID_S0:AWID_s;
      B_counter <= (c_s == 3'b000)?4'b1:((RVALID_S0 && RREADY_S0)?(B_counter +4'b1):B_counter);
      ARLEN_S0_s <= (c_s == 3'b000)?ARLEN_S0:ARLEN_S0_s;
      AR_check <= (ARVALID_S0 && ARREADY_S0)?1'b1:(RVALID_S0 && RREADY_S0 && ~RLAST_S0)?1'b1:1'b0;
      S_en <= (AWADDR_S0 == 32'h1000_0100 && WDATA_S0 != 32'b0 && WVALID_S0)?1'b1:
          (AWADDR_S0 == 32'h1000_0100 && WDATA_S0 == 32'b0 && WVALID_S0)?1'b0:S_en;
  end
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
sensor_ctrl SC0(
  .clk(CK),
  .rst(rst),
  // Core inputs
  .sctrl_en(S_en),
  .sctrl_clear(S_clear),
  .sctrl_addr(S_addr),
  // Sensor inputs
  .sensor_ready(SEN_ready),
  .sensor_out(SEN_out),
  // Core outputs
  .sctrl_interrupt(SCTRL_irupt),
  .sctrl_out(S_out),
  // Sensor outputs
  .sensor_en(SEN_en)
);  
endmodule
