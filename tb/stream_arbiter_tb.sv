
module stream_arbiter_tb;

  // Parameters
  localparam  T_DATA_WIDTH = 8;
  localparam  T_QOS__WIDTH = 4;
  localparam  STREAM_COUNT = 2;
  localparam  T_ID___WIDTH = $clog2(STREAM_COUNT);
  localparam  TEST_AMMOUNT = 5;

  //Ports
  logic clk_i;
  logic rst_n;
  logic [T_DATA_WIDTH - 1:0] s_data_i [STREAM_COUNT-1:0];
  logic [T_QOS__WIDTH - 1:0] s_qos_i  [STREAM_COUNT-1:0];
  logic [STREAM_COUNT - 1:0] s_last_i;
  logic [STREAM_COUNT - 1:0] s_valid_i;
  logic [STREAM_COUNT - 1:0] s_ready_o;
  logic [T_DATA_WIDTH - 1:0] m_data_o;
  logic [T_QOS__WIDTH - 1:0] m_qos_o;
  logic [T_ID___WIDTH - 1:0] m_id_o;
  logic m_last_o;
  logic m_valid_o;
  logic m_ready_i;

stream_arbiter # (
  .T_DATA_WIDTH( T_DATA_WIDTH ),
  .T_QOS__WIDTH( T_QOS__WIDTH ),
  .STREAM_COUNT( STREAM_COUNT )
)
stream_arbiter_inst (
  .clk_i      ( clk_i     ),
  .rst_n      ( rst_n     ),
  .s_data_i   ( s_data_i  ),
  .s_qos_i    ( s_qos_i   ),
  .s_last_i   ( s_last_i  ),
  .s_valid_i  ( s_valid_i ),
  .s_ready_o  ( s_ready_o ),
  .m_data_o   ( m_data_o  ),
  .m_qos_o    ( m_qos_o   ),
  .m_id_o     ( m_id_o    ),
  .m_last_o   ( m_last_o  ),
  .m_valid_o  ( m_valid_o ),
  .m_ready_i  ( m_ready_i )
);

always #5 clk_i = ~clk_i;

task reset();
  clk_i     <= 1'b0;
  rst_n     <= 1'b1;
  s_data_i  <= '{default: '0};
  s_qos_i   <= '{default: '0};
  s_last_i  <= '0;
  s_valid_i <= '0;
  m_ready_i <= 1'b0;

  #10;

  rst_n <= 1'b0;

  #90;
  rst_n <= 1'b1;
  m_ready_i <= 1'b1;
endtask

task driver();
    two_streams();
    #5000;
    two_streams_zero_qos();
    #5000;
    two_streams_same_qos();
endtask

task automatic one_stream( input int stream_id, input logic [T_QOS__WIDTH - 1:0] qos);
begin
  s_qos_i[stream_id]   <= qos;
  s_valid_i[stream_id] <= 1'b1;
  repeat (4) begin
    @( negedge clk_i )
    s_data_i[stream_id] <= $urandom_range(63,0);
    s_last_i[stream_id] <= 1'b0;
    @( posedge clk_i iff (s_ready_o[stream_id] == 1));
  end

  @( negedge clk_i );
  s_data_i[stream_id] <= $urandom_range(63,0);
  s_last_i[stream_id] <= 1'b1;

  @( posedge clk_i iff (s_ready_o[stream_id] == 1));

  @( negedge clk_i );
  s_data_i[stream_id]  <= '0;
  s_qos_i[stream_id]   <= '0;
  s_last_i[stream_id]  <= 1'b0;
  s_valid_i[stream_id] <= 1'b0;
end
endtask

task two_streams();
begin
  fork
    one_stream(0, 4'd3);
    one_stream(1, 4'd10);
  join
end
endtask


task two_streams_zero_qos();
begin
  fork
    one_stream(0, 4'd0);
    one_stream(1, 4'd10);
  join
end
endtask

task two_streams_same_qos();
begin
  fork
    one_stream(0, 4'd7);
    one_stream(1, 4'd7);
  join
end
endtask

// task monitor();
//   repeat ( TEST_AMMOUNT ) begin
//     @( negedge clk_i );
//       if ( q_valid_o )
//       q_expected = ( ( a_queue.pop_back() - b_queue.pop_back() ) * ( 1 + 3 * c_queue.pop_back() ) - 4 * d_queue.pop_back() ) / 2;

//       if ( q_expected != q_o ) begin
//         $error("Wrong output data, expected %d, got %d at moment: %t", q_expected, q_o, $time());
//       end
//   end
// endtask

initial begin
  reset();
  driver();
  $finish();
end

endmodule