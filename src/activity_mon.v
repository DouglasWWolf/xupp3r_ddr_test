//=============================================================================
//                ------->  Revision History  <------
//=============================================================================
//
//   Date     Who   Ver  Changes
//=============================================================================
// 08-Jun-24  DWW     1  Initial creation
//=============================================================================

/*
    This module detects and reports activity on a TVALID line
*/

module activity_mon # (parameter DW=512, FREQ_HZ = 332265625)
(
    input clk, resetn,
    
    (* X_INTERFACE_MODE = "monitor" *)
    input         stream_tvalid,
    input[DW-1:0] stream_tdata,    

    // This will be high when activity on tvalid is detected
    output  active
);

// A countdown timer
reg[31:0] timer;

// The state of our state machine
reg       fsm_state;

// The stream is "active" any time we're in state 1
assign    active = (fsm_state == 1);

// This is how long we wait for further activity before giving up
localparam TIMEOUT_PERIOD = FREQ_HZ;


//=============================================================================
// This state machine examines the 'stream_tvalid' input and uses it to 
// determine whether the stream is "active"
//=============================================================================
always @(posedge clk) begin

    // A countdown timer
    if (timer) timer <= timer - 1;

    if (resetn == 0) begin
        fsm_state <= 0;
    end else case(fsm_state)

        // Wait for 'stream_tvalid' to go high
        0:  if (stream_tvalid) begin
                timer     <= TIMEOUT_PERIOD;
                fsm_state <= 1;
            end

        // If 'stream_tvalid' is high, restart the timer.
        // If it's not, and the timer is expired, then
        // the stream is no longer active
        1:  if (stream_tvalid)
                timer <= TIMEOUT_PERIOD;
            else if (timer == 0)
                fsm_state <= 0;

    endcase
end
//=============================================================================


endmodule
