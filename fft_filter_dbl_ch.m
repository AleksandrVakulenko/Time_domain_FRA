

function [T_arr_filt, Signal_filt_1, Signal_filt_2] = ...
    fft_filter_dbl_ch(Time_arr, V1_arr, V2_arr,freq , Fs, Filter_freq)

T_arr_filt = Time_arr;
Signal_filt_1 = V1_arr;
Signal_filt_2 = V2_arr;

F_Scale = 6.0; % FIXME: magic constant
Fiter_lvl_dB = -40; % FIXME: magic constant

Filter_period = 1/Filter_freq;
Period = 1/freq;

Time_cut_length = 2*F_Scale*Filter_period;
Time_length = T_arr_filt(end) - T_arr_filt(1);

Period_counter = Time_length/Period;
Period_counter_new = (Time_length-Time_cut_length)/Period;
Ratio = Period_counter_new/Period_counter;
if Ratio < 0
    Ratio = 0;
end

if Ratio > 0.8 % FIXME: magic constant
    apply_filter = true;
else
    apply_filter = false;
end

if apply_filter
    Signal_filt_1 = fft_band_rejection(Signal_filt_1, Fs, Fiter_lvl_dB, ...
        Filter_freq, Fs/2);
    Signal_filt_2 = fft_band_rejection(Signal_filt_2, Fs, Fiter_lvl_dB, ...
        Filter_freq, Fs/2);
    
    range1 = T_arr_filt < T_arr_filt(1) + F_Scale*Filter_period;
    range2 = T_arr_filt > T_arr_filt(end) - F_Scale*Filter_period;
    range = range1 | range2;
    T_arr_filt(range) = [];
    Signal_filt_1(range) = [];
    Signal_filt_2(range) = [];
else
    % FIXME: debug
    warning(['Filter does not applied: ' num2str(Ratio)]);
end

end