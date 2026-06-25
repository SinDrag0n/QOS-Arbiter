module delay_block #(
  parameter DATA___WIDTH = 8,
  parameter DELAY_CYCLES = 1
)(
  input logic clk_i,
  input logic rstn_i,

  input  logic [DATA___WIDTH - 1:0] data_i,
  output logic [DATA___WIDTH - 1:0] data_o
);

generate
  if ( DELAY_CYCLES > 1) begin
    logic [DELAY_CYCLES - 1:0][DATA___WIDTH - 1:0] shift_reg;

    always_ff @( posedge clk_i ) begin
      if ( ~rstn_i ) begin
        shift_reg <= '0;
      end else begin
        shift_reg <= {shift_reg[DELAY_CYCLES - 2:0], data_i};
      end
    end

    assign data_o = shift_reg[DELAY_CYCLES - 1];

  end else begin
    always_ff @( posedge clk_i ) begin
      if ( ~rstn_i ) data_o <= {DATA___WIDTH{1'b0}};
      else           data_o <= data_i;
    end
  end
endgenerate

endmodule
