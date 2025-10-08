//
// Module: pwm_generator
// Description: Creates a Pulse-Width Modulated (PWM) signal based on a
//              target duty cycle value. It uses a free-running counter.
//

module pwm_generator #(
    parameter PWM_COUNTER_MAX = 1200
)(
    input  logic clk,
    input  logic [$clog2(PWM_COUNTER_MAX)-1:0] target_duty_cycle,
    output logic pwm_output
);

    // Free-running counter for PWM generation
    logic [$clog2(PWM_COUNTER_MAX)-1:0] pwm_tick_counter = 0;

    // Counter logic
    always_ff @(posedge clk) begin
        if (pwm_tick_counter == PWM_COUNTER_MAX - 1) begin
            pwm_tick_counter <= 0;
        end else begin
            pwm_tick_counter <= pwm_tick_counter + 1;
        end
    end

    // Combinational logic to generate the PWM output
    // The output is high as long as the counter is less than the target duty cycle.
    assign pwm_output = (pwm_tick_counter < target_duty_cycle);

endmodule