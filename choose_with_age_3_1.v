module choose_with_age_3_1
(
  input  [2:0] in_vld,
  input  [4:0] in_age [2:0],   //small age with higher priority
  output [2:0] out_vld
);

assign out_vld[0] =
    in_vld[ 0]                              &&
  (!in_vld[ 1] || in_age[ 1] >= in_age[ 0]) &&
  (!in_vld[ 2] || in_age[ 2] >= in_age[ 0]) ;

assign out_vld[1] =
    in_vld[ 1]                              &&
  (!in_vld[ 0] || in_age[ 0] >  in_age[ 1]) &&
  (!in_vld[ 2] || in_age[ 2] >= in_age[ 1]) ;

assign out_vld[2] =
    in_vld[ 2]                              &&
  (!in_vld[ 0] || in_age[ 0] >  in_age[ 2]) &&
  (!in_vld[ 1] || in_age[ 1] >  in_age[ 2]) ;

endmodule
