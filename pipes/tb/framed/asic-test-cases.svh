//========================================================================
// PIPES Framed Test Cases pipes/tb/framed/asic-test-cases.svh
//========================================================================
// Sebastian Claudiusz Magierowski Apr 18 2026

task framed_vectors_basic;
begin
  init_ctrl_src( 32'h0000_0000 ); // start word
  init_ctrl_src( 32'h0000_0004 ); // number of framed beats
  init_ctrl_snk( 32'h0000_0001 ); // done word

  // Source beats: { first, last, data }
  init_data_src( 66'h2_0000_0000_0000_0011 ); // first beat of a 3-beat frame
  init_data_src( 66'h0_0000_0000_0000_0022 ); // middle beat
  init_data_src( 66'h1_0000_0000_0000_0033 ); // last beat
  init_data_src( 66'h3_0000_0000_0000_0044 ); // single-beat frame

  // Expected sink beats for a 2-stage pipe: data + 2, framing unchanged
  init_data_snk( 66'h2_0000_0000_0000_0013 );
  init_data_snk( 66'h0_0000_0000_0000_0024 );
  init_data_snk( 66'h1_0000_0000_0000_0035 );
  init_data_snk( 66'h3_0000_0000_0000_0046 );
end
endtask

`VC_TEST_CASE_BEGIN( 1, "framed pipe, no random delays" )
begin
  clear_streams();
  init_rand_delays( 0, 0, 0, 0 );
  framed_vectors_basic();
  run_test();
end
`VC_TEST_CASE_END

`VC_TEST_CASE_BEGIN( 2, "framed pipe, control path random delays" )
begin
  clear_streams();
  init_rand_delays( 4, 4, 0, 0 );
  framed_vectors_basic();
  run_test();
end
`VC_TEST_CASE_END

`VC_TEST_CASE_BEGIN( 3, "framed pipe, data path random delays" )
begin
  clear_streams();
  init_rand_delays( 0, 0, 4, 4 );
  framed_vectors_basic();
  run_test();
end
`VC_TEST_CASE_END

`VC_TEST_CASE_BEGIN( 4, "framed pipe, all paths random delays" )
begin
  clear_streams();
  init_rand_delays( 4, 4, 4, 4 );
  framed_vectors_basic();
  run_test();
end
`VC_TEST_CASE_END
