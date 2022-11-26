//算术逻辑运算单元 根据输入的8种不同操作码分别实现相应的加、与、异或、跳转等8种基本操作运算。
//利用这几种基本运算可以实现很多种其它运算以及逻辑判断等操作。
`timescale 1ns / 1ps

module alu(alu_out,zero,data,accum,alu_clk,opcode);
output [7:0] alu_out;
output zero;
input [2:0] opcode;
input [7:0] data,accum;
input alu_clk;
reg [7:0] alu_out;

parameter HLT=3'b000,   //暂停指令，将操作数accum传输到输出
          SKZ=3'b001,   //跳过指令，也是将操作数传输到输出
          ADD=3'b010,    //加法
          ANDD=3'b011,   //位与运算
          XORR=3'b100,   //位异或运算
          LDA=3'b101,    //传输指令，将data传输到输出
          STO=3'b110,    //存储指令，将accum传输到输出
          JMP=3'b111;    //跳转指令，将accum传输到输出
assign zero=!accum;//accum如果是全0，那么就输出zero标识位为1；
always @(posedge alu_clk)
    begin
        casex(opcode)
            HLT: alu_out<=accum;
            SKZ: alu_out<=accum;
            ADD: alu_out<=data+accum;
            ANDD: alu_out<=data&accum;
            XORR: alu_out<=data^accum;
            LDA: alu_out<=data;
            STO: alu_out<=accum;
            JMP: alu_out<=accum;
            default: alu_out<=8'bxxxx_xxxx;
        endcase
    end
endmodule

