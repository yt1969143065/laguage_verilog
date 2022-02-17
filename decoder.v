module decoder
#(
  parameter LINES = 16,
  parameter WIDTH = $clog2(LINES)
)
(
  input   [WIDTH-1:0] binary_in,
  output  [LINES-1:0] unitary_out
);

//use generate
genvar i;
generate
for (i = 0; i < LINES; i = i + 1) begin
  assign unitary_out[i] = binary_in == i;
end
endgenerate
  
//a more simple code
/*
assign unitary_out = {LINES'b1} << binary_in;
*/
endmodule
