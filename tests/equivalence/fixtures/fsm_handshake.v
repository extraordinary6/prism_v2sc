// Small Moore FSM: IDLE -> BUSY -> DONE -> IDLE.
// Strict one-signal-per-always-block style.
module fsm_handshake (
  input  wire clk,
  input  wire rst_n,
  input  wire start,
  input  wire data_valid,
  output reg  ready,
  output reg  done
);
  localparam [1:0] IDLE = 2'b00;
  localparam [1:0] BUSY = 2'b01;
  localparam [1:0] DONE = 2'b10;

  reg [1:0] state;
  reg [1:0] next_state;

  // Sequential: state register.
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) state <= IDLE;
    else        state <= next_state;
  end

  // Combinational: next-state.
  always @(*) begin
    case (state)
      IDLE:    next_state = start      ? BUSY : IDLE;
      BUSY:    next_state = data_valid ? DONE : BUSY;
      DONE:    next_state = IDLE;
      default: next_state = IDLE;
    endcase
  end

  // Combinational: 'ready' output (one always block).
  always @(*) begin
    ready = (state == IDLE);
  end

  // Combinational: 'done' output (one always block).
  always @(*) begin
    done = (state == DONE);
  end
endmodule
