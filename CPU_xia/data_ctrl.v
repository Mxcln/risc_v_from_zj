 //数据控制器的作用是控制累加器数据输出,数据总线有时要传输指令，有时要传送RAM区或接口的数据。
 //累加器的数据只有在需要往RAM区或端口写时才允许输出，否则应呈现高阻态，以允许其它部件使用数据总线。
`timescale 1ns / 1ps

module data_ctrl(data,in,data_ena);
output [7:0] data;
input [7:0] in;
input data_ena;

assign data=(data_ena)? in:8'bzzzz_zzzz;
//data_ena如果为0，输出高阻；
//data_ena如果为1，将输入进行输出；
//这相当于一个受控的buffer
endmodule

