`timescale 1ns / 1ps

module instr_reg(opc_iraddr,data,ena,clk1,rst);
output [15:0] opc_iraddr;//这个就是输出的16进制opcode的地址
input [7:0] data;        //这个是输入数据
input ena,clk1,rst;      // load_ir输入进来，表示这时是否进行指令地址寄存
reg [15:0] opc_iraddr;

reg state;
always @(posedge clk1)
    begin
        if(rst)
            begin
            opc_iraddr<=16'b0000_0000_0000_0000;
            state<=1'b0;
            end
        else
            begin
                if(ena)
                    begin
                        casex(state)
                            1'b0:
                                begin
                                opc_iraddr[15:8]<=data;//先存高八位
                                state<=1;
                                end
                            1'b1:
                                begin
                                opc_iraddr[7:0]<=data;//再存低八位
                                state<=0;
                                end
                            default:
                                begin
                                opc_iraddr[15:0]<=16'bxxxx_xxxx_xxxx_xxxx;
                                state<=1'bx;
                                end
                        endcase
                    end
                else
                    state<=1'b0;//如果总线不是指令，则state一直是0
    end
    end
endmodule

