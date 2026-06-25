module onehot_decoder #(
    parameter INPUT__WIDTH = 8,
    parameter OUTPUT_WIDTH = $clog2( INPUT__WIDTH )
)(
    input  logic [INPUT__WIDTH-1:0] onehot_i,
    output logic [OUTPUT_WIDTH-1:0] bin_o
);

always_comb begin
  bin_o = '0;
  for (int i = 0; i < INPUT__WIDTH; i++) if (onehot_i[i]) bin_o   = OUTPUT_WIDTH'(i);
end

endmodule
