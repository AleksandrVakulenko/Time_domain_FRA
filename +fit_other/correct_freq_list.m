

function Freq_arr = correct_freq_list(Freq_arr)
    Freq_arr = fit_other.move_bad_freq(Freq_arr);
    Freq_arr = fit_other.move_bad_freq(Freq_arr);
    Freq_arr = fit_other.move_bad_freq(Freq_arr);
    Freq_arr = fit_other.move_bad_freq(Freq_arr, 'action', 'delete');
end

