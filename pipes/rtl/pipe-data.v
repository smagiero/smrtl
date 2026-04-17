//========================================================================
// pipes/rtl/pipe-data.v
//========================================================================
// Sebastian Claudiusz Magierowski Apr 17 2026

`ifndef PIPE_DATA_V
`define PIPE_DATA_V

`include "vc-trace.v"

module pipe_data
(
  input  logic        clk,
  input  logic        reset,

  input  logic        pipe_start_i,
  input  logic [31:0] num_inputs_i,
  output logic        pipe_done_o,

  input  logic        data_src_val_i,
  output logic        data_src_rdy_o,
  input  logic [63:0] data_src_msg_i,

  output logic        data_snk_val_o,
  input  logic        data_snk_rdy_i,
  output logic [63:0] data_snk_msg_o
);

  logic        running_reg;
  logic [31:0] retired_outputs_reg;
  logic        data_go;

  assign data_go       = data_snk_val_o && data_snk_rdy_i;
  assign data_src_rdy_o = running_reg && data_snk_rdy_i;
  assign data_snk_val_o = running_reg && data_src_val_i;
  assign data_snk_msg_o = data_src_msg_i;
  assign pipe_done_o    =
    running_reg && data_go && ( retired_outputs_reg + 32'd1 == num_inputs_i );

  always @( posedge clk ) begin
    if ( reset ) begin
      running_reg         <= 1'b0;
      retired_outputs_reg <= 32'b0;
    end
    else begin
      if ( pipe_start_i ) begin
        running_reg         <= 1'b1;
        retired_outputs_reg <= 32'b0;
      end
      else if ( pipe_done_o ) begin
        running_reg         <= 1'b0;
        retired_outputs_reg <= retired_outputs_reg + 32'd1;
      end
      else if ( data_go ) begin
        retired_outputs_reg <= retired_outputs_reg + 32'd1;
      end
    end
  end

  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  logic [95:0] state_str;

  `VC_TRACE_BEGIN
  begin
    $sformat( state_str, "r:%x/%x", retired_outputs_reg[7:0], num_inputs_i[7:0] );
    vc_trace.append_str( trace_str, state_str );
  end
  `VC_TRACE_END

endmodule

`endif /* PIPE_DATA_V */
