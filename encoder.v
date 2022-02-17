module encoder 
#(
  parameter LINES = 16,
  parameter WIDTH = $clog2(LINES)
)
(
  input    [LINES-1:0] unitary_in,
  output   [WIDTH-1:0] binary_out
);

genvar i, j;
wire [LINES-1:0] binary_out_tmp [WIDTH-1:0];

generate 
for (i = 0; i < LINES; i = i + 1) begin: loop_i
  for (j = 0; j < WIDTH; j = j + 1) begin: loop_j
    assign binary_out_tmp[j][i] = i[j] & unitary_in[i];
  end
end
endgenerate

generate
for(i=0; i<WIDTH; i=i+1) begin
  assign binary_out[i] = |binary_out[i];
end
endgenerate

endmodule
