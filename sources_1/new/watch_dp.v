`timescale 1ns / 1ps

module watch_dp (
    input clk,
    input reset,
    input btn_sec,
    input btn_min,
    input btn_hour,
    output [6:0] msec,
    output [6:0] sec,
    output [6:0] min,
    output [6:0] hour
);

    wire w_clk_100hz, tick_sec, tick_min;


    clk_div_100 clk_div_100 (
        .clk  (clk),
        .reset(reset),
        .run  (1),
        .clear(0),
        .o_clk(w_clk_100hz)
    );

    time_show #(
        .TICK_COUNT(100),
        .INITIAL_VALUE(0)
    ) time_msec (
        .clk(clk),
        .reset(reset),
        .tick(w_clk_100hz),
        .btn_up(1'b0),
        .o_time(msec),
        .o_tick(tick_msec)
    );

    time_show #(
        .TICK_COUNT(60),
        .INITIAL_VALUE(0)
    ) time_sec (
        .clk(clk),
        .reset(reset),
        .tick(tick_msec),
        .btn_up(btn_sec),
        .o_time(sec),
        .o_tick(tick_sec)
    );
    time_show #(
        .TICK_COUNT(60),
        .INITIAL_VALUE(0)
    ) time_min (
        .clk(clk),
        .reset(reset),
        .tick(tick_sec),
        .btn_up(btn_min),
        .o_time(min),
        .o_tick(tick_min)
    );
    time_show #(
        .TICK_COUNT(24),
        .INITIAL_VALUE(12)
    ) time_hour (
        .clk(clk),
        .reset(reset),
        .tick(tick_min),
        .btn_up(btn_hour),
        .o_time(hour),
        .o_tick()
    );
endmodule


module time_show (
    input clk,
    input reset,
    input tick,
    input btn_up,
    output [6:0] o_time,
    output o_tick
);

    parameter TICK_COUNT = 100, INITIAL_VALUE = 0;

    reg [$clog2(TICK_COUNT)-1:0] count_reg, count_next;
    reg tick_reg, tick_next;

    assign o_time = count_reg;
    assign o_tick = tick_reg;


    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count_reg <= INITIAL_VALUE;
            tick_reg  <= 0;
        end else begin
            count_reg <= count_next;
            tick_reg  <= tick_next;
        end
    end

    always @(*) begin
        count_next = count_reg;
        tick_next  = 1'b0;
        if (btn_up) begin
            count_next = count_reg + 1;
        end  
        if (tick) begin
            if (count_reg == TICK_COUNT - 1) begin
                count_next = 0;
                tick_next  = 1'b1;
            end else begin
                count_next = count_reg + 1;
                tick_next  = 1'b0;
            end
        end

        // 버튼으로 인한 overflow방지
        if(count_next >= TICK_COUNT) begin
            count_next = 0;
            tick_next = 1'b1;
        end
    end
endmodule
