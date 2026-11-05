
`timescale 1ns/1ps

module traffic_fsm (
    input wire clk,
    input wire reset,
    output reg [2:0] ns_light,
    output reg [2:0] ew_light
);

    // Light encoding: RED=100, YELLOW=010, GREEN=001
    localparam RED = 3'b100;
    localparam YELLOW = 3'b010;
    localparam GREEN = 3'b001;

    // Four FSM states
    localparam S0 = 2'b00; // North-South green
    localparam S1 = 2'b01; // North-South yellow
    localparam S2 = 2'b10; // East-West green
    localparam S3 = 2'b11; // East-West yellow

    reg [1:0] state;
    reg [3:0] timer;

    // State register and timer
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S0;
            timer <= 0;
        end else if (timer == 4) begin
            timer <= 0;
            case (state)
                S0: state <= S1;
                S1: state <= S2;
                S2: state <= S3;
                S3: state <= S0;
                default: state <= S0;
            endcase
        end else begin
            timer <= timer + 1'b1;
        end
    end

    // Output logic
    always @(*) begin
        ns_light = RED;
        ew_light = RED;
        case (state)
            S0: ns_light = GREEN;
            S1: ns_light = YELLOW;
            S2: ew_light = GREEN;
            S3: ew_light = YELLOW;
            default: begin
                ns_light = RED;
                ew_light = RED;
            end
        endcase
    end

endmodule
  