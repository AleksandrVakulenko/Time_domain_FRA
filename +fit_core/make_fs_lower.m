
%FIXME: UNDONE function

function [T_arr_new, V1_arr_new, V2_arr_new, Fs_new] = make_fs_lower(T_arr, ...
    V1_arr, V2_arr, Fs, freq, Find_harms_num, Max_points)

Num = numel(T_arr);

if Num > Max_points
%     Period = 1/freq; % FIXME: unused
    Time_length = T_arr(end) - T_arr(1);
%     Period_counter = Time_length/Period; % FIXME: unused
    
    if ~isempty(Find_harms_num)
        Max_harm = max(Find_harms_num);
    else
        Max_harm = 3;
    end

    Max_freq = Max_harm * freq;
    Filter_freq = Max_freq*2;
    if Filter_freq > Fs/2
        Filter_freq = [];
    end

    Fs_new = Max_points/Time_length;
    if ~isempty(Filter_freq)
        [T_arr, V1_arr, V2_arr] = fit_core.fft_filter_dbl_ch(T_arr, V1_arr, ...
            V2_arr, freq, Fs, Filter_freq);
    end

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