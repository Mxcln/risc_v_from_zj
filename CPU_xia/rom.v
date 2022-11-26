`timescale 1ns / 1ps

module rom(data,addr,read,ena);
    output [7:0] data;
    input [12:0] addr;
    input read,ena;
    reg [7:0] memory [13'h1fff : 0]; //位宽为8 
    wire [7:0] data;
    assign data=(read && ena)?memory[addr]:8'bzzzz_zzzz;
    //定义了一个8位宽，深度为1_1111_1111的存储阵列
    //当read模式、enable时，读addr的存储指令，否则就是高阻态
endmodule

