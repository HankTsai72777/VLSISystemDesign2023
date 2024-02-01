`define OKAY 2'b00
`define EXOKAY 2'b01
`define SLAVER 2'b10
`define DECERR 2'b11

module SRAM_wrapper (
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
  input RREADY_S0
);
logic CS,OE;
logic [3:0] WEB;
logic [13:0] A,add_save;
logic [31:0] DI,DO;
logic [2:0] c_s,ns;
logic rst;
logic ARVALID_S0_s;
logic [7:0]AWID_s,ARID_s;
logic [3:0] B_counter,ARLEN_S0_s;
logic [31:0] RDATA_S0_s;
logic AR_check;

logic d_rst;
always_ff @(posedge CK) begin
  if (rst) d_rst <= 1'b1;
  else d_rst <= 1'b0;
end

assign rst = ~arst;
assign A = (c_s == 3'b00)?((AWVALID_S0)?AWADDR_S0[15:2]:(ARVALID_S0)?ARADDR_S0[15:2]:add_save):add_save;
assign OE = (ARVALID_S0 || ARVALID_S0_s)?1'b1:1'b0;
assign CS = 1'd1;
assign DI = WDATA_S0;//do in stage2
assign WEB = WSTRB_S0;//do in stage 2

assign RLAST_S0 = (ARLEN_S0_s < B_counter)?1'b1:1'b0;
assign RDATA_S0 = (AR_check)?DO:RDATA_S0_s;
always @(posedge CK or posedge rst)begin
  if(rst)begin
      c_s <= 3'b0;
      add_save <= 14'b0;
      RDATA_S0_s <= 32'b0;
      ARVALID_S0_s <= 1'b0;
      ARID_s <= 8'b0;
      AWID_s <= 8'b0;
      B_counter <= 4'b0;
      ARLEN_S0_s <= 4'b0;
      AR_check <= 1'b0;
  end
  else if(d_rst)begin
      c_s <= 3'b0;
      add_save <= 14'b0;
      RDATA_S0_s <= 32'b0;
      ARVALID_S0_s <= 1'b0;
      ARID_s <= 8'b0;
      AWID_s <= 8'b0;
      B_counter <= 4'b0;
      ARLEN_S0_s <= 4'b0;
      AR_check <= 1'b0;
  end
  else begin
      c_s <= ns;
      add_save <= (c_s == 3'b000)?((AWVALID_S0)?AWADDR_S0[15:2]:(ARVALID_S0)?(ARADDR_S0[15:2]+14'b1):add_save):
        (ns == 3'b010 || ns == 3'b101)?(add_save + 14'b1):add_save;
      RDATA_S0_s <= (AR_check)?DO:RDATA_S0_s;
      ARVALID_S0_s <= (c_s == 3'b0)?ARVALID_S0:ARVALID_S0_s;
      ARID_s <= (ARVALID_S0)?ARID_S0:ARID_s;
      AWID_s <= (AWVALID_S0)?AWID_S0:AWID_s;
      B_counter <= (c_s == 3'b000)?4'b1:((RVALID_S0 && RREADY_S0)?(B_counter +4'b1):B_counter);
      ARLEN_S0_s <= (c_s == 3'b000)?ARLEN_S0:ARLEN_S0_s;
      AR_check <= (ARVALID_S0 && ARREADY_S0)?1'b1:(RVALID_S0 && RREADY_S0 && ~RLAST_S0)?1'b1:1'b0;
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

  SRAM i_SRAM (
    .A0   (A[0]  ),
    .A1   (A[1]  ),
    .A2   (A[2]  ),
    .A3   (A[3]  ),
    .A4   (A[4]  ),
    .A5   (A[5]  ),
    .A6   (A[6]  ),
    .A7   (A[7]  ),
    .A8   (A[8]  ),
    .A9   (A[9]  ),
    .A10  (A[10] ),
    .A11  (A[11] ),
    .A12  (A[12] ),
    .A13  (A[13] ),
    .DO0  (DO[0] ),
    .DO1  (DO[1] ),
    .DO2  (DO[2] ),
    .DO3  (DO[3] ),
    .DO4  (DO[4] ),
    .DO5  (DO[5] ),
    .DO6  (DO[6] ),
    .DO7  (DO[7] ),
    .DO8  (DO[8] ),
    .DO9  (DO[9] ),
    .DO10 (DO[10]),
    .DO11 (DO[11]),
    .DO12 (DO[12]),
    .DO13 (DO[13]),
    .DO14 (DO[14]),
    .DO15 (DO[15]),
    .DO16 (DO[16]),
    .DO17 (DO[17]),
    .DO18 (DO[18]),
    .DO19 (DO[19]),
    .DO20 (DO[20]),
    .DO21 (DO[21]),
    .DO22 (DO[22]),
    .DO23 (DO[23]),
    .DO24 (DO[24]),
    .DO25 (DO[25]),
    .DO26 (DO[26]),
    .DO27 (DO[27]),
    .DO28 (DO[28]),
    .DO29 (DO[29]),
    .DO30 (DO[30]),
    .DO31 (DO[31]),
    .DI0  (DI[0] ),
    .DI1  (DI[1] ),
    .DI2  (DI[2] ),
    .DI3  (DI[3] ),
    .DI4  (DI[4] ),
    .DI5  (DI[5] ),
    .DI6  (DI[6] ),
    .DI7  (DI[7] ),
    .DI8  (DI[8] ),
    .DI9  (DI[9] ),
    .DI10 (DI[10]),
    .DI11 (DI[11]),
    .DI12 (DI[12]),
    .DI13 (DI[13]),
    .DI14 (DI[14]),
    .DI15 (DI[15]),
    .DI16 (DI[16]),
    .DI17 (DI[17]),
    .DI18 (DI[18]),
    .DI19 (DI[19]),
    .DI20 (DI[20]),
    .DI21 (DI[21]),
    .DI22 (DI[22]),
    .DI23 (DI[23]),
    .DI24 (DI[24]),
    .DI25 (DI[25]),
    .DI26 (DI[26]),
    .DI27 (DI[27]),
    .DI28 (DI[28]),
    .DI29 (DI[29]),
    .DI30 (DI[30]),
    .DI31 (DI[31]),
    .CK   (CK    ),
    .WEB0 (WEB[0]),
    .WEB1 (WEB[1]),
    .WEB2 (WEB[2]),
    .WEB3 (WEB[3]),
    .OE   (OE    ),
    .CS   (CS    )
  );

endmodule
