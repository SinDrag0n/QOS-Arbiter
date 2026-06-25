module arbiter #(
    parameter REQ_WIDTH = 4,
    parameter QOS_WIDTH = 2
) (
    input  logic                    clk_i,
    input  logic                    rst_n,
    input  logic                    grant_release,
    input  logic [REQ_WIDTH - 1:0]  req_i,
    input  logic [QOS_WIDTH - 1:0]  qos_i [REQ_WIDTH - 1:0],
    output logic [REQ_WIDTH - 1:0]  grant_o
);

logic [REQ_WIDTH - 1:0] grant_qos;
logic [REQ_WIDTH - 1:0] grant_next;
logic [REQ_WIDTH - 1:0] grant_reg;
logic                   upd_grant;
logic                   grant_release_delayed;

assign upd_grant = grant_release_delayed | ~|grant_reg;

qos_arbiter #(
    .REQ_WIDTH ( REQ_WIDTH ),
    .QOS_WIDTH ( QOS_WIDTH )
) qos_arbiter_inst (
    .clk_i      ( clk_i       ),
    .rst_n      ( rst_n       ),
    .req_i      ( req_i       ),
    .qos_i      ( qos_i       ),
    .grant_o    ( grant_qos   )
);

rr_arbiter #(
    .REQ_WIDTH ( REQ_WIDTH )
) rr_arbiter_inst (
    .clk_i      ( clk_i       ),
    .rst_n      ( rst_n       ),
    .req_i      ( grant_qos   ),
    .ptr_upd    ( upd_grant   ),
    .grant_o    ( grant_next  )
);

delay_block # (
    .DATA___WIDTH( REQ_WIDTH           ),
    .DELAY_CYCLES( $clog2( REQ_WIDTH ) )
)
req_delay_block_inst (
    .clk_i  ( clk_i       ),
    .rstn_i ( rst_n       ),
    .data_i ( grant_release         ),
    .data_o ( grant_release_delayed )
);

always_ff @( posedge clk_i ) begin
    if ( ~rst_n ) begin
        grant_reg <= {REQ_WIDTH{1'b0}};
    end else if ( upd_grant )  begin
    // end else begin
        grant_reg <= grant_next;
    end
end

assign grant_o = ( upd_grant ) ? ( grant_next ) : ( grant_reg );

endmodule
