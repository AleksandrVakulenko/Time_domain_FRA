
% NOTE: test for fit_core::fft_filter_dbl_ch

% FIXME: NEED TO GENERATE DATA

clc

% T_arr
% V1_arr
% V2_arr
% freq
% Fs

% T_arr_init = T_arr;
T_arr_init = Time_arr;

T_arr_filt = T_arr_init;
Signal_filt_1 = V1_arr;
Signal_filt_2 = V2_arr;

Filter_freq = 40;


[T_arr_filt, Signal_filt_1, Signal_filt_2] = fit_core.fft_filter_dbl_ch(...
    T_arr_filt, Signal_filt_1, Signal_filt_2, freq, Fs, Filter_freq);


figure
subplot(2, 1, 1)
hold on
plot(T_arr_init, V1_arr, '-b')
plot(T_arr_filt, Signal_filt_1, '-r')

subplot(2, 1, 2)
hold on
plot(T_arr_init, V2_arr, '-b')
plot(T_arr_filt, Signal_filt_2, '-r')

% fft_plot(V2_arr, Fs);
% fft_plot(Signal_filt_2, Fs);









