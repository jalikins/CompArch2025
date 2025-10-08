//
// Module: color_fader
// Description: Generates a smoothly changing PWM duty cycle value
//              to create a "breathing" or "fading" effect. It cycles
//              through off, fade-up, on, and fade-down states.
//

module color_fader #(
    parameter PWM_MAX_VALUE         = 1200,
    parameter FADE_CLOCK_DIVIDER    = 5000,
    parameter DURATION_OFF_STATE    = 800,
    parameter DURATION_RAMP_STATE   = 400,
    parameter DURATION_ON_STATE     = 800,
    parameter STARTING_PHASE_OFFSET = 0
)(
    input   logic           clk,
    output  reg  [10:0]     current_duty_cycle
);

    //-- State Machine Definition --//
    localparam [1:0] STATE_OFF         = 2'b00;
    localparam [1:0] STATE_FADING_UP   = 2'b01;
    localparam [1:0] STATE_ON          = 2'b10;
    localparam [1:0] STATE_FADING_DOWN = 2'b11;

    //-- Internal Registers --//
    reg [1:0]  fsm_state;               // Holds the current state of the FSM
    reg [31:0] tick_prescaler;          // Slows down the state machine updates
    reg [31:0] state_progression_timer; // Tracks progress within the overall cycle
    reg [10:0] fade_step_size;          // Amount to inc/dec duty cycle per update

    //-- Total cycle duration for the state progression timer --//
    localparam CYCLE_TOTAL_DURATION = DURATION_OFF_STATE + DURATION_RAMP_STATE + DURATION_ON_STATE + DURATION_RAMP_STATE;
    
    //-- Initialization --//
    initial begin
        current_duty_cycle      = 0;
        fsm_state               = STATE_OFF;
        tick_prescaler          = 0;
        state_progression_timer = STARTING_PHASE_OFFSET;
        fade_step_size          = PWM_MAX_VALUE / DURATION_RAMP_STATE;
    end

    //-- Main Sequential Logic --//
    always @(posedge clk) begin
        // Use a prescaler to control the speed of the fading effect
        if (tick_prescaler >= FADE_CLOCK_DIVIDER - 1) begin
            tick_prescaler <= 0;

            // Increment the state timer to progress through the overall cycle
            if (state_progression_timer >= CYCLE_TOTAL_DURATION - 1) begin
                state_progression_timer <= 0;
            end else begin
                state_progression_timer <= state_progression_timer + 1;
            end

            // State Transition and Duty Cycle Logic
            case (fsm_state)
                STATE_OFF: begin
                    if (state_progression_timer >= DURATION_OFF_STATE) begin
                        fsm_state <= STATE_FADING_UP;
                    end
                end

                STATE_FADING_UP: begin
                    if (current_duty_cycle < PWM_MAX_VALUE - fade_step_size) begin
                        current_duty_cycle <= current_duty_cycle + fade_step_size;
                    end else begin
                        current_duty_cycle <= PWM_MAX_VALUE; // Latch to max value
                        fsm_state          <= STATE_ON;
                    end
                end

                STATE_ON: begin
                    if (state_progression_timer >= DURATION_OFF_STATE + DURATION_RAMP_STATE + DURATION_ON_STATE) begin
                        fsm_state <= STATE_FADING_DOWN;
                    end
                end

                STATE_FADING_DOWN: begin
                    if (current_duty_cycle > fade_step_size) begin
                        current_duty_cycle <= current_duty_cycle - fade_step_size;
                    end else begin
                        current_duty_cycle <= 0; // Latch to min value
                        fsm_state          <= STATE_OFF;
                    end
                end
            endcase
            
        end else begin
            tick_prescaler <= tick_prescaler + 1;
        end
    end

endmodule