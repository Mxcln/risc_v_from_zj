`timescale 1ns / 1ps

module state_ctrl(ena,fetch,rst);
output ena;
input fetch,rst;
reg ena;
always @(posedge fetch or posedge rst)
    begin
        if(rst)
            ena<=0;
        else
            ena<=1;
//state_ctrl模块的作用就是：在fetch上升沿时刻，如果rst是高，那就enable为低，否则就正常工作
    end
endmodule

