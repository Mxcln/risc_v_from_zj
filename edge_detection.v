//上升沿检测输出波形，out<=in;
//上升沿检测输出脉冲：将输入信号用寄存器得到延时一个周期的输入信号temp，~temp&in=1，得到一个脉冲pedge
//下降沿检测输出脉冲，将输入信号用寄存器得到延迟一个周期的输入信号temp，temp&~in=1，得到一个脉冲pedge
//边沿检测输出脉冲，将temp^in=1
//上升沿捕捉（遇到上升沿输出延迟一个周期的1，直到reset变回0），在上升沿检测中增加保持态和reset态）
//inst1 上升沿检测输出脉冲
module top_module (
    input clk,
    input [7:0] in,
    output reg [7:0] pedge
);
    reg [7:0] temp_in;
    always @(posedge clk) begin//上升沿检测
        temp_in<=in;
        pedge<=~temp_in&in;
    end

endmodule
//双边检测
module top_module1(
	input clk,
	input d,
	output q);
	reg p, n;	
	// A positive-edge triggered flip-flop
    always @(posedge clk)
        p <= d ^ n;   
    // A negative-edge triggered flip-flop
    always @(negedge clk)
        n <= d ^ p;
    // Why does this work? 
    // After posedge clk, p changes to d^n. Thus q = (p^n) = (d^n^n) = d.
    // After negedge clk, n changes to d^p. Thus q = (p^n) = (p^d^p) = d.
    // At each (positive or negative) clock edge, p and n FFs alternately
    // load a value that will cancel out the other and cause the new value of d to remain.
    assign q = p ^ n;
	// Can't synthesize this.
	/*always @(posedge clk, negedge clk) begin
		q <= d;
	end*/
endmodule

