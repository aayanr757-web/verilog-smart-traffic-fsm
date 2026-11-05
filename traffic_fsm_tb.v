
`timescale 1ns/1ps

module traffic_fsm_tb;

    reg clk = 0;
    reg reset = 0;
    wire [2:0] ns_light;
    wire [2:0] ew_light;

    integer passed = 0;
    integer failed = 0;

    localparam RED    = 3'b100;
    localparam YELLOW = 3'b010;
    localparam GREEN  = 3'b001;

    traffic_fsm dut (
        .clk(clk),
        .reset(reset),
        .ns_light(ns_light),
        .ew_light(ew_light)
    );

    // Clock changes every 5 ns
    always #5 clk = ~clk;

    task check;
        input [2:0] expected_ns;
        input [2:0] expected_ew;
        begin
            if (ns_light === expected_ns &&
                ew_light === expected_ew) begin
                passed = passed + 1;
                $display("PASS: NS=%b EW=%b",
                         ns_light, ew_light);
            end else begin
                failed = failed + 1;
                $display("FAIL: NS=%b EW=%b",
                         ns_light, ew_light);
            end
        end
    endtask

    initial begin
        $dumpfile("traffic.vcd");
        $dumpvars(0, traffic_fsm_tb);

        // Reset controller
        #2 reset = 1;
        #2;
        check(GREEN, RED);

        #2 reset = 0;

        // Wait for each state transition
        #50;
        check(YELLOW, RED);

        #50;
        check(RED, GREEN);

        #50;
        check(RED, YELLOW);

        #50;
        check(GREEN, RED);

        $display("----------------");
        $display("PASSED: %0d", passed);
        $display("FAILED: %0d", failed);

        $finish;
    end

endmodule
