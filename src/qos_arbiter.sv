module qos_arbiter #(
  parameter REQ_WIDTH = 2,
  parameter QOS_WIDTH = 4,
)(
  input  logic clk,
  input  logic rst_n,

  input  logic [REQ_WIDTH - 1:0] req_i,
  input  logic [QOS_WIDTH - 1:0] qos_i [REQ_WIDTH - 1:0],
  output logic [REQ_WIDTH - 1:0] grant_o
);

comparator_tree # (
  .DATA_WIDTH ( QOS___WIDTH ),
  .NUM__WORDS ( REQ___WIDTH )
)
comparator_tree_inst (
  .clk_i  ( clk_i  ),
  .rst_n  ( rst_n  ),
  .data_i ( qos_i ),
  .max_o  ( max_o  )
);

always_comb begin
  for ( int i = 0; i < REQ___WIDTH; i++ ) grant_o[i] = qos_i[i] == max_o;
end

endmodule
