module typedef_enum_fsm (
  input  logic       clk,
  input  logic       rst_n,
  input  logic       start,
  input  logic       ack,
  output logic       busy,
  output logic       done,
  output logic [1:0] state_bits
);
  typedef enum logic [1:0] {
    IDLE = 2'b00,
    RUN  = 2'b01,
    DONE = 2'b10
  } state_t;

  state_t state;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= IDLE;
    end else begin
      case (state)
        IDLE: state <= start ? RUN : IDLE;
        RUN:  state <= ack ? DONE : RUN;
        DONE: state <= ack ? IDLE : DONE;
        default: state <= IDLE;
      endcase
    end
  end

  assign busy = (state == RUN);
  assign done = (state == DONE);
  assign state_bits = state;
endmodule
