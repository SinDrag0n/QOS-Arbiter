module rr-arbiter #(
  parameter REQ_WIDTH = 4
)(
  input  logic clk_i,
  input  logic rstn_i,

  input  logic [REQ_WIDTH - 1:0] req,
  output logic                   grant
);



endmodule