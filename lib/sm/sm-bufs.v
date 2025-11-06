//========================================================================
// Verilog Components: Buffers
//========================================================================

`ifndef SM_BUFS_V
`define SM_BUFS_V

//------------------------------------------------------------------------
// Tristate Buffer
//------------------------------------------------------------------------

module sm_Buf
#(
  parameter p_nbits = 1
)(
  input logic [p_nbits-1:0] in,
  input logic               en,

  output tri  [p_nbits-1:0] out
);

  assign out = en ? in : p_nbits'('bz);
  
endmodule

`endif /* SM_BUFS_V */

