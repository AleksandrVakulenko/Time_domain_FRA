

function [T_arr_filt, Signal_filt_1] = ...
    fft_filter_single_ch(Time_arr, V1_arr,freq , Fs, Filter_freq)

T_arr_filt = Time_arr;
Signal_filt_1 = V1_arr;

Period_scale = 6.0; % NOTE: at least 6 filter periods from both sides of window
Fiter_lvl_dB = -40; % NOTE: its enough

Filter_period = 1/Filter_freq;
Period = 1/freq;

Time_cut_length = 2*Period_scale*Filter_period;
Time_length = T_arr_filt(end) - T_arr_filt(1);

Period_counter = Time_length/Period;
Period_counter_new = (Time_length-Time_cut_length)/Period;
Ratio = Period_counter_new/Period_counter;
if Ratio < 0
    Ratio = 0;
end

Min_Ratio = 0.8; % FIXME: magic constant

if Ratio > Min_Ratio
    apply_filter = true;
else
    apply_filter = false;
end

if apply_filter
    Signal_filt_1 = fft_band_rejection(Signal_filt_1, Fs, Fiter_lvl_dB, ...
        Filter_freq, Fs/2);
    
    range1 = T_arr_filt < T_arr_filt(1) + Period_scale*Filter_period;
    range2 = T_arr_filt > T_arr_filt(end) - Period_scale*Filter_period;
    range = range1 | range2;
    T_arr_filt(range) = [];
    Signal_filt_1(range) = [];
else
    % FIXME: disp
    warning(['Filter does not applied: ' num2str(Ratio) ' < ' num2str(Min_Ratio)]);
end

end