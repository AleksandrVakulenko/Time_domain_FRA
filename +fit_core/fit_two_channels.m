function [Result_1, Residuals_1, DEBUG_1, Result_2, Residuals_2, DEBUG_2] = ...
    fit_two_channels(Ch_data_1, Ch_data_2, Properties_1, Properties_2, ...
    Harm_num, Max_points)

T_arr_1 = Ch_data_1.time;
V1_arr = Ch_data_1.voltage;
Outliers_range_1 = Ch_data_1.outliers_range;
Fit_range_1 = ~Outliers_range_1;
Overload_1 = Ch_data_1.overload;
Fs = Ch_data_1.fs;
Period = Ch_data_1.time_conf.period;
freq = 1/Period;

T_arr_2 = Ch_data_2.time; % NOTE: same as in CH1
V2_arr = Ch_data_2.voltage;
Outliers_range_2 = Ch_data_2.outliers_range;
Fit_range_2 = ~Outliers_range_2;
Overload_2 = Ch_data_2.overload;

Harm_num_1 = Harm_num;
Harm_num_2 = Harm_num;

Time_length = T_arr_1(end) - T_arr_1(1);
Period_counter = Time_length/Period;

if Overload_1.count > 0
    Harm_num_1 = [];
end

if Overload_2.count > 0
    Harm_num_2 = [];
end

Estimations_1 = fit_core.estimation_processing(Ch_data_1);
Estimations_2 = fit_core.estimation_processing(Ch_data_2);

if Period_counter < 2
    Fit_settings_1.freq_dev_flag = false;
    Fit_settings_1.freq_dev_const = 0;
else
    Fit_settings_1.freq_dev_flag = true;
    Fit_settings_1.freq_dev_const = 0;
end
Fit_settings_1.max_points = Max_points;

[Result_1, Residuals_1, DEBUG_1] = fit_core.fit_channel(T_arr_1, V1_arr, ...
    Fit_range_1, Fs, freq, Estimations_1, Properties_1, Harm_num_1, Fit_settings_1);

if isempty(Result_1)
    error('Fit CH1 fail')
end

Fit_settings_2.freq_dev_flag = false;
Fit_settings_2.freq_dev_const = Result_1.f_dev_ppm;
Fit_settings_2.max_points = Max_points;

[Result_2, Residuals_2, DEBUG_2] = fit_core.fit_channel(T_arr_2, V2_arr, ...
    Fit_range_2, Fs, freq, Estimations_2, Properties_2, Harm_num_2, Fit_settings_2);

if isempty(Result_2)
    error('Fit CH2 fail')
end

Result_1.estimations = Estimations_1;
Result_2.estimations = Estimations_2;

end
