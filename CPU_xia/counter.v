  //程序计数器用于提供指令地址。以便读取指令，指令按地址顺序存放在存储器中。
  //有两种途径可形成指令地址：其一是顺序执行的情况，
  //其二是遇到要改变顺序执行程序的情况，例如执行JMP指令后，需要形成新的指令地址。复位后，指令指针为零，即每次CPU重新启动将从ROM的零地址开始读取指令并执行。
  //每条指令执行完需2个时钟，这时pc_addr已被增2，指向下一条指令。（因为每条指令占两个字节。）
  //如果正执行的指令是跳转语句，这时CPU状态控制器将会输出load_pc信号，通过load口进入程序计数器。程序计数器（pc_addr）将装入目标地址（ir_addr），而不是增2。

`timescale 1ns / 1ps

module counter(pc_addr,ir_addr,load,clk,rst);
output [12:0] pc_addr;
input [12:0] ir_addr;
input load,clk,rst;
reg [12:0] pc_addr;

always @(posedge clk or posedge rst)
    begin
        if(rst)
            pc_addr<=13'b0000_0000_0000;
        else
            if(load)//load是1时,直接将输入进行传输
                pc_addr<=ir_addr;
            else
                pc_addr<=pc_addr+1;
    end
endmodule

