//========================================================================
// sm-msgs : Source/Sink Request/Response Messages
//========================================================================
// 

`ifndef SM_MSGS_V
`define SM_MSGS_V

`include "vc-trace.v"

//------------------------------------------------------------------------
// Source RoCC Message: Unpack message
//------------------------------------------------------------------------
// Unpack a vector from the source into 
 module sm_RoccCmdUnpack
#(
  parameter p_rs1bits  = 32 
)(
  input  logic [p_rs1bits+p_rs1bits+32-1:0] msg,

  output logic [p_rs1bits-1:0] cmd_rs2,
  output logic [p_rs1bits-1:0] cmd_rs1,

  output logic [6:0] cmd_inst_funct, // set to 8-bit for ease of storage in xfile
  output logic [4:0] cmd_inst_rs2,
  output logic [4:0] cmd_inst_rs1,
  output logic       cmd_inst_xd,
  output logic       cmd_inst_xs1,
  output logic       cmd_inst_xs2,
  output logic [4:0] cmd_inst_rd,
  output logic [6:0] cmd_inst_opcode
);

  assign cmd_rs2         = msg[p_rs1bits+p_rs1bits+32-1:p_rs1bits+32];
  assign cmd_rs1         = msg[p_rs1bits+32-1:32];
  assign cmd_inst_funct  = msg[31:25];
  assign cmd_inst_rs2    = msg[24:20];
  assign cmd_inst_rs1    = msg[19:15];
  assign cmd_inst_xd     = msg[14];
  assign cmd_inst_xs1    = msg[13];
  assign cmd_inst_xs2    = msg[12];
  assign cmd_inst_rd     = msg[11:7];
  assign cmd_inst_opcode = msg[6:0];

endmodule

//------------------------------------------------------------------------
// Sink RoCC Message: Pack message
//------------------------------------------------------------------------
 module sm_RoccCmdPack
#(
  parameter p_rd_data_bits  = 32
)(
  
  input  logic [4:0]                  resp_rd,
  input  logic [p_rd_data_bits-1:0]   resp_data,

  output logic [5+p_rd_data_bits-1:0] msg
);

  assign msg = {resp_rd,resp_data};

endmodule

`endif /* SM_MSGS_V */

