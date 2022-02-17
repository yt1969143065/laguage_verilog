module roundrobin_arb
#(
  parameter ARB_WIDTH = 4
)
(
  input  logic [ARB_WIDTH-1:0] req,
  input  logic                 pause,
  output logic [ARB_WIDTH-1:0] gnt,
  input  logic                 clk,
  input  logic                 rst
);

reg [ARB_WIDTH-1:0] state;

assign gnt = !pause? round_robin(req, state) : '0;
always @(posedge clk) begin
  if (rst) begin
    state <= 1;
  end else if (|req) begin
    if (state[ARB_WIDTH-1]) state <= 1;
    else state <= state<<1;
  end
end

localparam WD = ARB_WIDTH;
function bit [WD-1:0] round_robin (bit [WD-1:0] req, bit [WD-1:0] pos);
  bit [2*WD-1:0] d_req;
  bit [2*WD-1:0] d_gnt;
  bit [WD-1:0]   gnt  ;
  begin
    d_req = {req,req};
    d_gnt = d_req & ~(d_req-pos);
    gnt   = d_gnt[WD-1:0] | d_gnt[2*WD-1:WD];
  end
  return gnt;
endfunction
endmodule
