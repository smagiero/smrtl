//========================================================================
// vc-mem-msgs : Memory Request/Response Messages
//========================================================================
// The memory request/response messages are used to interact with various
// memories. They are parameterized by the number of bits in the address,
// data, and opaque field.  To better reflect some of the properties of
// the RoCC communication scheme, these messages have included the address
// in the response fields.

`ifndef SM_MEM_MSGS_V
`define SM_MEM_MSGS_V

`include "vc-trace.v"

//========================================================================
// Memory Request Message
//========================================================================
// Memory request messages can either be for a read or write. Read
// requests include an opaque field, the address, and the number of bytes
// to read, while write requests include an opaque field, the address,
// the number of bytes to write, and the actual data to write.
//
// Message Format:
//
//    5b    p_opaque_nbits  p_addr_nbits       calc   p_data_nbits
//  +------+---------------+------------------+------+------------------+
//  | type | opaque        | addr             | len  | data             |
//  +------+---------------+------------------+------+------------------+
//
// The message type is parameterized by the number of bits in the opaque
// field, address field, and data field. Note that the size of the length
// field is caclulated from the number of bits in the data field, and
// that the length field is expressed in _bytes_. If the value of the
// length field is zero, then the read or write should be for the full
// width of the data field.
//
// For example, if the opaque field is 8 bits, the address is 40 bits and
// the data is also 64 bits, then the message format is as follows:
//
//  119 115 114         107 106              67 66  64 63               0
//  +------+---------------+------------------+------+------------------+
//  | type | opaque        | addr             | len  | data             |
//  +------+---------------+------------------+------+------------------+
//
// The length field is three bits. A length value of one means read or write
// a single byte, a length value of two means read or write two bytes, and
// so on. A length value of zero means read or write all four bytes. Note
// that not all memories will necessarily support any alignment and/or any
// value for the length field.
//
// The opaque field is reserved for use by a specific implementation. All
// memories should guarantee that every response includes the opaque
// field corresponding to the request that generated the response.

//------------------------------------------------------------------------
// Memory Request Message: Message fields ordered from right to left
//------------------------------------------------------------------------
// We use the following short names to make all of these preprocessor
// macros more succinct.

// Data field
// 64
`define SM_MEM_REQ_MSG_DATA_NBITS(o_,a_,d_)                             \
  d_
// 63
`define SM_MEM_REQ_MSG_DATA_MSB(o_,a_,d_)                               \
  ( `SM_MEM_REQ_MSG_DATA_NBITS(o_,a_,d_) - 1 )
// 63:0
`define SM_MEM_REQ_MSG_DATA_FIELD(o_,a_,d_)                             \
  (`SM_MEM_REQ_MSG_DATA_MSB(o_,a_,d_)):                                 \
  0

// Length field 
// 3
`define SM_MEM_REQ_MSG_LEN_NBITS(o_,a_,d_)                              \
  ($clog2(d_/8))
// 63+3=66
`define SM_MEM_REQ_MSG_LEN_MSB(o_,a_,d_)                                \
  (   `SM_MEM_REQ_MSG_DATA_MSB(o_,a_,d_)                                \
    + `SM_MEM_REQ_MSG_LEN_NBITS(o_,a_,d_) )
// 66:64
`define SM_MEM_REQ_MSG_LEN_FIELD(o_,a_,d_)                              \
  (`SM_MEM_REQ_MSG_LEN_MSB(o_,a_,d_)):                                  \
  (`SM_MEM_REQ_MSG_DATA_MSB(o_,a_,d_) + 1)

// Address field
// 40
`define SM_MEM_REQ_MSG_ADDR_NBITS(o_,a_,d_)                             \
  a_
// 66+40 = 106
`define SM_MEM_REQ_MSG_ADDR_MSB(o_,a_,d_)                               \
  (   `SM_MEM_REQ_MSG_LEN_MSB(o_,a_,d_)                                 \
    + `SM_MEM_REQ_MSG_ADDR_NBITS(o_,a_,d_) )

`define SM_MEM_REQ_MSG_ADDR_FIELD(o_,a_,d_)                             \
  (`SM_MEM_REQ_MSG_ADDR_MSB(o_,a_,d_)):                                 \
  (`SM_MEM_REQ_MSG_LEN_MSB(o_,a_,d_) + 1)

// Opaque field

`define SM_MEM_REQ_MSG_OPAQUE_NBITS(o_,a_,d_)                           \
  o_

`define SM_MEM_REQ_MSG_OPAQUE_MSB(o_,a_,d_)                             \
  (   `SM_MEM_REQ_MSG_ADDR_MSB(o_,a_,d_)                                \
    + `SM_MEM_REQ_MSG_OPAQUE_NBITS(o_,a_,d_) )

`define SM_MEM_REQ_MSG_OPAQUE_FIELD(o_,a_,d_)                           \
  (`SM_MEM_REQ_MSG_OPAQUE_MSB(o_,a_,d_)):                               \
  (`SM_MEM_REQ_MSG_ADDR_MSB(o_,a_,d_) + 1)

// Type field

`define SM_MEM_REQ_MSG_TYPE_NBITS(o_,a_,d_) 5
`define SM_MEM_REQ_MSG_TYPE_READ     5'd0
`define SM_MEM_REQ_MSG_TYPE_WRITE    5'd1

// write no-refill
`define SM_MEM_REQ_MSG_TYPE_WRITE_INIT 5'd2
`define SM_MEM_REQ_MSG_TYPE_AMO_ADD    5'd3
`define SM_MEM_REQ_MSG_TYPE_AMO_AND    5'd4
`define SM_MEM_REQ_MSG_TYPE_AMO_OR     5'd5
`define SM_MEM_REQ_MSG_TYPE            5'dx

`define SM_MEM_REQ_MSG_TYPE_MSB(o_,a_,d_)                               \
  (   `SM_MEM_REQ_MSG_OPAQUE_MSB(o_,a_,d_)                              \
    + `SM_MEM_REQ_MSG_TYPE_NBITS(o_,a_,d_) )

`define SM_MEM_REQ_MSG_TYPE_FIELD(o_,a_,d_)                             \
  (`SM_MEM_REQ_MSG_TYPE_MSB(o_,a_,d_)):                                 \
  (`SM_MEM_REQ_MSG_OPAQUE_MSB(o_,a_,d_) + 1)

// Total size of message

`define SM_MEM_REQ_MSG_NBITS(o_,a_,d_)                                  \
  (   `SM_MEM_REQ_MSG_TYPE_NBITS(o_,a_,d_)                              \
    + `SM_MEM_REQ_MSG_OPAQUE_NBITS(o_,a_,d_)                            \
    + `SM_MEM_REQ_MSG_ADDR_NBITS(o_,a_,d_)                              \
    + `SM_MEM_REQ_MSG_LEN_NBITS(o_,a_,d_)                               \
    + `SM_MEM_REQ_MSG_DATA_NBITS(o_,a_,d_) )

//------------------------------------------------------------------------
// Memory Request Message: Pack message
//------------------------------------------------------------------------

module sm_MemReqMsgPack
#(
  parameter p_opaque_nbits = 8,
  parameter p_addr_nbits   = 32,
  parameter p_data_nbits   = 32,

  // Shorter names for message type, not to be set from outside the module
  parameter o = p_opaque_nbits,
  parameter a = p_addr_nbits,
  parameter d = p_data_nbits
)(
  // Input message

  input  [`SM_MEM_REQ_MSG_TYPE_NBITS(o,a,d)-1:0]   type_,
  input  [`SM_MEM_REQ_MSG_OPAQUE_NBITS(o,a,d)-1:0] opaque,
  input  [`SM_MEM_REQ_MSG_ADDR_NBITS(o,a,d)-1:0]   addr,
  input  [`SM_MEM_REQ_MSG_LEN_NBITS(o,a,d)-1:0]    len,
  input  [`SM_MEM_REQ_MSG_DATA_NBITS(o,a,d)-1:0]   data,

  // Output bits

  output [`SM_MEM_REQ_MSG_NBITS(o,a,d)-1:0]        msg
);

  assign msg[`SM_MEM_REQ_MSG_TYPE_FIELD(o,a,d)]   = type_;
  assign msg[`SM_MEM_REQ_MSG_OPAQUE_FIELD(o,a,d)] = opaque;
  assign msg[`SM_MEM_REQ_MSG_ADDR_FIELD(o,a,d)]   = addr;
  assign msg[`SM_MEM_REQ_MSG_LEN_FIELD(o,a,d)]    = len;
  assign msg[`SM_MEM_REQ_MSG_DATA_FIELD(o,a,d)]   = data;

endmodule

//------------------------------------------------------------------------
// Memory Request Message: Unpack message
//------------------------------------------------------------------------

module sm_MemReqMsgUnpack
#(
  parameter p_opaque_nbits = 8,
  parameter p_addr_nbits   = 32,
  parameter p_data_nbits   = 32,

  // Shorter names for message type, not to be set from outside the module
  parameter o = p_opaque_nbits,
  parameter a = p_addr_nbits,
  parameter d = p_data_nbits
)(

  // Input bits

  input [`SM_MEM_REQ_MSG_NBITS(o,a,d)-1:0]         msg,

  // Output message

  output [`SM_MEM_REQ_MSG_TYPE_NBITS(o,a,d)-1:0]   type_,
  output [`SM_MEM_REQ_MSG_OPAQUE_NBITS(o,a,d)-1:0] opaque,
  output [`SM_MEM_REQ_MSG_ADDR_NBITS(o,a,d)-1:0]   addr,
  output [`SM_MEM_REQ_MSG_LEN_NBITS(o,a,d)-1:0]    len,
  output [`SM_MEM_REQ_MSG_DATA_NBITS(o,a,d)-1:0]   data
);

  assign type_  = msg[`SM_MEM_REQ_MSG_TYPE_FIELD(o,a,d)];
  assign opaque = msg[`SM_MEM_REQ_MSG_OPAQUE_FIELD(o,a,d)];
  assign addr   = msg[`SM_MEM_REQ_MSG_ADDR_FIELD(o,a,d)];
  assign len    = msg[`SM_MEM_REQ_MSG_LEN_FIELD(o,a,d)];
  assign data   = msg[`SM_MEM_REQ_MSG_DATA_FIELD(o,a,d)];

endmodule

//------------------------------------------------------------------------
// Memory Request Message: Trace message
//------------------------------------------------------------------------

module sm_MemReqMsgTrace
#(
  parameter p_opaque_nbits = 8,
  parameter p_addr_nbits   = 32,
  parameter p_data_nbits   = 32,

  // Shorter names for message type, not to be set from outside the module
  parameter o = p_opaque_nbits,
  parameter a = p_addr_nbits,
  parameter d = p_data_nbits
)(
  input                                    clk,
  input                                    reset,
  input                                    val,
  input                                    rdy,
  input [`SM_MEM_REQ_MSG_NBITS(o,a,d)-1:0] msg
);

  // Extract fields

  wire [`SM_MEM_REQ_MSG_TYPE_NBITS(o,a,d)-1:0]   type_;
  wire [`SM_MEM_REQ_MSG_OPAQUE_NBITS(o,a,d)-1:0] opaque;
  wire [`SM_MEM_REQ_MSG_ADDR_NBITS(o,a,d)-1:0]   addr;
  wire [`SM_MEM_REQ_MSG_LEN_NBITS(o,a,d)-1:0]    len;
  wire [`SM_MEM_REQ_MSG_DATA_NBITS(o,a,d)-1:0]   data;

  sm_MemReqMsgUnpack#(o,a,d) mem_req_msg_unpack
  (
    .msg    (msg),
    .type_  (type_),
    .opaque (opaque),
    .addr   (addr),
    .len    (len),
    .data   (data)
  );

  // Short names

  localparam c_msg_nbits  = `SM_MEM_REQ_MSG_NBITS(o,a,d);
  localparam c_read       = `SM_MEM_REQ_MSG_TYPE_READ;
  localparam c_write      = `SM_MEM_REQ_MSG_TYPE_WRITE;
  localparam c_write_init = `SM_MEM_REQ_MSG_TYPE_WRITE_INIT;

  // Line tracing

  reg [8*2-1:0] type_str;
  reg [`VC_TRACE_NBITS-1:0] str;
  `VC_TRACE_BEGIN
  begin

    // Convert type into a string

    if ( type_ === {`SM_MEM_REQ_MSG_TYPE_NBITS(o,a,d){1'bx}} )
      type_str = "xxxx";
    else begin
      case ( type_ )
        c_read     : type_str = "rd";
        c_write    : type_str = "wr";
        c_write_init : type_str = "wn";
        default    : type_str = "??";
      endcase
    end

    // Put together the trace string

    if ( vc_trace.level == 1 ) begin
      $sformat( str, "%s", type_str );
    end
    else if ( vc_trace.level == 2 ) begin
      $sformat( str, "%s:%x", type_str, addr );
    end
    else if ( vc_trace.level == 3 ) begin
      if ( type_ == c_read ) begin
        $sformat( str, "%s:%x:%x %s", type_str, opaque, addr,
                  {`VC_TRACE_NBITS_TO_NCHARS(d){" "}} );
      end
      else
        $sformat( str, "%s:%x:%x:%x", type_str, opaque, addr, data );
    end

    // Trace with val/rdy signals

    vc_trace.append_val_rdy_str( trace_str, val, rdy, str );

  end
  `VC_TRACE_END

endmodule

//========================================================================
// Memory Response Message (an "X" modification at one time)
//========================================================================
// Memory request messages can either be for a read or write. Read
// responses include an opaque field, the address, the actual data, and the 
// number of bytes, while write responses currently include just the opaque 
// field.
//
// Message Format:
//
//    5b    p_opaque_nbits  p_addr_nbits       calc   p_data_nbits
//  +------+---------------+------------------+------+------------------+
//  | type | opaque        | addr             | len  | data             |
//  +------+---------------+------------------+------+------------------+
//
// The message type is parameterized by the number of bits in the opaque
// field, address field, and data field. Note that the size of the length 
// field is caclulated from the number of bits in the data field, and 
// that the length field is expressed in _bytes_. If the value of the 
// length field is zero, then the read or write should be for the full 
// width of the data field.
//
// For example, if the opaque field is 8 bits, the address is 32 bits and 
// the data is 32 bits, then the message format is as follows:
//
//  119 115 114         107 106              67 66  64 63               0
//  +------+---------------+------------------+------+------------------+
//  | type | opaque        | addr             | len  | data             |
//  +------+---------------+------------------+------+------------------+
//
// The length field is two bits. A length value of one means one byte was
// read, a length value of two means two bytes were read, and so on. A
// length value of zero means all four bytes were read. Note that not all
// memories will necessarily support any alignment and/or any value for
// the length field.
//
// The opaque field is reserved for use by a specific implementation. All
// memories should guarantee that every response includes the opaque
// field corresponding to the request that generated the response.

//------------------------------------------------------------------------
// Memory Response Message: Message fields ordered from right to left
//------------------------------------------------------------------------
// We use the following short names to make all of these preprocessor
// macros more succinct.

// Data field

`define SM_MEM_RESP_MSG_DATA_NBITS(o_,d_)                               \
  d_

`define SM_MEM_RESP_MSG_DATA_MSB(o_,d_)                                 \
  ( `SM_MEM_RESP_MSG_DATA_NBITS(o_,d_) - 1 )

`define SM_MEM_RESP_MSG_DATA_FIELD(o_,d_)                               \
  (`SM_MEM_RESP_MSG_DATA_MSB(o_,d_)):                                   \
  0

// Length field

`define SM_MEM_RESP_MSG_LEN_NBITS(o_,d_)                                \
  ($clog2(d_/8))

`define SM_MEM_RESP_MSG_LEN_MSB(o_,d_)                                  \
  (   `SM_MEM_RESP_MSG_DATA_MSB(o_,d_)                                  \
    + `SM_MEM_RESP_MSG_LEN_NBITS(o_,d_) )

`define SM_MEM_RESP_MSG_LEN_FIELD(o_,d_)                                \
  (`SM_MEM_RESP_MSG_LEN_MSB(o_,d_)):                                    \
  (`SM_MEM_RESP_MSG_DATA_MSB(o_,d_) + 1)

// XXXXXXX Address field XXXXXXX
`define SM_MEM_RESP_MSG_ADDR_NBITS(o_,a_,d_)                           \
  a_

`define SM_MEM_RESP_MSG_ADDR_MSB(o_,a_,d_)                             \
  (   `SM_MEM_RESP_MSG_LEN_MSB(o_,d_)                                   \
    + `SM_MEM_RESP_MSG_ADDR_NBITS(o_,a_,d_) )

`define SM_MEM_RESP_MSG_ADDR_FIELD(o_,a_,d_)                           \
  (`SM_MEM_RESP_MSG_ADDR_MSB(o_,a_,d_)):                               \
  (`SM_MEM_RESP_MSG_LEN_MSB(o_,d_) + 1)

// Opaque field

`define SM_MEM_RESP_MSG_OPAQUE_NBITS(o_,d_)                             \
  o_

// `define SM_MEM_RESP_MSG_OPAQUE_MSB(o_,d_)                               \
//   (   `SM_MEM_RESP_MSG_LEN_MSB(o_,d_)                                   \
//     + `SM_MEM_RESP_MSG_OPAQUE_NBITS(o_,d_) )
// XXXXXXX Opaque MSB XXXXXXX
`define SM_MEM_RESP_MSG_OPAQUE_MSB(o_,a_,d_)                           \
  (   `SM_MEM_RESP_MSG_ADDR_MSB(o_,a_,d_)                              \
    + `SM_MEM_RESP_MSG_OPAQUE_NBITS(o_,d_) )

// `define SM_MEM_RESP_MSG_OPAQUE_FIELD(o_,d_)                             \
//   (`SM_MEM_RESP_MSG_OPAQUE_MSB(o_,d_)):                                 \
//   (`SM_MEM_RESP_MSG_LEN_MSB(o_,d_) + 1)
// XXXXXXX Opaque FIELD XXXXXXX
`define SM_MEM_RESP_MSG_OPAQUE_FIELD(o_,a_,d_)                         \
  (`SM_MEM_RESP_MSG_OPAQUE_MSB(o_,a_,d_)):                             \
  (`SM_MEM_RESP_MSG_ADDR_MSB(o_,a_,d_) + 1)

// Type field

`define SM_MEM_RESP_MSG_TYPE_NBITS(o_,d_) 5
`define SM_MEM_RESP_MSG_TYPE_READ     5'd0
`define SM_MEM_RESP_MSG_TYPE_WRITE    5'd1

// write no-refill
`define SM_MEM_RESP_MSG_TYPE_WRITE_INIT 2'd2
`define SM_MEM_RESP_MSG_TYPE_AMO_ADD    5'd3
`define SM_MEM_RESP_MSG_TYPE_AMO_AND    5'd4
`define SM_MEM_RESP_MSG_TYPE_AMO_OR     5'd5
`define SM_MEM_RESP_MSG_TYPE            5'dx

// `define SM_MEM_RESP_MSG_TYPE_MSB(o_,d_)                                 \
//   (   `SM_MEM_RESP_MSG_OPAQUE_MSB(o_,d_)                                \
//     + `SM_MEM_RESP_MSG_TYPE_NBITS(o_,d_) )
// XXXXXXX Type MSB XXXXXXX
`define SM_MEM_RESP_MSG_TYPE_MSB(o_,a_,d_)                             \
  (   `SM_MEM_RESP_MSG_OPAQUE_MSB(o_,a_,d_)                            \
    + `SM_MEM_RESP_MSG_TYPE_NBITS(o_,d_) )

// `define SM_MEM_RESP_MSG_TYPE_FIELD(o_,d_)                               \
//   (`SM_MEM_RESP_MSG_TYPE_MSB(o_,d_)):                                   \
//   (`SM_MEM_RESP_MSG_OPAQUE_MSB(o_,d_) + 1)
// XXXXXXX Type Field XXXXXXX
`define SM_MEM_RESP_MSG_TYPE_FIELD(o_,a_,d_)                           \
  (`SM_MEM_RESP_MSG_TYPE_MSB(o_,a_,d_)):                               \
  (`SM_MEM_RESP_MSG_OPAQUE_MSB(o_,a_,d_) + 1)


// Total size of message
// `define SM_MEM_RESP_MSG_NBITS(o_,d_)                                    \
//   (   `SM_MEM_RESP_MSG_TYPE_NBITS(o_,d_)                                \
//     + `SM_MEM_RESP_MSG_OPAQUE_NBITS(o_,d_)                              \
//     + `SM_MEM_RESP_MSG_LEN_NBITS(o_,d_)                                 \
//     + `SM_MEM_RESP_MSG_DATA_NBITS(o_,d_) )

// XXXXXXX Total size of message XXXXXXX
`define SM_MEM_RESP_MSG_NBITS(o_,a_,d_)                                \
  (   `SM_MEM_RESP_MSG_TYPE_NBITS(o_,d_)                                \
    + `SM_MEM_RESP_MSG_OPAQUE_NBITS(o_,d_)                              \
    + `SM_MEM_RESP_MSG_ADDR_NBITS(o_,a_,d_)                            \
    + `SM_MEM_RESP_MSG_LEN_NBITS(o_,d_)                                 \
    + `SM_MEM_RESP_MSG_DATA_NBITS(o_,d_) )

//------------------------------------------------------------------------
// Memory Response Message: Pack message
//------------------------------------------------------------------------

// module sm_MemRespMsgPack
// #(
//   parameter p_opaque_nbits = 8,
//   parameter p_data_nbits   = 32,

//   // Shorter names for message type, not to be set from outside the module
//   parameter o = p_opaque_nbits,
//   parameter d = p_data_nbits
// )(
//   // Input message

//   input  [`SM_MEM_RESP_MSG_TYPE_NBITS(o,d)-1:0]   type_,
//   input  [`SM_MEM_RESP_MSG_OPAQUE_NBITS(o,d)-1:0] opaque,
//   input  [`SM_MEM_RESP_MSG_LEN_NBITS(o,d)-1:0]    len,
//   input  [`SM_MEM_RESP_MSG_DATA_NBITS(o,d)-1:0]   data,

//   // Output bits

//   output [`SM_MEM_RESP_MSG_NBITS(o,d)-1:0]        msg
// );

//   assign msg[`SM_MEM_RESP_MSG_TYPE_FIELD(o,d)]   = type_;
//   assign msg[`SM_MEM_RESP_MSG_OPAQUE_FIELD(o,d)] = opaque;
//   assign msg[`SM_MEM_RESP_MSG_LEN_FIELD(o,d)]    = len;
//   assign msg[`SM_MEM_RESP_MSG_DATA_FIELD(o,d)]   = data;

// endmodule

// XXXXXXX Mem Resp Message Pack XXXXXXX
module sm_MemRespMsgPack
#(
  parameter p_opaque_nbits = 8,
  parameter p_addr_nbits   = 32,
  parameter p_data_nbits   = 32,

  // Shorter names for message type, not to be set from outside the module
  parameter o = p_opaque_nbits,
  parameter a = p_addr_nbits,
  parameter d = p_data_nbits
)(
  // Input message

  input  [`SM_MEM_RESP_MSG_TYPE_NBITS(o,d)-1:0]    type_,
  input  [`SM_MEM_RESP_MSG_OPAQUE_NBITS(o,d)-1:0]  opaque,
  input  [`SM_MEM_RESP_MSG_ADDR_NBITS(o,a,d)-1:0] addr,
  input  [`SM_MEM_RESP_MSG_LEN_NBITS(o,d)-1:0]     len,
  input  [`SM_MEM_RESP_MSG_DATA_NBITS(o,d)-1:0]    data,

  // Output bits

  output [`SM_MEM_RESP_MSG_NBITS(o,a,d)-1:0]      msg
);

  assign msg[`SM_MEM_RESP_MSG_TYPE_FIELD(o,a,d)]   = type_;
  assign msg[`SM_MEM_RESP_MSG_OPAQUE_FIELD(o,a,d)] = opaque;
  assign msg[`SM_MEM_RESP_MSG_ADDR_FIELD(o,a,d)]   = addr;
  assign msg[`SM_MEM_RESP_MSG_LEN_FIELD(o,d)]       = len;
  assign msg[`SM_MEM_RESP_MSG_DATA_FIELD(o,d)]      = data;

endmodule


//------------------------------------------------------------------------
// Memory Response Message: Unpack message
//------------------------------------------------------------------------

module sm_MemRespMsgUnpack
#(
  parameter p_opaque_nbits = 8,
  parameter p_addr_nbits   = 32,
  parameter p_data_nbits   = 32,

  // Shorter names for message type, not to be set from outside the module
  parameter o = p_opaque_nbits,
  parameter a = p_addr_nbits,
  parameter d = p_data_nbits
)(

  // Input bits

  input [`SM_MEM_RESP_MSG_NBITS(o,a,d)-1:0]         msg,

  // Output message

  output [`SM_MEM_RESP_MSG_TYPE_NBITS(o,d)-1:0]    type_,
  output [`SM_MEM_RESP_MSG_OPAQUE_NBITS(o,d)-1:0]  opaque,
  output [`SM_MEM_RESP_MSG_ADDR_NBITS(o,a,d)-1:0] addr,
  output [`SM_MEM_RESP_MSG_LEN_NBITS(o,d)-1:0]     len,
  output [`SM_MEM_RESP_MSG_DATA_NBITS(o,d)-1:0]    data
);

  assign type_   = msg[`SM_MEM_RESP_MSG_TYPE_FIELD(o,a,d)];
  assign opaque  = msg[`SM_MEM_RESP_MSG_OPAQUE_FIELD(o,a,d)];
  assign addr    = msg[`SM_MEM_RESP_MSG_ADDR_FIELD(o,a,d)];
  assign len     = msg[`SM_MEM_RESP_MSG_LEN_FIELD(o,d)];
  assign data    = msg[`SM_MEM_RESP_MSG_DATA_FIELD(o,d)];

endmodule

//------------------------------------------------------------------------
// Memory Response Message: Trace message
//------------------------------------------------------------------------

module sm_MemRespMsgTrace
#(
  parameter p_opaque_nbits = 8,
  parameter p_addr_nbits   = 32,
  parameter p_data_nbits   = 32,

  // Shorter names for message type, not to be set from outside the module
  parameter o = p_opaque_nbits,
  parameter a = p_addr_nbits,
  parameter d = p_data_nbits
)(
  input                                      clk,
  input                                      reset,
  input                                      val,
  input                                      rdy,
  input [`SM_MEM_RESP_MSG_NBITS(o,a,d)-1:0] msg
);

  // Extract fields

  wire [`SM_MEM_RESP_MSG_TYPE_NBITS(o,d)-1:0]    type_;
  wire [`SM_MEM_RESP_MSG_OPAQUE_NBITS(o,d)-1:0]  opaque;
  wire [`SM_MEM_RESP_MSG_ADDR_NBITS(o,a,d)-1:0] addr;
  wire [`SM_MEM_RESP_MSG_LEN_NBITS(o,d)-1:0]     len;
  wire [`SM_MEM_RESP_MSG_DATA_NBITS(o,d)-1:0]    data;

  sm_MemRespMsgUnpack#(o,a,d) mem_req_msg_unpack
  (
    .msg     (msg),
    .type_   (type_),
    .opaque  (opaque),
    .addr    (addr),
    .len     (len),
    .data    (data)
  );

  // Short names

  localparam c_msg_nbits  = `SM_MEM_RESP_MSG_NBITS(o,a,d);
  localparam c_read       = `SM_MEM_RESP_MSG_TYPE_READ;
  localparam c_write      = `SM_MEM_RESP_MSG_TYPE_WRITE;
  localparam c_write_init = `SM_MEM_RESP_MSG_TYPE_WRITE_INIT;

  // Line tracing

  reg [8*2-1:0] type_str;
  reg [`VC_TRACE_NBITS-1:0] str;
  `VC_TRACE_BEGIN
  begin

    // Convert type into a string

    if ( type_ === {`SM_MEM_RESP_MSG_TYPE_NBITS(o,d){1'bx}} )
      type_str = "xxxx";
    else begin
      case ( type_ )
        c_read     : type_str = "rd";
        c_write    : type_str = "wr";
        c_write_init : type_str = "wn";
        default    : type_str = "??";
      endcase
    end

    // Put together the trace string

    if ( (vc_trace.level == 1) || (vc_trace.level == 2) ) begin
      $sformat( str, "%s", type_str );
    end
    else if ( vc_trace.level == 3 ) begin
      if ( type_ == c_write || type_ == c_write_init ) begin
        $sformat( str, "%s:%x %s", type_str, opaque,
                  {`VC_TRACE_NBITS_TO_NCHARS(d){" "}} );
      end
      else
        $sformat( str, "%s:%x:%x", type_str, opaque, data );
    end

    // Trace with val/rdy signals

    vc_trace.append_val_rdy_str( trace_str, val, rdy, str );

  end
  `VC_TRACE_END

endmodule

`endif /* SM_MEM_MSGS_V */

