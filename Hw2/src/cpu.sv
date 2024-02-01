`define LUI           (7'b0110111)
`define AUIPC         (7'b0010111)
`define JAL           (7'b1101111)
`define JALR          (7'b1100111)
`define BRANCH        (7'b1100011)
`define I_type        (7'b0010011)
`define STORE         (7'b0100011)
`define R_type        (7'b0110011)
`define LOAD          (7'b0000011)
`define CSR           (7'b1110011)
`define NOP           (7'b0000000)
`define alu_add       (5'd0)
`define alu_sub       (5'd1)
`define alu_sll       (5'd2)
`define alu_slt       (5'd3)
`define alu_sltu      (5'd4)
`define alu_xor       (5'd5)
`define alu_srl       (5'd6)
`define alu_sra       (5'd7)
`define alu_or        (5'd8)
`define alu_and       (5'd9)
`define alu_beq       (5'd10)
`define alu_bne       (5'd11)
`define alu_blt       (5'd12)
`define alu_bge       (5'd13)
`define alu_bltu      (5'd14)
`define alu_bgeu      (5'd15)
`define alu_j         (5'd16)
`define alu_lui       (5'd17)
`define alu_auipc     (5'd18)
`define alu_mul       (5'd19)
`define alu_mulh      (5'd20)
`define alu_mulhsu    (5'd21)
`define alu_mulhu     (5'd22)
`define alu_csr       (5'd23)
`define alu_nop       (5'd31)
`define BYTE          (3'd0)
`define HALF_WORD     (3'd1)
`define WORD          (3'd2)
`define U_BYTE        (3'd3)
`define U_HALF_WORD   (3'd4)

module cpu (
    input                       clk, 
    input                       rst,
    output logic                IM_read,
    output logic [31:0]         IM_addr,
    input        [31:0]         IM_out,
    output logic                DM_read,
    output logic [3:0]          DM_wen,
    output logic [31:0]         DM_addr,
    output logic [31:0]         DM_in,
    input        [31:0]         DM_out,
    input                       IM_stall,
    input                       DM_stall
);
//================================    define    ================================//
//IF
logic        rst_reg;
logic [31:0] F_pc, E_jb_pc, E_jb_pc_reg;
logic        E_jb, D_stall, E_jb_reg;
//ID
logic [31:0] D_pc;
logic [11:0] D_csr_rd;
logic        D_jal, D_jalr, D_mem_read, D_mem_write, D_reg_write, D_nop;
logic [1:0]  D_alu_rs1_sel, D_alu_rs2_sel;
logic [4:0]  D_alu_op;
logic [2:0]  D_data_width;
logic [4:0]  D_rd, D_rs1, D_rs2;
logic [31:0] D_rs1_data, D_rs2_data, D_rs1_data_next, D_rs2_data_next, D_imm;
//EXE
logic [31:0] E_pc;
logic [11:0] E_csr_rd;
logic        E_jal, E_jalr, E_mem_read, E_mem_write, E_reg_write, E_nop;
logic [1:0]  E_alu_rs1_sel, E_alu_rs2_sel;
logic [4:0]  E_alu_op;
logic [2:0]  E_data_width;
logic [4:0]  E_rd, E_rs1, E_rs2;
logic [31:0] E_rs1_data, E_rs2_data, E_rs1_data_next, E_rs2_data_next, E_imm;
//MEM
logic        M_mem_read, M_mem_write, M_reg_write;
logic [4:0]  M_rd;
logic [2:0]  M_data_width;
logic [31:0] M_rs2_data, M_alu_out;
//WB
logic        WB_mem_read, WB_reg_write;
logic [4:0]  WB_rd;
logic [2:0]  WB_data_width;
logic [31:0] WB_alu_out;
logic [31:0] WB_data;
logic        WB_en;
//================================    IF stage    ================================//
logic [31:0] D_inst;
//delay reset
always_ff @(posedge clk or posedge rst) begin
    if (rst) rst_reg <= 1'b1;
    else     rst_reg <= 1'b0;
end
//E_jb reg
always_ff @(posedge clk or posedge rst) begin
    if (rst)            E_jb_reg <= 1'b0;
    else if (E_jb)      E_jb_reg <= 1'b1;
    else if (IM_stall)  E_jb_reg <= E_jb_reg;
    else                E_jb_reg <= 1'b0;
end
always_ff @(posedge clk or posedge rst) begin
    if (rst)            E_jb_pc_reg <= 32'b0;
    else if (E_jb)      E_jb_pc_reg <= E_jb_pc;
    else if (IM_stall)  E_jb_pc_reg <= E_jb_pc_reg;
    else                E_jb_pc_reg <= 32'b0;
end
//IF pc
always_ff @(posedge clk or posedge rst) begin
    if (rst)                     F_pc <= 32'b0;
    else if (rst_reg)            F_pc <= 32'b0;
    else if (IM_stall||DM_stall) F_pc <= F_pc;
    else if (E_jb)               F_pc <= E_jb_pc;
    else if (E_jb_reg)           F_pc <= E_jb_pc_reg;
    else if (D_stall)            F_pc <= F_pc;
    else                         F_pc <= (F_pc + 32'd4);
end
//IF stage register
always_ff @(posedge clk or posedge rst) begin
    if (rst)                           D_pc <= 32'b0;
    else if (IM_stall||E_jb||E_jb_reg) D_pc <= 32'b0;
    else if (DM_stall||D_stall)        D_pc <= D_pc;
    else                               D_pc <= F_pc;
end
//instruction
always_ff @(posedge clk or posedge rst) begin
    if (rst)                                    D_inst <= 32'b0;
    else if (rst_reg||IM_stall||E_jb||E_jb_reg) D_inst <= 32'b0;
    else if (DM_stall||D_stall)                 D_inst <= D_inst;
    else                                        D_inst <= IM_out;
end
//IM
assign IM_addr = F_pc;
always_ff @(posedge clk or posedge rst) begin
    if (rst) IM_read <= 1'b0;
    else IM_read <= 1'b1;
end
//================================    ID stage    ================================//
logic [6:0]  D_op;
logic [2:0]  D_f3;
logic [6:0]  D_funct7;
logic [1:0]  D_f7;
logic [3:0]  D_csr_op;
logic [31:0] regfile[31:0];
//decoder
always_comb begin
    D_funct7 = D_inst[31:25];
    D_csr_rd = D_inst[31:20];
    D_rs2    = D_inst[24:20];
    D_rs1    = D_inst[19:15];
    D_f3     = D_inst[14:12];
    D_rd     = D_inst[11:7];
    D_op     = D_inst[6:0];
end
always_comb begin
    case(D_funct7)
        7'b0100000 : D_f7 = 2'd1;
        7'b0000001 : D_f7 = 2'd2;
        default : D_f7 = 2'b0;
    endcase
end
//csr
always_comb begin
    case(D_csr_rd)
        12'b110010000010 : D_csr_op = 4'd1;
        12'b110000000010 : D_csr_op = 4'd2;
        12'b110010000000 : D_csr_op = 4'd3;
        12'b110000000000 : D_csr_op = 4'd4;
        default : D_csr_op = 4'b0;
    endcase
end
//signal
assign D_jal       = (D_op==`JAL)   ? 1'b1 : 1'b0;
assign D_jalr      = (D_op==`JALR)  ? 1'b1 : 1'b0;
assign D_mem_read  = (D_op==`LOAD)  ? 1'b1 : 1'b0;
assign D_mem_write = (D_op==`STORE) ? 1'b1 : 1'b0;
assign D_reg_write = ((D_op==`STORE)||(D_op==`BRANCH)||(D_rd==5'b0))? 1'b0 : 1'b1;
always_comb begin
    if ((D_op==`AUIPC)||(D_op==`JAL)||(D_op==`JALR)) D_alu_rs1_sel = 2'd1;
    else D_alu_rs1_sel = 2'b0;
end
always_comb begin
    if ((D_op==`R_type)||(D_op==`BRANCH)) D_alu_rs2_sel = 2'b0;
    else D_alu_rs2_sel = 2'd1;
end
//alu D_op
always_comb begin
    case(D_op)
        `R_type : begin
            case(D_f7)
                2'b0 : begin
                    case(D_f3)
                        3'b000 : D_alu_op = `alu_add; 
                        3'b001 : D_alu_op = `alu_sll;
                        3'b010 : D_alu_op = `alu_slt;
                        3'b011 : D_alu_op = `alu_sltu;
                        3'b100 : D_alu_op = `alu_xor;
                        3'b101 : D_alu_op = `alu_srl;
                        3'b110 : D_alu_op = `alu_or;
                        3'b111 : D_alu_op = `alu_and;
                    endcase
                end
                2'd1 : begin
                    case(D_f3)
                        3'b000 : D_alu_op = `alu_sub;
                        default : D_alu_op = `alu_sra;  //001
                    endcase
                end
                default : begin //2'd2
                    case(D_f3)
                        3'b000 : D_alu_op = `alu_mul;
                        3'b001 : D_alu_op = `alu_mulh;
                        3'b010 : D_alu_op = `alu_mulhsu;
                        default : D_alu_op = `alu_mulhu;  //011
                    endcase
                end
            endcase
        end
        `I_type : begin
            case(D_f3)
                3'b000  : D_alu_op = `alu_add;        
                3'b001  : D_alu_op = `alu_sll;
                3'b010  : D_alu_op = `alu_slt;
                3'b011  : D_alu_op = `alu_sltu;
                3'b100  : D_alu_op = `alu_xor;
                3'b101  : begin
                    case (D_f7)
                        2'd1    : D_alu_op = `alu_sra;
                        default : D_alu_op = `alu_srl;  //00
                    endcase
                end
                3'b110  : D_alu_op = `alu_or;   
                3'b111  : D_alu_op = `alu_and;
            endcase
        end
        `CSR : D_alu_op = `alu_csr;
        `BRANCH : begin
            case(D_f3)
                3'b001  : D_alu_op = `alu_bne;
                3'b100  : D_alu_op = `alu_blt;
                3'b101  : D_alu_op = `alu_bge;
                3'b110  : D_alu_op = `alu_bltu;
                3'b111  : D_alu_op = `alu_bgeu;
                default : D_alu_op = `alu_beq;  //000
            endcase
        end
        `LUI    : D_alu_op = `alu_lui;
        `AUIPC  : D_alu_op = `alu_auipc;
        `JAL    : D_alu_op = `alu_j;
        `JALR   : D_alu_op = `alu_j;
        default : D_alu_op = `alu_add;  //nop, load, store
    endcase
end
//data width
always_comb begin
    if ((D_op==`LOAD)||(D_op==`STORE)) begin
        case(D_f3)
            3'b000 : D_data_width = `BYTE;
            3'b001 : D_data_width = `HALF_WORD;
            3'b010 : D_data_width = `WORD;
            3'b100 : D_data_width = `U_BYTE;
            3'b101 : D_data_width = `U_HALF_WORD;
            default : D_data_width = 3'b111;
        endcase
    end
    else D_data_width = 3'b111;
end
//imm
always_comb begin
    case(D_op)
        `LOAD, `I_type, `JALR : D_imm = { {20{D_inst[31]}}, D_inst[31:20] };
        `BRANCH               : D_imm = { {20{D_inst[31]}}, D_inst[7], D_inst[30:25], D_inst[11:8], 1'b0 };
        `STORE                : D_imm = { {20{D_inst[31]}}, D_inst[31:25], D_inst[11:7] };
        `LUI, `AUIPC          : D_imm = { D_inst[31:12], 12'd0 };
        `JAL                  : D_imm = { {12{D_inst[31]}}, D_inst[19:12], D_inst[20], D_inst[30:21], 1'b0 }; 
        default               : D_imm = 32'd0;  //R_type, NOP
    endcase
end
//reg file
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        for(int i=0;i<32;i++) begin
            regfile[i] <= 32'b0;
        end
    end
    else if ((WB_en == 1'b1)&&(WB_rd!=5'b0)) regfile[WB_rd] <= WB_data;
    else regfile[WB_rd] <= regfile[WB_rd];
end
assign D_rs1_data = regfile[D_rs1];
assign D_rs2_data = regfile[D_rs2];
//forwading
always_comb begin
    if ((WB_rd==D_rs1)&&(WB_en==1'b1)) D_rs1_data_next = WB_data;
    else D_rs1_data_next = D_rs1_data;
end
always_comb begin
    if ((WB_rd==D_rs2)&&(WB_en==1'b1)) D_rs2_data_next = WB_data;
    else D_rs2_data_next = D_rs2_data;
end
//D_stall
assign D_stall = ((E_mem_read==1'b1)&&((E_rd==D_rs1)||(E_rd==D_rs2)))? 1'b1 : 1'b0;
//nop
assign D_nop = (D_op==`NOP)? 1'b1 : 1'b0;
//ID state reg
always_ff @(posedge clk or posedge rst) begin
    if (rst)                E_pc <= 32'b0;
    else if (DM_stall)      E_pc <= E_pc;
    else if (D_stall||E_jb) E_pc <= 32'b0;
    else                    E_pc <= D_pc;
end
always_ff @(posedge clk or posedge rst) begin
    if (rst)                E_csr_rd <= 5'b0;
    else if (DM_stall)      E_csr_rd <= E_csr_rd;
    else if (D_stall||E_jb) E_csr_rd <= 5'b0;
    else                    E_csr_rd <= D_csr_rd;
end
always_ff @(posedge clk or posedge rst) begin
    if (rst)                E_jal <= 1'b0;
    else if (DM_stall)      E_jal <= E_jal;
    else if (D_stall||E_jb) E_jal <= 1'b0;
    else                    E_jal <= D_jal;
end
always_ff @(posedge clk or posedge rst) begin
    if (rst)                E_jalr <= 1'b0;
    else if (DM_stall)      E_jalr <= E_jalr;
    else if (D_stall||E_jb) E_jalr <= 1'b0;
    else                    E_jalr <= D_jalr;
end
always_ff @(posedge clk or posedge rst) begin
    if (rst)                E_mem_read <= 1'b0;
    else if (DM_stall)      E_mem_read <= E_mem_read;
    else if (D_stall||E_jb) E_mem_read <= 1'b0;
    else                    E_mem_read <= D_mem_read;
end
always_ff @(posedge clk or posedge rst) begin
    if (rst)                E_mem_write <= 1'b0;
    else if (DM_stall)      E_mem_write <= E_mem_write;
    else if (D_stall||E_jb) E_mem_write <= 1'b0;
    else                    E_mem_write <= D_mem_write;
end
always_ff @(posedge clk or posedge rst) begin
    if (rst)                E_reg_write <= 1'b0;
    else if (DM_stall)      E_reg_write <= E_reg_write;
    else if (D_stall||E_jb) E_reg_write <= 1'b0;
    else                    E_reg_write <= D_reg_write;
end
always_ff @(posedge clk or posedge rst) begin
    if (rst)                E_nop <= 1'b1;
    else if (DM_stall)      E_nop <= 1'b1;
    else if (D_stall||E_jb) E_nop <= 1'b1;
    else                    E_nop <= D_nop;
end
always_ff @(posedge clk or posedge rst) begin
    if (rst)                E_alu_rs1_sel <= 1'b0;
    else if (DM_stall)      E_alu_rs1_sel <= E_alu_rs1_sel;
    else if (D_stall||E_jb) E_alu_rs1_sel <= 1'b0;
    else                    E_alu_rs1_sel <= D_alu_rs1_sel;
end
always_ff @(posedge clk or posedge rst) begin
    if (rst)                E_alu_rs2_sel <= 1'b0;
    else if (DM_stall)      E_alu_rs2_sel <= E_alu_rs2_sel;
    else if (D_stall||E_jb) E_alu_rs2_sel <= 1'b0;
    else                    E_alu_rs2_sel <= D_alu_rs2_sel;
end
always_ff @(posedge clk or posedge rst) begin
    if (rst)                E_alu_op <= 5'b0;
    else if (DM_stall)      E_alu_op <= E_alu_op;
    else if (D_stall||E_jb) E_alu_op <= 5'b0;
    else                    E_alu_op <= D_alu_op;
end
always_ff @(posedge clk or posedge rst) begin
    if (rst)                E_data_width <= 3'b0;
    else if (DM_stall)      E_data_width <= E_data_width;
    else if (D_stall||E_jb) E_data_width <= 3'b0;
    else                    E_data_width <= D_data_width;
end
always_ff @(posedge clk or posedge rst) begin
    if (rst)                E_imm <= 32'b0;
    else if (DM_stall)      E_imm <= E_imm;
    else if (D_stall||E_jb) E_imm <= 32'b0;
    else                    E_imm <= D_imm;
end
always_ff @(posedge clk or posedge rst) begin
    if (rst)                E_rs1 <= 5'b0;
    else if (DM_stall)      E_rs1 <= E_rs1;
    else if (D_stall||E_jb) E_rs1 <= 5'b0;
    else                    E_rs1 <= D_rs1;
end
always_ff @(posedge clk or posedge rst) begin
    if (rst)                E_rs2 <= 5'b0;
    else if (DM_stall)      E_rs2 <= E_rs2;
    else if (D_stall||E_jb) E_rs2 <= 5'b0;
    else                    E_rs2 <= D_rs2;
end
always_ff @(posedge clk or posedge rst) begin
    if (rst)                E_rd <= 5'b0;
    else if (DM_stall)      E_rd <= E_rd;
    else if (D_stall||E_jb) E_rd <= 5'b0;
    else                    E_rd <= D_rd;
end
always_ff @(posedge clk or posedge rst) begin
    if (rst)                E_rs1_data <= 32'b0;
    else if (DM_stall)      E_rs1_data <= E_rs1_data;
    else if (D_stall||E_jb) E_rs1_data <= 32'b0;
    else                    E_rs1_data <= D_rs1_data_next;
end
always_ff @(posedge clk or posedge rst) begin
    if (rst)                E_rs2_data <= 32'b0;
    else if (DM_stall)      E_rs2_data <= E_rs2_data;
    else if (D_stall||E_jb) E_rs2_data <= 32'b0;
    else                    E_rs2_data <= D_rs2_data_next;
end
//================================    EXE stage    ================================//
logic        [31:0] E_alu_rs1_data, E_alu_rs2_data;
logic        [31:0] E_alu_out;
logic        [31:0] E_csr_data;
logic        [63:0] E_instret, E_cycle;
logic signed [32:0] mul1, mul2;
logic signed [32:0] mul_u_rs1, mul_u_rs2;
logic signed [32:0] mul_s_rs1, mul_s_rs2;
logic signed [65:0] mul_out;
logic signed [31:0] s_rs1, s_rs2;
logic        [31:0] u_rs1, u_rs2;
logic               E_branch;
logic signed [31:0] E_jb_op;
logic signed [31:0] E_jb_imm;
//forwarding
always_comb begin
    if ((M_rd==E_rs1)&&(M_reg_write==1'b1)) E_rs1_data_next = M_alu_out;
    else if ((WB_rd==E_rs1)&&(WB_en==1'b1)) E_rs1_data_next = WB_data;
    else                                    E_rs1_data_next = E_rs1_data;
end
always_comb begin
    if ((M_rd==E_rs2)&&(M_reg_write==1'b1)) E_rs2_data_next = M_alu_out;
    else if ((WB_rd==E_rs2)&&(WB_en==1'b1)) E_rs2_data_next = WB_data;
    else                                    E_rs2_data_next = E_rs2_data;
end
//csr file
always_ff @(posedge clk or posedge rst) begin
    if (rst) E_instret <= 64'b0;
    else if (E_nop) E_instret <= E_instret;
    else E_instret <= (E_instret+64'd1);
end
always_ff @(posedge clk or posedge rst) begin
    if (rst) E_cycle   <= 64'b0;
    else E_cycle   <= (E_cycle +64'd1);
end
always_comb begin
    case(E_csr_rd)
        12'hc00 : E_csr_data = E_cycle  [31:0];
        12'hc02 : E_csr_data = E_instret[31:0];
        12'hc80 : E_csr_data = E_cycle  [63:32];
        12'hc82 : E_csr_data = E_instret[63:32];
        default : E_csr_data = 32'b0;
    endcase
end
//alu input
always_comb begin
    case(E_alu_rs1_sel)
        2'd1    : E_alu_rs1_data = E_pc;
        default : E_alu_rs1_data = E_rs1_data_next; //0
    endcase
end
always_comb begin
    case(E_alu_rs2_sel)
        2'd1    : E_alu_rs2_data = E_imm;
        default : E_alu_rs2_data = E_rs2_data_next; //0
    endcase
end
//mul
assign mul_u_rs1 = {1'b0, E_alu_rs1_data};
assign mul_u_rs2 = {1'b0, E_alu_rs2_data};
assign mul_s_rs1 = {E_alu_rs1_data[31], E_alu_rs1_data};
assign mul_s_rs2 = {E_alu_rs2_data[31], E_alu_rs2_data};
always_comb begin
    case(E_alu_op)
        `alu_mul, `alu_mulh, `alu_mulhsu : mul1 = mul_s_rs1;
        `alu_mulhu                       : mul1 = mul_u_rs1;
        default                          : mul1 = 33'b0;
    endcase
end
always_comb begin
    case(E_alu_op)
        `alu_mul, `alu_mulh     : mul2 = mul_s_rs2;
        `alu_mulhsu, `alu_mulhu : mul2 = mul_u_rs2;
        default                 : mul2 = 33'b0;
    endcase
end
assign mul_out = mul1 * mul2;
//alu
assign s_rs1 = E_alu_rs1_data;
assign s_rs2 = E_alu_rs2_data;
assign u_rs1 = E_alu_rs1_data;
assign u_rs2 = E_alu_rs2_data;
always_comb begin
    case(E_alu_op)
        `alu_add,`alu_auipc : E_alu_out = s_rs1 + s_rs2;
        `alu_sub            : E_alu_out = s_rs1 - s_rs2;
        `alu_sll            : E_alu_out = u_rs1 << u_rs2[4:0];
        `alu_slt            : E_alu_out = (s_rs1 < s_rs2)? 32'd1 : 32'b0;
        `alu_sltu           : E_alu_out = (u_rs1 < u_rs2)? 32'd1 : 32'b0;
        `alu_xor            : E_alu_out = s_rs1 ^ s_rs2;
        `alu_srl            : E_alu_out = u_rs1 >> u_rs2[4:0];
        `alu_sra            : E_alu_out = s_rs1 >>> u_rs2[4:0];
        `alu_or             : E_alu_out = s_rs1 | s_rs2;
        `alu_and            : E_alu_out = s_rs1 & s_rs2;
        `alu_j              : E_alu_out = s_rs1 + 32'd4;
        `alu_lui            : E_alu_out = s_rs2;
        `alu_mul            : E_alu_out = mul_out[31:0];
        `alu_mulh           : E_alu_out = mul_out[63:32];
        `alu_mulhsu         : E_alu_out = mul_out[63:32];
        `alu_mulhu          : E_alu_out = mul_out[63:32];
        `alu_csr            : E_alu_out = E_csr_data;
        default             : E_alu_out = 32'd0;
    endcase
end
//branch
always_comb begin
    case(E_alu_op)
        `alu_beq  : E_branch = (s_rs1 == s_rs2)? 1'b1 : 1'b0;
        `alu_bne  : E_branch = (s_rs1 != s_rs2)? 1'b1 : 1'b0;
        `alu_blt  : E_branch = (s_rs1 <  s_rs2)? 1'b1 : 1'b0;
        `alu_bge  : E_branch = (s_rs1 >= s_rs2)? 1'b1 : 1'b0;
        `alu_bltu : E_branch = (u_rs1 <  u_rs2)? 1'b1 : 1'b0;
        `alu_bgeu : E_branch = (u_rs1 >= u_rs2)? 1'b1 : 1'b0;
        default   : E_branch = ((1'b0)&(mul_out[65])&(mul_out[64]));
    endcase
end
//JB unit
assign E_jb_imm = E_imm;
assign E_jb = (E_jal||E_jalr||E_branch)? 1'b1 : 1'b0;
assign E_jb_op = (E_jalr)? E_rs1_data_next : E_pc;
assign E_jb_pc = E_jb_op + E_jb_imm;
//EXE state reg
always_ff @(posedge clk or posedge rst) begin
    if (rst)            M_mem_read <= 1'b0;
    else if (DM_stall)  M_mem_read <= M_mem_read;
    else                M_mem_read <= E_mem_read;
end
always_ff @(posedge clk or posedge rst) begin
    if (rst)            M_mem_write <= 1'b0;
    else if (DM_stall)  M_mem_write <= M_mem_write;
    else                M_mem_write <= E_mem_write;
end
always_ff @(posedge clk or posedge rst) begin
    if (rst)            M_reg_write <= 1'b0;
    else if (DM_stall)  M_reg_write <= M_reg_write;
    else                M_reg_write <= E_reg_write;
end
always_ff @(posedge clk or posedge rst) begin
    if (rst)            M_data_width <= 3'b0;
    else if (DM_stall)  M_data_width <= M_data_width;
    else                M_data_width <= E_data_width;
end
always_ff @(posedge clk or posedge rst) begin
    if (rst)            M_rd <= 5'b0;
    else if (DM_stall)  M_rd <= M_rd;
    else                M_rd <= E_rd;
end
always_ff @(posedge clk or posedge rst) begin
    if (rst)            M_alu_out <= 32'b0;
    else if (DM_stall)  M_alu_out <= M_alu_out;
    else                M_alu_out <= E_alu_out;
end
always_ff @(posedge clk or posedge rst) begin
    if (rst)            M_rs2_data <= 32'b0;
    else if (DM_stall)  M_rs2_data <= M_rs2_data;
    else                M_rs2_data <= E_rs2_data_next;
end
//================================    MEM stage    ================================//
//DM wen
always_comb begin
    if (M_mem_write==1'b1) begin
        case(M_data_width)
            `BYTE, `U_BYTE : begin
                case(M_alu_out[1:0])
                    2'd0 : DM_wen = 4'b1110;
                    2'd1 : DM_wen = 4'b1101;
                    2'd2 : DM_wen = 4'b1011;
                    2'd3 : DM_wen = 4'b0111;
                endcase
            end
            `HALF_WORD, `U_HALF_WORD : begin
                case(M_alu_out[1:0])
                    2'd0 : DM_wen = 4'b1100;
                    2'd1 : DM_wen = 4'b1001;
                    2'd2 : DM_wen = 4'b0011;
                    default : DM_wen = 4'b1111;
                endcase
            end
            `WORD : DM_wen = 4'b0000;
            default : DM_wen = 4'b1111;
        endcase
    end
    else DM_wen = 4'b1111;
end
//DM input data
always_comb begin
    case(M_data_width)
        `BYTE : begin
            case(M_alu_out[1:0])
                2'b0 : DM_in = { 24'b0, M_rs2_data[7:0] };
                2'd1 : DM_in = { 16'b0, M_rs2_data[7:0], 8'b0 };
                2'd2 : DM_in = { 8'b0, M_rs2_data[7:0], 16'b0 };
                2'd3 : DM_in = { M_rs2_data[7:0], 24'b0};
            endcase
        end
        `HALF_WORD : begin
            case (M_alu_out[1:0])
                2'b0    : DM_in = { 16'b0, M_rs2_data[15:0] };
                2'd1    : DM_in = { 8'b0, M_rs2_data[15:0], 8'b0 };
                2'd2    : DM_in = { M_rs2_data[15:0], 16'b0};
                default : DM_in = 32'b0;
            endcase
        end
        `WORD : DM_in = M_rs2_data;
        default : DM_in = 32'b0;
    endcase
end
//DM
assign DM_read = M_mem_read;
assign DM_addr = M_alu_out;
//MEM state reg
logic [31:0] WB_ld_data;
always_ff @(posedge clk or posedge rst) begin
    if (rst)           WB_mem_read <= 1'b0;
    else if (DM_stall) WB_mem_read <= 1'b0;
    else               WB_mem_read <= M_mem_read;
end
always_ff @(posedge clk or posedge rst) begin
    if (rst)           WB_reg_write <= 1'b0;
    else if (DM_stall) WB_reg_write <= 1'b0;
    else               WB_reg_write <= M_reg_write;
end
always_ff @(posedge clk or posedge rst) begin
    if (rst)           WB_rd <= 5'b0;
    else if (DM_stall) WB_rd <= 5'b0;
    else               WB_rd <= M_rd;
end
always_ff @(posedge clk or posedge rst) begin
    if (rst)           WB_alu_out <= 32'b0;
    else if (DM_stall) WB_alu_out <= 32'b0;
    else               WB_alu_out <= M_alu_out;
end
always_ff @(posedge clk or posedge rst) begin
    if (rst)           WB_data_width <= 3'b0;
    else if (DM_stall) WB_data_width <= 3'b0;
    else               WB_data_width <= M_data_width;
end
always_ff @(posedge clk or posedge rst) begin
    if (rst)           WB_ld_data <= 32'b0;
    else if (DM_stall) WB_ld_data <= 32'b0;
    else               WB_ld_data <= DM_out;
end
//================================    WB stage    ================================//
//load data filter
logic [31:0] WB_ld_data_next;
always_comb begin
    case(WB_data_width)
        `BYTE, `U_BYTE : begin
            case(WB_alu_out[1:0])
                2'b0 : WB_ld_data_next[7:0] = WB_ld_data[7:0];
                2'd1 : WB_ld_data_next[7:0] = WB_ld_data[15:8];
                2'd2 : WB_ld_data_next[7:0] = WB_ld_data[23:16];
                2'd3 : WB_ld_data_next[7:0] = WB_ld_data[31:24];
            endcase
            WB_ld_data_next[31:8] = (WB_data_width==`BYTE)? {24{WB_ld_data_next[7]}} : 24'b0;
        end
        `HALF_WORD, `U_HALF_WORD : begin
            case (WB_alu_out[1:0])
                2'd0 : WB_ld_data_next[15:0] = WB_ld_data[15:0];
                2'd1 : WB_ld_data_next[15:0] = WB_ld_data[23:8];
                2'd2 : WB_ld_data_next[15:0] = WB_ld_data[31:16];
                default : WB_ld_data_next[15:0] = 16'b0;
            endcase
            WB_ld_data_next[31:16] = (WB_data_width==`HALF_WORD) ? {16{WB_ld_data_next[15]}} : 16'b0;
        end
        `WORD : WB_ld_data_next = WB_ld_data;
        default : WB_ld_data_next = 32'b0;
    endcase
end
assign WB_data = (WB_mem_read==1'b1)?  WB_ld_data_next : WB_alu_out;
assign WB_en   = (WB_reg_write)? 1'b1 : 1'b0;

endmodule