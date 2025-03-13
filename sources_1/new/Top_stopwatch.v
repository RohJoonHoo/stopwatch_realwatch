module Top_stopwatch (
    input clk,
    input reset,
    input btnL,
    input btnR,
    input btnU,
    input btnD,
    input sw_mode,
    input sw_time_mode,
    output [3:0] led,
    output [3:0] fnd_comm,
    output [7:0] fnd_font
);
    assign led = (sw_mode)? (sw_time_mode)?4'b1000:4'b0100:(sw_time_mode)?4'b0010:4'b0001;

    wire w_btnL, w_btnR, run, clear;
    wire [6:0] s_msec, s_sec, s_min, s_hour;
    wire [6:0] w_msec, w_sec, w_min, w_hour;
    wire [6:0] o_msec, o_sec, o_min, o_hour;

    btn_debounce U_btn_left (
        .clk  (clk),
        .reset(reset),
        .i_btn(btnL),
        .o_btn(w_btnL)
    );

    btn_debounce U_btn_right (
        .clk  (clk),
        .reset(reset),
        .i_btn(btnR),
        .o_btn(w_btnR)
    );

    btn_debounce U_btn_up (
        .clk  (clk),
        .reset(reset),
        .i_btn(btnU),
        .o_btn(w_btnU)
    );

    btn_debounce U_btn_down (
        .clk  (clk),
        .reset(reset),
        .i_btn(btnD),
        .o_btn(w_btnD)
    );

    stopwatch_cu Stopwatch_CU (
        .clk(clk),
        .reset(reset),
        .mode(sw_mode),
        .i_btn_run(w_btnL),
        .i_btn_clear(w_btnR),
        .o_run(run),
        .o_clear(clear)
    );

    stopwatch_dp Stopwatch_DP (
        .clk  (clk),
        .reset(reset),
        .run  (run),
        .clear(clear),
        .msec (s_msec),
        .sec  (s_sec),
        .min  (s_min),
        .hour (s_hour)
    );


    watch_cu U_Watch_CU (
        .clk(clk),
        .reset(reset),
        .mode(sw_mode),
        .i_btn_sec(w_btnU),
        .i_btn_min(w_btnD),
        .i_btn_hour(w_btnL),
        .o_btn_sec(w_btn_sec),
        .o_btn_min(w_btn_min),
        .o_btn_hour(w_btn_hour)
    );


    watch_dp Watch_DP (
        .clk(clk),
        .reset(reset),
        .btn_sec(w_btn_sec),
        .btn_min(w_btn_min),
        .btn_hour(w_btn_hour),
        .msec(w_msec),
        .sec(w_sec),
        .min(w_min),
        .hour(w_hour)
    );
    
    mux_2x1_watch U_mux_watch_sw (
        .sel(sw_mode),
        .s_msec(s_msec),
        .s_sec(s_sec),
        .s_min(s_min),
        .s_hour(s_hour),
        .w_msec(w_msec),
        .w_sec(w_sec),
        .w_min(w_min),
        .w_hour(w_hour),
        .o_msec(o_msec),
        .o_sec(o_sec),
        .o_min(o_min),
        .o_hour(o_hour)
    );

    fnd_controller U_Fnd_Ctrl (
        .clk(clk),
        .reset(reset),
        .sw_time_mode(sw_time_mode),
        .msec(o_msec),
        .sec(o_sec),
        .min(o_min),
        .hour(o_hour),
        .fnd_font(fnd_font),
        .fnd_comm(fnd_comm)
    );

endmodule

module mux_2x1_watch (
    input sel,
    input [6:0] s_msec,
    input [6:0] s_sec,
    input [6:0] s_min,
    input [6:0] s_hour,
    input [6:0] w_msec,
    input [6:0] w_sec,
    input [6:0] w_min,
    input [6:0] w_hour,
    output reg [6:0] o_msec,
    output reg [6:0] o_sec,
    output reg [6:0] o_min,
    output reg [6:0] o_hour
);
    always @(*) begin
        case (sel)
            1'b0: begin
                o_msec = s_msec;
                o_sec  = s_sec;
                o_min  = s_min;
                o_hour = s_hour;
            end
            1'b1: begin
                o_msec = w_msec;
                o_sec  = w_sec;
                o_min  = w_min;
                o_hour = w_hour;
            end
        endcase
    end
endmodule
