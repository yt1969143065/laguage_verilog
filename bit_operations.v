module AAAA
//---------------------------------------------------------------------------------------
//根据队列指针ptr的位置，得到队列里面满足条件的slot位置
//---------------------------------------------------------------------------------------
//63--------ptr----------0
//>= ptr (大于等于， ptr左边包含)
assign ge_ptr_bitvec = {64{1'b1}} << ptr;
//> ptr （大于， ptr左边不包含）
assign g_ptr_bitvec = {64{1'b1}} << ({1'b0, ptr} + 1'b1);
//<= (小于等于， ptr右边包含)
assign le_ptr_bitvec = {64{1'b1}} >> (63 - ptr);
//<（小于， ptr右边不包含）
assign l_ptr_bitvec = {64{1'b1}} >> (64 - ptr);

//---------------------------------------------------------------------------------------
//根据队列的In指针(in_ptr)和当前的指针(cur_ptr)精确计算应该被flush的basic block, cur不flush
// 63----(in_ptr----)cur_ptr--------0    (flush > cur_ptr 且 flush <= in_ptr)
//(63-------)cur_ptr-----(in_ptr----0)   (flush > cur_ptr 或 flush <= in_ptr)
//---------------------------------------------------------------------------------------
assign br_flush_vec = 
   cur_ptr < in_ptr ?
  ({64{1'b1}} >> (63 - in_ptr)) & ({64{1'b1}} << ({1'b0, cur_ptr} + 1'b1)) :
  ({64{1'b1}} >> (63 - in_ptr)) | ({64{1'b1}} << ({1'b0, cur_ptr} + 1'b1)) ;
   
endmodule

//---------------------------------------------------------------------------------------
// 4bit找第一个1的位置
//---------------------------------------------------------------------------------------
module first_one_4_2(in,out,nonzero);
input  [3:0] in;
output [1:0] out; 
output nonzero;
 
assign out[1] = (~in[0])&(~in[1]) & (in[2] | in[3]);
assign out[0] = ((~in[0])&( in[1])) | ((~in[0])&(~in[2])&( in[3]));
assign nonzero   = |in[3:0];
endmodule

//---------------------------------------------------------------------------------------
// 8bit找第一个1的位置
//---------------------------------------------------------------------------------------
module first_one_8_3(in,out,nonzero);
input  [7:0] in;
output [2:0] out;
output nonzero;
 
assign out[2]=(~(|in[3:0]))&(|in[7:4]);
assign out[1]=((~in[0]) & (~in[1]) & (~in[4]) & (~in[5]) & (in[6] | in[7])) |
              ((~in[0]) & (~in[1]) & (in[2] | in[3]));
assign out[0]=((~in[0]) & (~in[2]) & (~in[4]) & (~in[6]) & in[7])|
              ((~in[0]) & (~in[2]) & (~in[4]) & in[5])|
              ((~in[0]) & (~in[2]) & in[3])|
              ((~in[0]) & in[1]);
assign nonzero=|in[7:0];
endmodule

//---------------------------------------------------------------------------------------
// 16bit找第一个1的位置
//---------------------------------------------------------------------------------------
module first_one_16_4(in,out,nonzero);
input  [15:0] in;
output [3:0] out;
output nonzero;
 
wire [1:0] a3,a2,a1,a0;
wire [3:0] nz;
wire zero;
 
`ifdef USE_DW

DW01_binenc #(16,5) first_one_16_4_DW0(.A(in),.ADDR({zero,out}));
assign nonzero = !zero;

`else

first_one_4_2 first_one_4_2_3(.in(in[15:12]),.out(a3),.nonzero(nz[3]));
first_one_4_2 first_one_4_2_2(.in(in[11: 8]),.out(a2),.nonzero(nz[2]));
first_one_4_2 first_one_4_2_1(.in(in[ 7: 4]),.out(a1),.nonzero(nz[1]));
first_one_4_2 first_one_4_2_0(.in(in[ 3: 0]),.out(a0),.nonzero(nz[0]));

first_one_4_2 first_one4(.in(nz),.out(out[3:2]),.nonzero(nonzero));

assign out[1:0]= a0 |
                (a1 & {2{~nz[0]}}) |
                (a2 & {2{~|nz[1:0]}}) |
                (a3 & {2{~|nz[2:0]}});
 
`endif
 
endmodule

//---------------------------------------------------------------------------------------
// 32bit找第一个1的位置
//---------------------------------------------------------------------------------------
module first_one_32_5(in,out,nonzero);
input  [31:0] in;
output [4:0] out;
output nonzero;

wire [2:0] a3,a2,a1,a0;
wire [3:0] nz;
wire zero;

`ifdef USE_DW
DW01_binenc #(32,6) first_one_32_5_DW0(.A(in),.ADDR({zero,out}));
assign nonzero = !zero;
`else
first_one_8_3 first_one3(.in(in[31:24]),.out(a3),.nonzero(nz[3]));
first_one_8_3 first_one2(.in(in[23:16]),.out(a2),.nonzero(nz[2]));
first_one_8_3 first_one1(.in(in[15: 8]),.out(a1),.nonzero(nz[1]));
first_one_8_3 first_one0(.in(in[ 7: 0]),.out(a0),.nonzero(nz[0]));

first_one_4_2 first_one4(.in(nz),.out(out[4:3]),.nonzero(nonzero));

assign out[2:0]= a0 |
                (a1 & {3{~nz[0]}})    |
                (a2 & {3{~|nz[1:0]}}) |
                (a3 & {3{~|nz[2:0]}});
`endif

endmodule

//---------------------------------------------------------------------------------------
// 64bit找第一个1的位置
//---------------------------------------------------------------------------------------
module first_one_64_6(in,out,nonzero);
input  [63:0] in;
output [5:0] out;
output nonzero;

wire [3:0] a3,a2,a1,a0;
wire [3:0] nz;
wire zero;

`ifdef USE_DW
DW01_binenc #(64,7) first_one_64_6_DW0(.A(in),.ADDR({zero,out}));
assign nonzero = !zero;
`else
first_one_16_4 first_one_16_4_3(.in(in[63:48]),.out(a3),.nonzero(nz[3]));
first_one_16_4 first_one_16_4_2(.in(in[47:32]),.out(a2),.nonzero(nz[2]));
first_one_16_4 first_one_16_4_1(.in(in[31:16]),.out(a1),.nonzero(nz[1]));
first_one_16_4 first_one_16_4_0(.in(in[15: 0]),.out(a0),.nonzero(nz[0]));

first_one_4_2  first_one_4_2_0(.in(nz),.out(out[5:4]),.nonzero(nonzero));

assign out[3:0]= a0 |
                (a1 & {4{~nz[0]}}) |
                (a2 & {4{~|nz[1:0]}}) |
                (a3 & {4{~|nz[2:0]}});
`endif                                                                                                                              
endmodule
