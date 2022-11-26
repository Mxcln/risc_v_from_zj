`timescale 1ns / 1ps

module state_machine(inc_pc,load_acc,load_pc,rd,wr,load_ir,
                        datactl_ena,halt,clk1,zero,ena,opcode);
output inc_pc,load_acc,load_pc;//inc_pc 程序计数器counter时钟信号，load_acc,load_pc程序计数器load信号(JMP)
output rd,wr;//指示是进行读还是写状态
output load_ir; //register寄存器模块是否读取指令
output datactl_ena,halt;//输出的是data_ctrl的使能，以及halt暂停（跳过）信号
input clk1,zero,ena;    //输入的零标志位，主控时钟是clk1（最快的那个），使能（由state_ctrl模块输出）
input [2:0] opcode;//输入的操作码

reg inc_pc,load_acc,load_pc,rd,wr,load_ir;
reg datactl_ena,halt;


parameter                 HLT    = 3'b000,  //暂停一个周期
                          SKZ    = 3'b001,  //为0跳过下一条语句，该操作先判断alu中结果是否为0，为0就跳过下一条语句，否则继续执行
                          ADD    = 3'b010,  //add相加：累加器中的值与地址所指的存储器或端口的数据相加
                         ANDD    = 3'b011,  //and相与
                         XORR    = 3'b100,  //XOr异或
                          LDA    = 3'b101,  //LDA读数据：指令中给出地址的数据 放入 累加器
                          STO    = 3'b110,  //STO写数据: 累加器的数据放入指令中给出的地址
                          JMP    = 3'b111;  //JMP无条件跳转语句：跳转至指令给出的目的地址，继续执行
//分析:state=000,001时，rd,load_ir 有效，此时正在读取指令
//HLT：000 001 读指令，010空操作 011 将halt=1 此后始终不操作，inc_pc经过两次上升沿，转到下一条指令
//SKZ: 000 001 读指令，010空操作 011 空操作 ...... 直到 111 ，若此时alu中数据为0，则跳过下一条语句(inc_pc+1),inc_pc经四次上升沿，实现跳过下一条指令
//如果此时alu不为0，则inc_pc经过两次上升沿，仅跳过当前指令
//ADD ANDD XORR LDA: 000 001 读指令， 010空操作 011空操作 100读指令(rd=1) 101将data存放到累加器，
//并在alu_clk上升沿到来时与累加器内的数据进行计算，110继续读数据    ？？？？为什么要读数据
//STO：100 输出累加器的数据(datactl_ena=1),101 110保持为1，同时101是wr=1，进行读写
//JMP：101 load_pc=1 且inc_pc=1 ,锁定目的地地址
//state=010时，空操作
//state=011时，如果指令为HLT则halt信号置1
//state=010时，如果指令为JMP则直接将
reg [2:0] state;
always @(negedge clk1)
    begin
        if(!ena)
            begin
            state<=3'b000;
            {inc_pc,load_acc,load_pc,rd}<=4'b0000;
            {wr,load_ir,datactl_ena,halt}<=4'b0000;//在enable信号为低时，进行全部置零的操作
            end
        else 
            ctl_cycle;//在enable为1的情况下，每次clk1的上升沿都进行一次task
    end
    //———————ctl_cycle task————————
task ctl_cycle;
    begin
        casex(state)//是一个state数量为8的状态机，一个完整的操作周期
        3'b000://进来后的第一个状态
            begin
                {inc_pc,load_acc,load_pc,rd}<=4'b0001;//第一次：rd和load_ir置高，寄存器读rom传过来的8位指令数据（高八位）
                {wr,load_ir,datactl_ena,halt}<=4'b0100;
                state<=3'b001;//按顺序进行下面的状态！
            end
        3'b001:
            begin//第二次：inc_pc和rd，load_ir置高，pc会加一，并且继续读rom的八位指令数据（低八位）
                {inc_pc,load_acc,load_pc,rd}<=4'b1001;
                {wr,load_ir,datactl_ena,halt}<=4'b0100;
                state<=3'b010;
            end
        3'b010:
            begin//第三次：空操作
                {inc_pc,load_acc,load_pc,rd}<=4'b0000;
                {wr,load_ir,datactl_ena,halt}<=4'b0000;
                state<=3'b011;
            end
        3'b011:
            begin//第四次：pc会加一
                if(opcode==HLT)
                    begin//如果操作码是hlt，说明要暂停，这时输出一个hlt标志位，并且是pc加一
                    {inc_pc,load_acc,load_pc,rd}<=4'b1000;
                    {wr,load_ir,datactl_ena,halt}<=4'b0001;
                    end
                else
                    begin//如果不是hlt，pc正常加一
                    {inc_pc,load_acc,load_pc,rd}<=4'b1000;
                    {wr,load_ir,datactl_ena,halt}<=4'b0000;
                    end
                state<=3'b100;
            end
        3'b100:
            begin//第五次：对不同操作符进行分支赋值
                if(opcode==JMP)
                    begin//如果是jump，跳过这一条，那么就直接load_pc，把目的地址送给程序计数器
                    {inc_pc,load_acc,load_pc,rd}<=4'b0010;  
                    {wr,load_ir,datactl_ena,halt}<=4'b0000;
                    end
                else if(opcode==ADD || opcode==ANDD ||
                        opcode==XORR|| opcode==LDA)
                      begin//如果是ADD,ANDD,XORR,LDA,那就正常进行read，计算得到数据
                      {inc_pc,load_acc,load_pc,rd}<=4'b0001;  //此时read的是8位的数据（地址对应的），而不是指令+地址
                      {wr,load_ir,datactl_ena,halt}<=4'b0000;
                      end
                else if(opcode==STO)
                    begin//如果是STO，那就将datactl_ena（数据控制模块使能）置高，输出累加器的数据
                    {inc_pc,load_acc,load_pc,rd}<=4'b0000;
                    {wr,load_ir,datactl_ena,halt}<=4'b0010;
                    end
                else
                    begin//否则，就全部为0
                    {inc_pc,load_acc,load_pc,rd}<=4'b0000;
                    {wr,load_ir,datactl_ena,halt}<=4'b0000;
                    end
                state<=3'b101;
            end
        3'b101:
            begin//第六次：
                if(opcode==ADD || opcode==ANDD ||
                    opcode==XORR || opcode==LDA)
                    begin//如果是上面这些操作，那就要继续进行这些操作，与累加器的输出进行运算
                    {inc_pc,load_acc,load_pc,rd}<=4'b0101;
                    {wr,load_ir,datactl_ena,halt}<=4'b0000;
                    end
                else if(opcode==SKZ && zero==1)
                    begin//如果是SKz，先判断是否是零，如果是零就pc+1，否则就全零空操作
                    {inc_pc,load_acc,load_pc,rd}<=4'b1000;
                    {wr,load_ir,datactl_ena,halt}<=4'b0000;
                    end
                else if(opcode==JMP)
                    begin//如果是JMP，那就pc+1，然后load_pc，锁定目的地址
                    {inc_pc,load_acc,load_pc,rd}<=4'b1010;
                    {wr,load_ir,datactl_ena,halt}<=4'b0000;
                    end
                else if(opcode==STO)
                    begin//如果是STO，就将数据写入地址处
                    {inc_pc,load_acc,load_pc,rd}<=4'b0000;
                    {wr,load_ir,datactl_ena,halt}<=4'b1010;
                    end
                else 
                    begin
                    {inc_pc,load_acc,load_pc,rd}<=4'b0000;
                    {wr,load_ir,datactl_ena,halt}<=4'b0000;
                    end
                state<=3'b110;
            end
        3'b110:
            begin//第七次，空操作
                if(opcode==STO)
                    begin//如果是STO，那么需要使数据控制模块enable
                    {inc_pc,load_acc,load_pc,rd}<=4'b0000;
                    {wr,load_ir,datactl_ena,halt}<=4'b0010;
                    end
                else if(opcode==ADD || opcode==ANDD ||
                    opcode==XORR || opcode==LDA)
                    begin//如果是这些操作码，那就进行read
                    {inc_pc,load_acc,load_pc,rd}<=4'b0001;
                    {wr,load_ir,datactl_ena,halt}<=4'b0000;
                    end
                else 
                    begin
                    {inc_pc,load_acc,load_pc,rd}<=4'b0000;
                    {wr,load_ir,datactl_ena,halt}<=4'b0000;
                    end
                state<=3'b111;
            end
        3'b111:
            begin//第八次
                if(opcode==SKZ && zero==1)
                    begin//如果是SKZ，并且是零，那么就pc+1,否则空操作
                    {inc_pc,load_acc,load_pc,rd}<=4'b1000;
                    {wr,load_ir,datactl_ena,halt}<=4'b0000;
                    end
                else 
                    begin
                    {inc_pc,load_acc,load_pc,rd}<=4'b0000;
                    {wr,load_ir,datactl_ena,halt}<=4'b0000;
                    end
                state<=3'b000;
            end
        default:
            begin
            {inc_pc,load_acc,load_pc,rd}<=4'b0000;
            {wr,load_ir,datactl_ena,halt}<=4'b0000;
            state<=3'b000;
            end
        endcase
    end
endtask
//————————end of task————————
endmodule
