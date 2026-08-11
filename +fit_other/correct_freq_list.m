

function Freq_arr = correct_freq_list(Freq_arr, level)
    Freq_arr = fit_other.move_bad_freq(Freq_arr, 'level', level);
    Freq_arr = fit_other.move_bad_freq(Freq_arr, 'level', level);
    Freq_arr = fit_other.move_bad_freq(Freq_arr, 'level', level);
    Freq_arr = fit_other.move_bad_freq(Freq_arr, 'level', level, 'action', 'delete');
end

