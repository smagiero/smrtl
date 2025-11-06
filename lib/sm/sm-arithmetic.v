//========================================================================
// Verilog Components: Arithmetic Components
//========================================================================

`ifndef SM_ARITHMETIC_V
`define SM_ARITHMETIC_V

//------------------------------------------------------------------------
// Multipliers
//------------------------------------------------------------------------

module sm_SimpleMultiplier
#(
  parameter p_nbits = 16
)(
  input  [p_nbits-1:0] in0,
  input  [p_nbits-1:0] in1,
  output [p_nbits-1:0] out
);

  assign out = in0 * in1;

endmodule

//------------------------------------------------------------------------
// 8-bit SubWord Sampler (SWS)
//------------------------------------------------------------------------
// …,5,4,3,2,1,0
module sm_SubWordSampler8
#(
  parameter p_nbits = 16,
  parameter p_startbits = 16
)(
  input  [p_nbits-1:0] in,
  input  [p_startbits-1:0] startbit,
  output [p_nbits-1:0] out
);

  assign out = ( in >> startbit[15:0] );

endmodule

//------------------------------------------------------------------------
// ReLU
//------------------------------------------------------------------------

module sm_ReLu
#(
  parameter p_nbits = 16
)(
  input  [p_nbits-1:0] in,
  output [p_nbits-1:0] out
);

  assign out = (in[p_nbits-1]==0)? in : 0; // pass positive, zero-out negative

endmodule

`endif /* SM_ARITHMETIC_V */

