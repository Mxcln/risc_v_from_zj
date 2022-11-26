module Eating
(
	input clk,
	input rst,
	input [5:0]headx,
	input [5:0]heady,    // 蛇头的位置，用来判断是否和食物位置相一致
	output reg [5:0]foodx,
	output reg [4:0]foody,  // 食物的位置 输出为VGA显示提供坐标
	output reg add  //吃到食物则为1,传递给VGA实现在下一秒蛇增长
);

	reg [31:0]cnt;
	reg [10:0]randomnum; //用来产生伪随机苹果
	always@(posedge clk)
		randomnum <= randomnum + 998;  
	
	always@(posedge clk or negedge rst) begin
        //苹果位置初始化
		if(!rst) begin
			cnt <= 0;
			foodx <= 24;
			foody <= 10;
			add <= 0;
		end
		else begin
			cnt <= cnt+1;
			if(cnt == 250000) begin
				cnt <= 0;
				if(foodx == headx && foody == heady)
				 begin
					add <= 1;
					foodx <= (randomnum[10:5] > 38) ? (randomnum[10:5] - 25) : (randomnum[10:5] == 0) ? 1 : randomnum[10:5];
					foody <= (randomnum[4:0] > 28) ? (randomnum[4:0] - 3) : (randomnum[4:0] == 0) ? 1:randomnum[4:0];
				end  
				else
					add <= 0;
					foodx<=foodx;
					foody<=foody;
			end
		end
	end
endmodule