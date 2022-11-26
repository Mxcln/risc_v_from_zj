//累加器用于存放当前的结果，使能信号，时钟信号上升沿，接受来自总线的数据
`timescale 1ns / 1ps

module accumulator(accum,data,ena,clk1,rst);
output [7:0] accum;
input [7:0] data;
input ena,clk1,rst;
reg [7:0] accum;

always @(posedge clk1 or negedge rst)
    begin
        if(rst)
            accum<=8'b0000_0000;//进行reset
        else
            if(ena)
                accum<=data;//ena时，信号正常输出
    end
endmodule

