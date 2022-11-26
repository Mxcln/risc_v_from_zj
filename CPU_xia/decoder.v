`timescale 1ns / 1ps
//外围模块_地址译码器，用于宣统rom或ram
module decoder(addr,rom_sel,ram_sel);
output rom_sel,ram_sel;
input [12:0] addr;
reg rom_sel,ram_sel;

always @(addr)
    begin
        casex(addr)
            13'b1_1xxx_xxxx_xxxx:{rom_sel,ram_sel}<=2'b01;
            13'b0_xxxx_xxxx_xxxx:{rom_sel,ram_sel}<=2'b10;
            13'b1_0xxx_xxxx_xxxx:{rom_sel,ram_sel}<=2'b10;
            default:{rom_sel,ram_sel}<=2'b00;
       endcase
//只有地址码的前两位全1，才选通ram，否则一直是rom
    end
endmodule

