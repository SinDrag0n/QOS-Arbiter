module rr_arbiter #(
  parameter REQ_WIDTH = 4
)(
  input  logic clk_i,
  input  logic rst_n,

  input  logic [REQ_WIDTH - 1:0] req_i,
  input  logic                   ptr_upd,
  output logic [REQ_WIDTH - 1:0] grant_o
);

logic [REQ_WIDTH - 1:0] req_rotated;
logic [REQ_WIDTH - 1:0] grant_rotated;

logic [2 * REQ_WIDTH - 1:0] req_double;
logic [2 * REQ_WIDTH - 1:0] grant_double;

logic [$clog2( REQ_WIDTH ) - 1:0] ptr_ff;
logic [$clog2( REQ_WIDTH ) - 1:0] ptr_next;

assign req_double  = {req_i, req_i} >> ptr_ff;
assign req_rotated = req_double[REQ_WIDTH - 1:0];

assign grant_double = {grant_rotated, grant_rotated} << ptr_ff;
assign grant_o      = grant_double[2 * REQ_WIDTH - 1:REQ_WIDTH];

always_comb begin
  grant_rotated = {REQ_WIDTH{1'b0}};
  for ( int i = 0; i < REQ_WIDTH; i++ ) begin
    if ( req_rotated[i] ) begin
      grant_rotated[i] = 1'b1;
      break;
    end
  end
end

onehot_decoder # (
  .INPUT__WIDTH( REQ_WIDTH ),
  .OUTPUT_WIDTH( $clog2( REQ_WIDTH ) )
)
onehot_decoder_inst (
  .onehot_i ( grant_o  ),
  .bin_o    ( ptr_next )
);

always_ff @( posedge clk_i ) begin
  if ( ~rst_n )
    ptr_ff <= '0;
  else if ( ptr_upd & |grant_o )
    if ( ptr_next == REQ_WIDTH - 1 ) begin
      ptr_ff <= '0;
    end else begin
      ptr_ff <= ptr_next + 1'b1;
    end
end

endmodule
