function [Result_1, Residuals_1, DEBUG_1] = ...
    fit_one_channels(Ch_data, Properties, Harm_num, Max_points)

T_arr_1 = Ch_data.time;
V1_arr = Ch_data.voltage;
Outliers_range = Ch_data.outliers_range;
Fit_range = ~Outliers_range;
Overload_1 = Ch_data.overload;
Fs = Ch_data.fs;
Period = Ch_data.time_conf.period;
freq = 1/Period;


Harm_num_1 = Harm_num;

if Overload_1.count > 0
    Harm_num_1 = [];
end

Estimations_1 = fit_core.estimation_processing(Ch_data);

Fit_settings_1.freq_dev_flag = false; % FIXME: maybe put in input args
Fit_settings_1.freq_dev_const = 0;
Fit_settings_1.max_points = Max_points;

[Result_1, Residuals_1, DEBUG_1] = fit_core.fit_channel(T_arr_1, V1_arr, ...
    Fit_range, Fs, freq, Estimations_1, Properties, Harm_num_1, Fit_settings_1);

end