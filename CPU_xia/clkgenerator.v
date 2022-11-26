//clk_gen.v
//时钟信号生成器，由于只要用到8分频时钟，采用有限状态机设计

//由于在时钟发生器的设计中采用了同步状态机的设计方法，
//不但使clk_gen模块的源程序可以被各种综合器综合，
//也使得由其生成的fetch、alu_clk 在跳变时间同步性能上有明显的提高，为整个系统的性能提高打下了良好的基础。
`timescale 1ns / 1ps

module clkgenerator(clk,rst,clk1,clk2,clk4,fetch,alu_clk);
input clk,rst;
output wire clk1;
output reg clk2,clk4,fetch,alu_clk;//三个不同时钟，fetch时钟，alu时钟,全部要是reg类型

reg [7:0] state;
parameter S1=8'b0000_0001,
          S2=8'b0000_0010,
          S3=8'b0000_0100,
          S4=8'b0000_1000,
          S5=8'b0001_0000,
          S6=8'b0010_0000,
          S7=8'b0100_0000,
          S8=8'b1000_0000,
          idle=8'b0000_0000;
//利用状态机来写，提高了代码的可综合性
assign clk1=~clk;

always @(negedge clk)
    if(rst)
        begin
            clk2<=0;
            clk4<=0;
            fetch<=0;
            alu_clk<=0;
            state<=idle;
        end
    else
        begin
            case(state)
                S1:
                    begin
                    clk2<=~clk2;//clk2每次都反向，其实是clk的二倍
                    alu_clk<=~alu_clk;
                    state<=S2;
                    end
                S2:
                    begin
                    clk2<=~clk2;
                    clk4<=~clk4;
                    alu_clk<=~alu_clk;//alu在一个大周期（8个系统周期）内只有一次
                    state<=S3;
                    end
                S3:
                    begin
                    clk2<=~clk2;
                    state<=S4;
                    end
                S4:
                    begin
                    clk2<=~clk2;
                    clk4<=~clk4;//clk4每两个系统时钟变一次，就是四倍的系统周期
                    fetch<=~fetch;//fetch每个大周期内变一次，是八个系统周期
                    state<=S5;
                    end
                S5:
                    begin
                    clk2<=~clk2;
                    state<=S6;
                    end
                S6:
                    begin
                    clk2<=~clk2;
                    clk4<=~clk4;
                    state<=S7;
                    end
                S7:
                    begin
                    clk2<=~clk2;
                    state<=S8;
                    end
                S8:
                    begin
                    clk2<=~clk2;
                    clk4<=~clk4;
                    fetch<=~fetch;
                    state<=S1;
                    end
                idle:
                    begin
                    state<=S1;//初始状态
                    end
                default://为了避免电路级错误而写default
                    begin
                    state<=idle;
                    end
            endcase
        end
endmodule

      
                        