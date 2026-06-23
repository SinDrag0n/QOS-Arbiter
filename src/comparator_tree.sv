module comparator_tree #(
  parameter int DATA_WIDTH = 8,
  parameter int NUM__WORDS = 5
)(
  input  logic clk_i,
  input  logic rst_n,

  input  logic [DATA_WIDTH - 1:0] data_i [NUM__WORDS - 1:0],

  output logic [DATA_WIDTH - 1:0] max_o
);

localparam COLUMNS = $clog2(NUM__WORDS);
localparam ROWS    = NUM__WORDS;

logic [DATA_WIDTH - 1:0] comp_tree [0:COLUMNS][0:ROWS - 1];

assign comp_tree[0] = data_i;

function automatic int iter_div ( input int number_of_divs ); // Division function with rounding up as Verilog rounds down
  int result = ROWS;
  if ( number_of_divs ) for ( int i = 0; i < number_of_divs; i++ ) result = ( ( result + 1 ) / 2 );
  return result;
endfunction

function automatic int column_last_idx ( input int col ); // Counts last index of choosen collumn of tree
  int idx = iter_div( col ) - 1;
  return idx;
endfunction

generate
  for ( genvar col = 0; col < COLUMNS; col++ ) begin
    for ( genvar row = 1; row <= column_last_idx( col ); row = row + 2 ) begin // begin from 2nd element of column
      comparator #(
        .DATA_WIDTH ( DATA_WIDTH )
      )(
        .clk_i  ( clk_i ),
        .rstn_i ( rst_n ),
        .a_i    ( comp_tree[col][row - 1]    ),
        .b_i    ( comp_tree[col][row]        ),
        .res_o  ( comp_tree[col + 1][row / 2])
      );
    end

    if ( iter_div( col ) % 2 ) begin
      delay_block #(
        .DATA_WIDTH ( DATA_WIDTH )
      )(
        .clk_i  ( clk_i ),
        .rstn_i ( rst_n ),
        .data_i ( comp_tree[col]  [column_last_idx( col )]    ),
        .data_o ( comp_tree[col+1][column_last_idx( col + 1)] )
      );
    end
  end
endgenerate

assign max_o = comp_tree[COLUMNS][0];

endmodule
