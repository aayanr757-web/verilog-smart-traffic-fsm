
`timescale 1ns/1ps

module traffic_fsm (
    input clk,
    input reset,
    input ns_sensor,
    input ew_sensor,
    output reg [2:0] ns_light,
    output reg [2:0] ew_light
);

parameter RED = 3'b100;
parameter YELLOW = 3'b010;
parameter GREEN = 3'b001;

parameter S0 = 2'd0;
parameter S1 = 2'd1;
parameter S2 = 2'd2;
parameter S3 = 2'd3;

reg [1:0] state;
reg [3:0] timer;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= S0;
        timer <= 0;
    end else begin
        case (state)
            S0: begin
                if (timer >= 4 &&
                    (ew_sensor || timer >= 9)) begin
                    state <= S1;
                    timer <= 0;
                end else
                    timer <= timer + 1'b1;
            end

            S1: begin
                if (timer >= 2) begin
                    state <= S2;
                    timer <= 0;
                end else
                    timer <= timer + 1'b1;
            end

            S2: begin
                if (timer >= 4 &&
                    (ns_sensor || timer >= 9)) begin
                    state <= S3;
                    timer <= 0;
                end else
                    timer <= timer + 1'b1;
            end

            S3: begin
                if (timer >= 2) begin
                    state <= S0;
                    timer <= 0;
                end else
                    timer <= timer + 1'b1;
            end
        endcase
    end
end

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

  
