
%FIXME: UNDODE function
function [T_arr_new, V1_arr_new, V2_arr_new, Fs_new] = make_fs_lower(T_arr, ...
    V1_arr, V2_arr, Fs, freq, Find_harms_num, Max_points)

Period = 1/freq;
Time_length = T_arr(end) - T_arr(1);
Period_counter = Time_length/Period;
Num = numel(T_arr);

if ~isempty(Find_harms_num)
    Max_harm = max(Find_harms_num);
else
    Max_harm = 1;
end

Max_freq = Max_harm * freq;
Filter_freq = Max_freq*2;
Fs_new = Max_freq*4;

if Fs_new < 500
    Fs_new = 500; % FIXME: magic constant
end

if Num > Max_points
    [T_arr, V1_arr, V2_arr] = ...
        fit_core.fft_filter_dbl_ch(T_arr, V1_arr, V2_arr, freq, Fs, Filter_freq);

    T_arr_new = T_arr(1) : 1/Fs_new : T_arr(end);
    V1_arr_new = interp1(T_arr, V1_arr, T_arr_new);
    V2_arr_new = interp1(T_arr, V2_arr, T_arr_new);
else
    T_arr_new = T_arr;
    V1_arr_new = V1_arr;
    V2_arr_new = V2_arr;
    Fs_new = Fs;
end

end