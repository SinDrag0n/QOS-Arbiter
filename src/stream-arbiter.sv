module stream_arbiter #(
  parameter  T_DATA_WIDTH = 8,
  parameter  T_QOS__WIDTH = 4,
  parameter  STREAM_COUNT = 2,
  localparam T_ID___WIDTH = $clog2(STREAM_COUNT)
)(
  input  logic clk_i,
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

logic [STREAM_COUNT - 1:0] input_handshake;
logic                      output_handshake;

logic [T_DATA_WIDTH - 1:0] m_data_ff;
logic                      m_valid_ff;
logic [T_ID___WIDTH - 1:0] m_id_ff;
logic                      m_last_ff;
logic [T_QOS__WIDTH - 1:0] m_qos_ff;

logic [STREAM_COUNT - 1:0] req;
logic [T_QOS__WIDTH - 1:0] qos_reg [STREAM_COUNT - 1:0];
logic [STREAM_COUNT - 1:0] grant;

logic                      grant_release;

logic [T_ID___WIDTH - 1:0] grant_dcd;

always_ff @( posedge clk_i ) begin
  if ( ~rst_n ) begin
    req     <=  {STREAM_COUNT{1'b0}};
    qos_reg <= '{default: '0};
  end else begin
    for ( int i = 0; i < STREAM_COUNT; i++ ) begin
      if ( s_valid_i[i] & ~req[i] ) begin
        req[i]     <= 1'b1;
        qos_reg[i] <= s_qos_i[i];
      end
      if ( input_handshake[i] & s_last_i[i] ) begin
        req[i]     <= 1'b0;
        qos_reg[i] <= {T_QOS__WIDTH{1'b0}};
      end
    end
  end
end

assign grant_release = output_handshake & m_last_o;

arbiter # (
  .REQ_WIDTH     ( STREAM_COUNT  ),
  .QOS_WIDTH     ( T_QOS__WIDTH  )
)
arbiter_inst (
  .clk_i         ( clk_i         ),
  .rst_n         ( rst_n         ),
  .grant_release ( grant_release ),
  .req_i         ( req           ),
  .qos_i         ( qos_reg       ),
  .grant_o       ( grant         )
);

onehot_decoder # (
  .INPUT__WIDTH   ( STREAM_COUNT ),
  .OUTPUT_WIDTH   ( T_ID___WIDTH )
)
onehot_decoder_inst (
  .onehot_i       ( grant        ),
  .bin_o          ( grant_dcd    )
);



assign input_handshake = s_valid_i & s_ready_o;
assign output_handshake = m_valid_o & m_ready_i;

always_ff @( posedge clk_i ) begin
  if ( ~rst_n ) begin
    m_data_ff  <= {T_DATA_WIDTH{1'b0}};
    m_valid_ff <= 1'b0;
    m_last_ff  <= 1'b0;
    m_id_ff    <= {T_ID___WIDTH{1'b0}};
    m_qos_ff   <= {T_QOS__WIDTH{1'b0}};
  end else begin
    if ( input_handshake[grant_dcd] ) begin
      m_data_ff  <= s_data_i[grant_dcd];
      m_id_ff    <= grant_dcd;
      m_qos_ff   <= s_qos_i[grant_dcd];
      m_last_ff  <= s_last_i[grant_dcd];
      m_valid_ff <= s_valid_i[grant_dcd];
    end else if ( m_ready_i ) begin
      m_valid_ff <= 1'b0;
      m_last_ff  <= 1'b0;
    end
  end
end

// Output stream logic

assign s_ready_o  = grant & ( m_ready_i | ~m_valid_o );
assign m_data_o   = m_data_ff;
assign m_id_o     = m_id_ff;
assign m_valid_o  = m_valid_ff;
assign m_qos_o    = m_qos_ff;
assign m_last_o   = m_last_ff;

endmodule
