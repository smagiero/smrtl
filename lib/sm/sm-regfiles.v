//========================================================================
// Verilog Components: Register Files
//========================================================================

`ifndef SM_REGFILES_V
`define SM_REGFILES_V

`include "vc-assert.v"

//------------------------------------------------------------------------
// 2r1w register file
//------------------------------------------------------------------------

module sm_Regfile_2r1w
#(
  parameter p_data_nbits  = 1,
  parameter p_num_entries = 2,
  parameter p_reset_value = 0,

  // Local constants not meant to be set from outside the module
  parameter c_addr_nbits  = $clog2(p_num_entries)
)(
  input                     clk,
  input                     reset,

  // Read port 0 (combinational read)

  input  [c_addr_nbits-1:0] read_addr0,
  output [p_data_nbits-1:0] read_data0,

  // Read port 1 (combinational read)

  input  [c_addr_nbits-1:0] read_addr1,
  output [p_data_nbits-1:0] read_data1,

  // Write port (sampled on the rising clock edge)

  input                     write_en,
  input [c_addr_nbits-1:0]  write_addr,
  input [p_data_nbits-1:0]  write_data
);

  reg [p_data_nbits-1:0] rfile[p_num_entries-1:0];

  // Combinational read

  assign read_data0 = rfile[read_addr0];
  assign read_data1 = rfile[read_addr1];

  // Write on positive clock edge. We have to use a generate statement to
  // allow us to include the reset logic for each individual register.

  genvar i;
  generate
    for ( i = 0; i < p_num_entries; i = i+1 )
    begin : wport
      always @( posedge clk )
        if ( reset )
          rfile[i] <= p_reset_value;
        else if ( write_en && (i == write_addr) )
          rfile[i] <= write_data;
    end
  endgenerate

  // Assertions

  always @( posedge clk ) begin
    if ( !reset ) begin
      `VC_ASSERT_NOT_X( write_en );

      // If write_en is one, then write address better be less than the
      // number of entries and definitely cannot be X's.

      if ( write_en ) begin
        `VC_ASSERT_NOT_X( write_addr );
        `VC_ASSERT( write_addr < p_num_entries );
      end

    end
  end

endmodule


`endif /* SM_REGFILES_V */
