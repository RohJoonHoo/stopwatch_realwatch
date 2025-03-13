`timescale 1ns / 1ps

module watch_cu (
    input clk,
    input reset,
    input mode,
    input i_btn_sec,
    input i_btn_min,
    input i_btn_hour,
    output reg o_btn_sec,
    output reg o_btn_min,
    output reg o_btn_hour
);

    // fsm 구조로 CU를 설계
    parameter WATCH = 2'b00, SEC_UP = 2'b01, MIN_UP = 2'b10, HOUR_UP = 2'b11;

    reg [1:0] state, next;
    // state register
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= WATCH;
        end else begin
            state <= next;
        end
    end

    // next state
    always @(*) begin
        next = state;
        case (state)
            WATCH: begin
                if (mode & i_btn_sec) begin
                    next = SEC_UP;
                end else if (mode & i_btn_min) begin
                    next = MIN_UP;
                end else if (mode & i_btn_hour) begin
                    next = HOUR_UP;
                end
            end
            SEC_UP: begin
                if (mode & i_btn_sec == 0) begin
                    next = WATCH;
                end
            end
            MIN_UP: begin
                if (mode & i_btn_min == 0) begin
                    next = WATCH;
                end
            end
            HOUR_UP: begin
                if (mode & i_btn_hour == 0) begin
                    next = WATCH;
                end
            end
            default: next = state;
        endcase
    end

    // output
    always @(*) begin
        o_btn_sec  = 0;
        o_btn_min  = 0;
        o_btn_hour = 0;
        case (state)
            WATCH: begin
                o_btn_sec  = 1'b0;
                o_btn_min  = 1'b0;
                o_btn_hour = 1'b0;
            end
            SEC_UP: begin
                o_btn_sec  = 1'b1;
                o_btn_min  = 1'b0;
                o_btn_hour = 1'b0;
            end
            MIN_UP: begin
                o_btn_sec  = 1'b0;
                o_btn_min  = 1'b1;
                o_btn_hour = 1'b0;
            end
            HOUR_UP: begin
                o_btn_sec  = 1'b0;
                o_btn_min  = 1'b0;
                o_btn_hour = 1'b1;
            end
        endcase
    end
endmodule
