module WDT(
    input clk,
    input rst,
    input clk2,
    input rst2,
    input WDEN,
    input WDLIVE,
    input [31:0] WTOCNT,
    output logic WTO
);
    logic D0,D1,D2,D3,CL2;
    logic [31:0] counter;

    assign CL2 = (D2 ^ D3);
    always @(posedge clk2)begin
        if(rst2)
            D0 <= 1'b0;
        else
            D0 <= ~D0;
    end
    
    always @(posedge clk) begin
        if(rst)begin
            D1 <= 1'b0;
            D2 <= 1'b0;
            D3 <= 1'b0;
        end
        else begin
            D1 <= D0;
            D2 <= D1;
            D3 <= D2;
        end
    end
    
    always @(posedge clk) begin
        if(rst)begin
            counter <= 32'b0;
            WTO <= 1'b0;
        end
        else begin 
            counter <= (~WDEN)?counter:
                        (WDLIVE)?32'd0 :
                        (CL2)?(counter + 32'd1):counter;
            WTO <= (~WDEN)?1'b0:(counter > WTOCNT)?1'b1:1'b0;
        end
    end

endmodule
