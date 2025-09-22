// top.sv


module top(
    input  logic clk,       // 12MHz clock input
    output logic RGB_R,
    output logic RGB_G,
    output logic RGB_B
);

    parameter COLOR_INTERVAL = 2_000_000;

    logic [2:0] color_state = RED; // Start with RED

    parameter RED = 3'b011;      // R on
    parameter YELLOW = 3'b001;   // R and G 
    parameter GREEN = 3'b101;    // G 
    parameter CYAN = 3'b100;     // G and B 
    parameter BLUE = 3'b110;     // B 
    parameter MAGENTA = 3'b010;  // R and B 


    logic [20:0] count = 0; // BLINK_INTERVAL counter
    logic [2:0] color_state = RED; 

    always_ff @(posedge clk) begin
        if (count == COLOR_INTERVAL - 1) begin
            case (color_state)
                RED: begin 
                    color_state <= YELLOW;
                    end
                YELLOW: begin 
                    color_state <= GREEN;
                    end
                GREEN: begin
                    color_state <= CYAN;
                    end
                CYAN: begin 
                    color_state <= BLUE;
                    end
                BLUE: begin
                    color_state <= MAGENTA;
                    end
                MAGENTA: begin
                    color_state <= RED;
                    end
                default: begin
                    color_state <= RED;
                    end
            endcase
            count <= 0;
        end
        else begin
            count <= count + 1;
        end
    end

    assign {RGB_R, RGB_G, RGB_B} = color_state;

endmodule