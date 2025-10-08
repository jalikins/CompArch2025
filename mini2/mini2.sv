//
// Module: rgb_controller
// Description: Top-level module to control a breathing RGB LED.
//              It instantiates three color faders, each with a different
//              phase, and three PWM generators to drive the RGB outputs.
//

`include "color_fader.sv"
`include "pwm_generator.sv"

module top (
    input   logic clk,
    output  logic RGB_R,
    output  logic RGB_G,
    output  logic RGB_B
);

    //-- Timing and Phase Configuration --//
    parameter PWM_PERIOD             = 1200; // Defines the resolution of the PWM signal
    localparam OFF_STATE_DURATION     = 800;  // Duration the LED stays fully off
    localparam RAMP_STATE_DURATION    = 400;  // Duration for the fade-in/fade-out ramp
    localparam ON_STATE_DURATION      = 800;  // Duration the LED stays fully on
    localparam FADE_UPDATE_RATE       = 5000; // Clock cycles between each fade step
    
    // Phase shifts for the color channels (120 and 240 degrees)
    localparam PHASE_OFFSET_120_DEG   = RAMP_STATE_DURATION * 2;
    localparam PHASE_OFFSET_240_DEG   = RAMP_STATE_DURATION * 4;

    //-- Internal Wires --//
    wire [10:0] duty_cycle_red;
    wire [10:0] duty_cycle_green;
    wire [10:0] duty_cycle_blue;

    wire pwm_out_red;
    wire pwm_out_green;
    wire pwm_out_blue;

    //-- Module Instantiations --//

    // Red Channel Fader (0° phase offset, but reversed for active-low)
    color_fader #(
        .PWM_MAX_VALUE          (PWM_PERIOD),
        .FADE_CLOCK_DIVIDER     (FADE_UPDATE_RATE),
        .DURATION_OFF_STATE     (OFF_STATE_DURATION),
        .DURATION_RAMP_STATE    (RAMP_STATE_DURATION),
        .DURATION_ON_STATE      (ON_STATE_DURATION),
        .STARTING_PHASE_OFFSET  (PHASE_OFFSET_240_DEG)
    ) fader_r (
        .clk                    (clk),
        .current_duty_cycle     (duty_cycle_red)
    );

    // Green Channel Fader (120° phase offset)
    color_fader #(
        .PWM_MAX_VALUE          (PWM_PERIOD),
        .FADE_CLOCK_DIVIDER     (FADE_UPDATE_RATE),
        .DURATION_OFF_STATE     (OFF_STATE_DURATION),
        .DURATION_RAMP_STATE    (RAMP_STATE_DURATION),
        .DURATION_ON_STATE      (ON_STATE_DURATION),
        .STARTING_PHASE_OFFSET  (PHASE_OFFSET_120_DEG)
    ) fader_g (
        .clk                    (clk),
        .current_duty_cycle     (duty_cycle_green)
    );

    // Blue Channel Fader (240° phase offset)
    color_fader #(
        .PWM_MAX_VALUE          (PWM_PERIOD),
        .FADE_CLOCK_DIVIDER     (FADE_UPDATE_RATE),
        .DURATION_OFF_STATE     (OFF_STATE_DURATION),
        .DURATION_RAMP_STATE    (RAMP_STATE_DURATION),
        .DURATION_ON_STATE      (ON_STATE_DURATION),
        .STARTING_PHASE_OFFSET  (0)
    ) fader_b (
        .clk                    (clk),
        .current_duty_cycle     (duty_cycle_blue)
    );

    // PWM Generators for each color channel
    pwm_generator #( .PWM_COUNTER_MAX(PWM_PERIOD) ) pwm_r (
        .clk                (clk),
        .target_duty_cycle  (duty_cycle_red),
        .pwm_output         (pwm_out_red)
    );

    pwm_generator #( .PWM_COUNTER_MAX(PWM_PERIOD) ) pwm_g (
        .clk                (clk),
        .target_duty_cycle  (duty_cycle_green),
        .pwm_output         (pwm_out_green)
    );

    pwm_generator #( .PWM_COUNTER_MAX(PWM_PERIOD) ) pwm_b (
        .clk                (clk),
        .target_duty_cycle  (duty_cycle_blue),
        .pwm_output         (pwm_out_blue)
    );

    //-- Output Assignments --//
    // Invert the PWM signals for active-low LEDs
    assign RGB_R = ~pwm_out_red;
    assign RGB_G = ~pwm_out_green;
    assign RGB_B = ~pwm_out_blue;

endmodule