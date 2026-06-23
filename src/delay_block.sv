module delay_block #(
  parameter DATA_WIDTH = 8
)(
  input logic clk_i,
  input logic rstn_i,

  input  logic [DATA_WIDTH - 1:0] data_i,
  output logic [DATA_WIDTH - 1:0] data_o
);

always_ff @( posedge clk_i ) begin
  if ( rstn_i ) data_o <= {DATA_WIDTH{1'b0}};
  else data_o <= data_i;
end

endmodule