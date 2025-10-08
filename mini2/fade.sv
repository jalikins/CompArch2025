// Fade

module fade #(
    parameter INC_DEC_INTERVAL = 12000,     // CLK frequency is 12MHz, so 12,000 cycles is 1ms
    parameter INC_DEC_MAX = 167,            // Transition to next state after 167 increments / decrements, which is 0.167s because for every second we need about 6 transitions
    parameter PWM_INTERVAL = 1200,          // CLK frequency is 12MHz, so 1,200 cycles is 100us
    parameter INC_DEC_VAL = PWM_INTERVAL / INC_DEC_MAX
)(
    input logic clk, 
    output logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value,
    output logic [1:0] currentState,
    output logic pwm_state
);

    // Define state variable values
    localparam PWM_INC = 1'b0;
    localparam PWM_DEC = 1'b1;

    localparam [1:0] FADE_RED   = 2'b00;
    localparam [1:0] FADE_GREEN = 2'b01;
    localparam [1:0] FADE_BLUE  = 2'b10;

    // Declare state variables

    logic next_state;

    // Declare variables for timing state transitions
    logic [$clog2(INC_DEC_INTERVAL) - 1:0] count = 0;
    logic [$clog2(INC_DEC_MAX) - 1:0] inc_dec_count = 0;
    logic time_to_inc_dec = 1'b0;
    logic time_to_transition = 1'b0;

    initial begin
        pwm_value = 0;
        currentState = FADE_GREEN;
        pwm_state = PWM_INC;
    end
    // Register the next state of the FSM
    always_ff @(posedge time_to_transition) begin
        case (currentState)
                FADE_RED:   currentState <= FADE_GREEN;
                FADE_GREEN: currentState <= FADE_BLUE;
                FADE_BLUE:  currentState <= FADE_RED;
        endcase
        pwm_state <= next_state;
        
    end

    // Compute the next state of the FSM
    always_comb begin
        next_state = 1'bx;
        case (pwm_state)
            PWM_INC:
                next_state = PWM_DEC;
            PWM_DEC:
                next_state = PWM_INC;
        endcase
    end

    // Implement counter for incrementing / decrementing PWM value
    always_ff @(posedge clk) begin
        if (count == INC_DEC_INTERVAL - 1) begin
            count <= 0;
            time_to_inc_dec <= 1'b1;
        end
        else begin
            count <= count + 1;
            time_to_inc_dec <= 1'b0;
        end
    end

    // Increment / Decrement PWM value as appropriate given current state
    always_ff @(posedge time_to_inc_dec) begin
        case (pwm_state)
            PWM_INC:
                pwm_value <= pwm_value + INC_DEC_VAL;
            PWM_DEC:
                pwm_value <= pwm_value - INC_DEC_VAL;
        endcase
    end

    // Implement counter for timing state transitions
    always_ff @(posedge time_to_inc_dec) begin
        if (inc_dec_count == INC_DEC_MAX - 1) begin
            inc_dec_count <= 0;
            time_to_transition <= 1'b1;
        end
        else begin
            inc_dec_count <= inc_dec_count + 1;
            time_to_transition <= 1'b0;
        end
    end

endmodule


//     // Register the next state of the FSM
//     always_ff @(posedge clk) begin
//         if (time_to_transition) begin
//             pwm_state <= next_state;
//         end
//     end

//     // Register the next state of the Color FSM
//     // This machine transitions to the next color when a full fade cycle is complete.

//     // Compute the next state of the FSM
//     always_comb begin
//         next_state = 1'bx;
//         case (pwm_state)
//             PWM_INC:
//                 next_state = PWM_DEC;
//             PWM_DEC:
//                 next_state = PWM_INC;
//         endcase
//     end

//     // Implement counter for incrementing / decrementing PWM value
//     always_ff @(posedge clk) begin
//         if (count == INC_DEC_INTERVAL - 1) begin
//             count <= 0;
//             time_to_inc_dec <= 1'b1;
            
//         end
//         else begin
//             count <= count + 1;
//             time_to_inc_dec <= 1'b0;
//         end
//     end

//     // Increment / Decrement PWM value as appropriate given current state
//     always_ff @(posedge time_to_inc_dec) begin
//         case (pwm_state)
//             PWM_INC:
//                 pwm_value <= pwm_value + INC_DEC_VAL;
//             PWM_DEC:
//                 pwm_value <= pwm_value - INC_DEC_VAL;
//         endcase
//     end

//     // Implement counter for timing state transitions
//     always_ff @(posedge time_to_inc_dec) begin
//         if (inc_dec_count == INC_DEC_MAX - 1) begin
//             inc_dec_count <= 0;
//             time_to_transition <= 1'b1;
//             // case (currentState)
//             //     FADE_RED:   currentState <= FADE_BLUE;
//             //     FADE_GREEN: currentState <= FADE_RED;
//             //     FADE_BLUE:  currentState <= FADE_GREEN;
//             // endcase
//         end
//         else begin
//             inc_dec_count <= inc_dec_count + 1;
//             time_to_transition <= 1'b0;
//         end
//     end

// endmodule
