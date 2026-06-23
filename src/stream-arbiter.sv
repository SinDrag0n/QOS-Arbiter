module stream_arbiter #(
  parameter  T_DATA_WIDTH = 8,
  parameter  T_QOS__WIDTH = 4,
  parameter  STREAM_COUNT = 2,
  localparam T_ID___WIDTH = $clog2(STREAM_COUNT)
)(
  input  logic clk,
  input  logic rst_n,

  // input streams
  input  logic [T_DATA_WIDTH-1:0] s_data_i [STREAM_COUNT-1:0],
  input  logic [T_QOS__WIDTH-1:0] s_qos_i  [STREAM_COUNT-1:0],
  input  logic [STREAM_COUNT-1:0] s_last_i ,
  input  logic [STREAM_COUNT-1:0] s_valid_i,
  output logic [STREAM_COUNT-1:0] s_ready_o,
  // output stream
  output logic [T_DATA_WIDTH-1:0] m_data_o,
  output logic [T_QOS__WIDTH-1:0] m_qos_o,
  output logic [T_ID___WIDTH-1:0] m_id_o,
  output logic                    m_last_o,
  output logic                    m_valid_o,
  input  logic                    m_ready_i
);

// inner variables

logic input_handshake;
logic [T_DATA_WIDTH - 1:0] m_data_ff;

logic [STREAM_COUNT - 1:0] req;
logic [STREAM_COUNT - 1:0] grant;

logic [T_ID___WIDTH - 1:0] grant_dcd;

onehot-decoder # (
  .INPUT__WIDTH(STREAM_COUNT),
  .OUTPUT_WIDTH(T_ID___WIDTH)
)
onehot-decoder_inst (
  .onehot_i ( grant     ),
  .bin_o    ( grant_dcd )
);

assign req    = s_valid_i;
assign m_id_o = grant_dcd; // bin from one-hot



// Round robin arbiter



// Static priority for QoS


assign input_handshake = s_valid_i & s_ready_o;

always_ff @( posedge clk_i ) begin
  if ( input_handshake ) m_data_ff <= s_data_i[grant_dcd];
end

// Output stream logic

assign m_data_o = m_data_ff


endmodule