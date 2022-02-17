module roundrobin_arb_flop
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

reg [ARB_WIDTH-1:0] arb_state;

always @(posedge clk) begin
  if (rst) begin
    arb_state <= '0;
  end else begin
    if (arb_state == '0) begin
      if (req != '0) begin
        gnt       <= req & round_robin(req) & ~gnt;
        arb_state <= ~round_robin(req) & req;
      end else begin
        gnt       <= '0;
      end
    end else begin
      gnt       <= round_robin(arb_state) & req;
      arb_state <= ~round_robin(arb_state) & arb_state;
      if (pause) begin
        gnt       <= '0;
        arb_state <= arb_state;
      end
    end
  end
end

localparam AD = ARB_WIDTH;
localparam WD = 1<<AD;
function bit [WD-1:0] round_robin (bit [WD-1:0] req);
  bit [2*WD-1:0] d_req;
  bit [2*WD-1:0] d_gnt;
  bit [WD-1:0]   gnt  ;
  begin
    d_req = {req,req};
    d_gnt = d_req & ~(d_req-1);
    gnt   = d_gnt[WD-1:0] | d_gnt[2*WD-1:WD];
  end
  return gnt;
endfunction
endmodule  
