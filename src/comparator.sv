module comparator #(
  parameter DATA_WIDTH = 8
)(
  input logic clk_i,
  input logic rstn_i,

  input  logic [DATA_WIDTH - 1:0] a_i,
  input  logic [DATA_WIDTH - 1:0] b_i,

  output logic [DATA_WIDTH - 1:0] res_o
);

always_ff @( posedge clk_i ) begin
  if ( ~rstn_i ) res_o <= {DATA_WIDTH{1'b0}};
  else          res_o <= ( a_i > b_i ) ? ( a_i ) : ( b_i );
end

endmodule