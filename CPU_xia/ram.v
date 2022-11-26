`timescale 1ns / 1ps

module ram(data,addr,read,write,ena);
    output [7:0] data;
    input [9:0] addr;
    input read,write,ena;
    reg [7:0] ram [10'h3ff: 0];
    
    assign data=(read && ena)?ram[addr]:8'hzz;
    
    always @(posedge write)
        begin
        ram[addr]<=data;
        end
        
endmodule

