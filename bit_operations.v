//case1
//根据队列指针ptr的位置，得到队列里面满足条件的slot位置
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
