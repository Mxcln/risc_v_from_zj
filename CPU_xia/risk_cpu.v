`timescale 1ns / 1ps

module risc_cpu(clk,reset,halt,rd,wr,addr,data); 

 input clk,reset; 
 output rd,wr,addr,halt; 
 inout data; 
 wire clk,reset,halt; 
 wire [7:0] data; 
 wire [12:0] addr; 
 wire rd,wr; 
 wire clk1,fetch,alu_clk; 
 wire [2:0] opcode; 
 wire [12:0] ir_addr,pc_addr; 
 wire [7:0] alu_out,accum; 
 wire zero,inc_pc,load_acc,load_pc,load_ir,data_ena,contr_ena;
 
//1时钟生成器
clkgenerator my_clkgenerator(.clk(clk),.clk1(clk1),.fetch(fetch),
                                 .alu_clk(alu_clk),.rst(reset));
//2指令寄存器
instr_reg my_instr_reg(.opc_iraddr({opcode,ir_addr[12:0]}),.data(data),.ena(load_ir),
                        .clk1(clk1),.rst(reset));
//3累加器
accumulator my_accumulator(.accum(accum),.data(alu_out),.ena(load_ir),
                            .clk1(clk1),.rst(reset));
//4算数逻辑单元：
alu my_alu(.alu_out(alu_out),.zero(zero),.data(data),.accum(accum),
           .alu_clk(alu_clk),.opcode(opcode));
//5状态机控制模块：
state_ctrl my_state_ctrl(.ena(contr_ena),.fetch(fetch),.rst(reset));
//6状态机模块：
state_machine my_machine (.inc_pc(inc_pc),.load_acc(load_acc),.load_pc(load_pc), 
             .rd(rd), .wr(wr), .load_ir(load_ir), .clk1(clk1), 
             .datactl_ena(data_ena), .halt(halt), .zero(zero), 
             .ena(contr_ena),.opcode(opcode));
//7数据控制器（累加器）
data_ctrl my_data_ctrl(.data(data),.in(alu_out),.data_ena(data_ena));
//8地址多路器
addr my_addr(.addr(addr),.fetch(fetch),.ir_addr(ir_addr),.pc_addr(pc_addr));
//9程序计数器
counter my_counter(.pc_addr(pc_addr),.ir_addr(ir_addr),
                    .load(load_pc),.clk(inc_pc),.rst(reset));
endmodule

