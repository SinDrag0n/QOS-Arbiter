module qos_arbiter #(
  parameter REQ_WIDTH = 2,
  parameter QOS_WIDTH = 4
)(
  input  logic clk_i,
  input  logic rst_n,

  input  logic [REQ_WIDTH - 1:0] req_i,
  input  logic [QOS_WIDTH - 1:0] qos_i [REQ_WIDTH - 1:0],
  output logic [REQ_WIDTH - 1:0] grant_o
);

logic [QOS_WIDTH - 1:0] max_o;
logic [QOS_WIDTH - 1:0] qos_delayed [REQ_WIDTH - 1:0];
logic [REQ_WIDTH - 1:0] req_delayed;

comparator_tree # (
  .DATA_WIDTH ( QOS_WIDTH ),
  .NUM__WORDS ( REQ_WIDTH )
)
comparator_tree_inst (
  .clk_i  ( clk_i  ),
  .rst_n  ( rst_n  ),
  .data_i ( qos_i  ),
  .max_o  ( max_o  )
);
generate
  for ( genvar i = 0; i < REQ_WIDTH; i++ ) begin
    delay_block # (
      .DATA___WIDTH( QOS_WIDTH           ),
      .DELAY_CYCLES( $clog2( REQ_WIDTH ) )
    )
    qos_delay_block_inst (
      .clk_i  ( clk_i          ),
      .rstn_i ( rst_n          ),
      .data_i ( qos_i[i]       ),
      .data_o ( qos_delayed[i] )
    );
  end
endgenerate

delay_block # (
    .DATA___WIDTH( REQ_WIDTH           ),
    .DELAY_CYCLES( $clog2( REQ_WIDTH ) )
)
req_delay_block_inst (
    .clk_i  ( clk_i       ),
    .rstn_i ( rst_n       ),
    .data_i ( req_i       ),
    .data_o ( req_delayed )
);

always_comb for ( int i = 0; i < REQ_WIDTH; i++ ) grant_o[i] = req_delayed[i] & ( ( qos_delayed[i] == max_o ) | ( qos_delayed[i]  == {QOS_WIDTH{1'b0}} ) );


endmodule
