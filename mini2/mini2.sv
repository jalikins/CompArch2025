`include "fade.sv"
`include "pwm.sv"

module top #(
    parameter PWM_INTERVAL = 1200       // CLK frequency is 12MHz, so 1,200 cycles is 100us
)(
    input  logic clk,       // 12MHz clock input
    output logic RGB_R,
    output logic RGB_G,
    output logic RGB_B
);

    logic [$clog2(PWM_INTERVAL) - 1:0] pwm_value;
    localparam [1:0] FADE_RED   = 2'b00;
    localparam [1:0] FADE_GREEN = 2'b01;
    localparam [1:0] FADE_BLUE  = 2'b10;


    logic [1:0] currentState; // Green fades first because we start with Red on
    logic [2:0] prev_LEDs = 3'b011; // Start with RED on
    logic [2:0] current_LEDs; // Declaration of current_LEDs


    logic pwm_out;

    fade #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u1 (
        .clk            (clk),
        .pwm_value      (pwm_value),
        .currentState (currentState),
        .pwm_state (pwm_state)
    );

    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u2 (
        .clk            (clk),
        .pwm_value      (pwm_value),
        .pwm_out        (pwm_out)
    );

    always_comb begin
        // Default to turning all LEDs off (assign '1' for active-low)
        // All LEDs off
        current_LEDs = 3'bxxx;
        case (currentState) // All off by default
            FADE_RED: begin
                // Connect the PWM signal to the RED LED.
                // The other LEDs remain off because of the default assignment above.
                if (pwm_state) begin // AND condition inside a specific case
                    current_LEDs[0] = ~pwm_out;
                    current_LEDs[1] = 1;
                    current_LEDs[2] = 0;
                    end else begin
                    current_LEDs[0] = ~pwm_out;
                    current_LEDs[1] = 0;
                    current_LEDs[2] = 1;
                end

            end

            FADE_GREEN: begin
                // Connect the PWM signal to the GREEN LED.
                if (pwm_state) begin // AND condition inside a specific case
                    current_LEDs[0] = 0;
                    current_LEDs[1] = ~pwm_out;
                    current_LEDs[2] = 1;
                    end else begin
                    current_LEDs[0] = 1;
                    current_LEDs[1] = ~pwm_out;
                    current_LEDs[2] = 0;
                end
            end

            FADE_BLUE: begin
                // Connect the PWM signal to the BLUE LED.
                if (pwm_state) begin // AND condition inside a specific case
                    current_LEDs[0] = 1;
                    current_LEDs[1] = 0;
                    current_LEDs[2] = ~pwm_out;
                    end else begin
                    current_LEDs[0] = 0;
                    current_LEDs[1] = 1;
                    current_LEDs[2] = ~pwm_out;
                end
            end
        endcase
    end
    
    always_ff @(posedge clk) begin
        prev_LEDs <= current_LEDs;
    end

    assign {RGB_R, RGB_G, RGB_B} = current_LEDs;

endmodule