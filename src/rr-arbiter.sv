module rr_arbiter #(
  parameter REQ_WIDTH = 4
)(
  input  logic clk_i,
  input  logic rstn_i,

  input  logic [REQ_WIDTH - 1:0] req,
  output logic [REQ_WIDTH - 1:0] grant
);

logic [REQ_WIDTH - 1:0] req_rotated;
logic [REQ_WIDTH - 1:0] grant_rotated;

logic [2 * REQ_WIDTH - 1:0] req_double;
logic [2 * REQ_WIDTH - 1:0] grant_double;

logic [$clog2(REQ_WIDTH) - 1:0] ptr_ff;
logic [$clog2(REQ_WIDTH) - 1:0] ptr_next;

assign req_rotated_double = {req, req} >> ptr_ff;
assign req_rotated = req_shifted_double[REQ_WIDTH - 1:0];

assign grant_double = {grant_rotated, grant_rotated} << ptr_ff;
assign grant = grant_double[2 * REQ_WIDTH - 1:REQ_WIDTH - 1];

always_comb begin
  grant_rotated = {REQ_WIDTH{1'b0}};
  for (int i = 0; i < REQ_WIDTH; i++) begin
    if (req_rotated[i]) begin
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
  .onehot_i ( grant    ),
  .bin_o    ( ptr_next )
);

always_ff @(posedge clk_i or negedge rstn_i) begin
  if (~rstn_i)
    ptr_ff <= '0;
  else
    ptr_ff <= ptr_next;
end

endmodule