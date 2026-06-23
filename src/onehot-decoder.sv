module onehot-decoder #(
    parameter int INPUT__WIDTH = 8,
    parameter int OUTPUT_WIDTH = $clog2( INPUT__WIDTH )
)(
    input  logic [INPUT__WIDTH-1:0] onehot_i,
    output logic [OUTPUT_WIDTH-1:0] bin_o,
);

always_comb begin
  bin_o   = '0;
  for (int i = 0; i < OUTPUT_WIDTH; i++) if (onehot_i[i]) bin_o   = BIN_WIDTH'(i);
end

endmodule