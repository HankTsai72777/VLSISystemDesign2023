`define OKAY 2'b00
`define EXOKAY 2'b01
`define SLAVER 2'b10
`define DECERR 2'b11

module ROM_wrapper (
  input CK,
  input arst,
  //READ ADDRESS0
  input [7:0]  ARID_S0,
  input [31:0] ARADDR_S0,
  input [3:0]  ARLEN_S0,
  input [2:0]  ARSIZE_S0,
  input [1:0]  ARBURST_S0,
  input        ARVALID_S0,
  output logic ARREADY_S0,
	//READ DATA0
  output logic [7:0] RID_S0,
  output logic [31:0] RDATA_S0,
  output logic [1:0] RRESP_S0,
  output logic RLAST_S0,
  output logic RVALID_S0,
  input        RREADY_S0,
  input [31:0] ROM_out,
  output logic ROM_read,
  output logic ROM_enable,
  output logic [11:0] ROM_address
);
logic [11:0] add_save;
logic [2:0] c_s,ns;
logic rst;
logic ARVALID_S0_s;
logic [7:0]ARID_s;
logic [3:0] B_counter,ARLEN_S0_s;
logic [31:0] RDATA_S0_s;
logic AR_check;
assign rst = ~arst;
assign ROM_address = add_save;
assign ROM_read = (ARVALID_S0_s)?1'b1:1'b0;
assign ROM_enable = 1'd1;

assign RLAST_S0 = (ARLEN_S0_s < B_counter)?1'b1:1'b0;
assign RDATA_S0 = (AR_check)?ROM_out:RDATA_S0_s;
always @(posedge CK)begin
  if(rst)begin
      c_s <= 3'b0;
      add_save <= 12'b0;
      RDATA_S0_s <= 32'b0;
      ARVALID_S0_s <= 1'b0;
      ARID_s <= 8'b0;
      B_counter <= 4'b0;
      ARLEN_S0_s <= 4'b0;
      AR_check <= 1'b0;
  end
  else begin
      c_s <= ns;
      add_save <= (c_s == 3'b000)?(ARADDR_S0[13:2]):(ns == 3'b010)?(add_save + 12'b1):add_save;
      RDATA_S0_s <= (AR_check)?ROM_out:RDATA_S0_s;
      ARVALID_S0_s <= (c_s == 3'b0)?ARVALID_S0:ARVALID_S0_s;
      ARID_s <= (ARVALID_S0)?ARID_S0:ARID_s;
      B_counter <= (c_s == 3'b000)?4'b1:((RVALID_S0 && RREADY_S0)?(B_counter +4'b1):B_counter);
      ARLEN_S0_s <= (c_s == 3'b000)?ARLEN_S0:ARLEN_S0_s;
      AR_check <= (c_s == 3'b100)?1'b1:(RVALID_S0 && RREADY_S0 && ~RLAST_S0)?1'b1:1'b0;//(c_s == 3'b011)?1'b1:1'b0;
  end
end

always @(*)begin
  case(c_s)
      3'b000:ns = (ARVALID_S0)?3'b100:3'b000;
      3'b100:ns = 3'b010;
      3'b010:ns = (RREADY_S0)?((RLAST_S0)?3'b000:3'b010):3'b010;
      3'b011:ns = 3'b010;//READ_burst
      default:ns = 3'b000;
  endcase
end

always @(*)begin
  case(c_s)
      3'b000:begin
          ARREADY_S0 = 1'b1;//(ARVALID_S0)?1'b1:1'b0;
          RID_S0 = 8'b0;
          RRESP_S0 = 2'b0;
          RVALID_S0 = 1'b0;
      end
      3'b100:begin
          ARREADY_S0 = 1'b0;
          RID_S0 = ARID_s;
          RRESP_S0 = 2'b0;
          RVALID_S0 = 1'b0;
      end
      3'b010:begin
          ARREADY_S0 = 1'b0;
          RID_S0 = ARID_s;
          RRESP_S0 = 2'b0;
          RVALID_S0 = 1'b1;
      end
      3'b011:begin
          ARREADY_S0 = 1'b0;
          RID_S0 = ARID_s;
          RRESP_S0 = 2'b00;
          RVALID_S0 = 1'b0;
      end

      default:begin
          ARREADY_S0 = 1'b0;
          RID_S0 = 8'b0;
          RRESP_S0 = 2'b0;
          RVALID_S0 = 1'b0;
      end
  endcase
end

endmodule
