
`timescale 1ns/1ps

module traffic_fsm_tb;

reg clk = 0;
reg reset = 0;
reg ns_sensor = 0;
reg ew_sensor = 0;

wire [2:0] ns_light;
wire [2:0] ew_light;

integer passed = 0;
integer failed = 0;
integer ns_short, ns_long;
integer ew_short, ew_long;

localparam RED    = 3'b100;
localparam YELLOW = 3'b010;
localparam GREEN  = 3'b001;

traffic_fsm dut (
    .clk(clk),
    .reset(reset),
    .ns_sensor(ns_sensor),
    .ew_sensor(ew_sensor),
    .ns_light(ns_light),
    .ew_light(ew_light)
);

always #5 clk = ~clk;

// Check that both directions are never green together.
always @(negedge clk) begin
    if (!reset &&
        ns_light == GREEN &&
        ew_light == GREEN) begin
        $display("FAIL: Both directions GREEN!");
        failed = failed + 1;
    end
end

// Restart controller with chosen sensor values.
task restart;
    input ns_request;
    input ew_request;
    begin
        @(negedge clk);
        reset = 1;
        ns_sensor = ns_request;
        ew_sensor = ew_request;

        @(negedge clk);
        reset = 0;
        #1;
    end
endtask

// Measure how many clock cycles NS remains green.
task measure_ns_green;
    output integer count;
    begin
        count = 0;

        while (ns_light == GREEN && count < 20) begin
            @(negedge clk);
            count = count + 1;
        end
    end
endtask

// Measure how many clock cycles EW remains green.
task measure_ew_green;
    output integer count;
    begin
        count = 0;

        while (ew_light == GREEN && count < 20) begin
            @(negedge clk);
            count = count + 1;
        end
    end
endtask

initial begin
    $dumpfile("smart_traffic.vcd");
    $dumpvars(0, traffic_fsm_tb);

    // Test 1: EW vehicle waiting -> shorter NS green.
    restart(0, 1);
    measure_ns_green(ns_short);

    // Test 2: No EW vehicle -> longer NS green.
    restart(0, 0);
    measure_ns_green(ns_long);

    if (ns_short == 5 && ns_long == 10) begin
        $display("PASS: NS adaptive timing (short=%0d long=%0d)",
                 ns_short, ns_long);
        passed = passed + 1;
    end else begin
        $display("FAIL: NS adaptive timing (short=%0d long=%0d)",
                 ns_short, ns_long);
        failed = failed + 1;
    end

    // Test 3: NS vehicle waiting -> shorter EW green.
    restart(1, 0);

    // Wait until EW turns green.
wait (ew_light == GREEN);
@(negedge clk);
measure_ew_green(ew_short);

    // Test 4: No NS vehicle -> longer EW green.
    restart(0, 0);
  wait (ew_light == GREEN);
@(negedge clk);
measure_ew_green(ew_long);

    if (ew_short == 5 && ew_long == 10) begin
        $display("PASS: EW adaptive timing (short=%0d long=%0d)",
                 ew_short, ew_long);
        passed = passed + 1;
    end else begin
        $display("FAIL: EW adaptive timing (short=%0d long=%0d)",
                 ew_short, ew_long);
        failed = failed + 1;
    end

    // Test 5: Check reset returns to NS green.
    restart(0, 0);

    if (ns_light == GREEN && ew_light == RED) begin
        $display("PASS: Reset initializes NS green");
        passed = passed + 1;
    end else begin
        $display("FAIL: Reset behavior");
        failed = failed + 1;
    end

    $display("-----------------------------");
    $display("PASSED: %0d", passed);
    $display("FAILED: %0d", failed);

    $finish;
end

endmodule
