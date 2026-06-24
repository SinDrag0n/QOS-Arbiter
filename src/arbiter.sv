module arbiter #(
    parameter REQ_WIDTH = 4,
    parameter QOS_WIDTH = 2
) (
    input  logic                    clk_i,
    input  logic                    rst_n,
    input  logic [REQ_WIDTH - 1:0]  req_i,
    input  logic [QOS_WIDTH - 1:0]  qos_i [REQ_WIDTH - 1:0],
    output logic [REQ_WIDTH - 1:0]  grant_o
);

logic [REQ_WIDTH - 1:0] grant_qos;

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
    .req_i      ( req_i       ),
    .grant_o    ( grant_o     )
);


endmodule