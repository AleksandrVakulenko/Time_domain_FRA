
function [Result_new, Residuals_new, DEBUG_new] = fit_refit_one_ch(Ch_data, ...
    Freq, Harm_num, Time_profile, Harm_profile, Ch_num, Max_points)
arguments
    Ch_data fit_core.Ch_data
    Freq
    Harm_num
    Time_profile
    Harm_profile
    Ch_num {mustBeMember(Ch_num, [1, 2])}
    Max_points = 50e3 % FIXME: magic constant
end

T_arr = Ch_data.time;
V_arr = Ch_data.voltage;
Overload = Ch_data.overload;
Outliers_range = Ch_data.outliers_range;
Outliers_range = fit_core.uppend_outliers(T_arr, Outliers_range);
Fs = Ch_data.fs;

% Freq = Result.freq;
Period = 1/Freq;

[Times_conf, ~, Accuracy_conf] = get_time_config(Period, Harm_num, ...
    Time_profile, Harm_profile);

Time_passed = T_arr(end) - T_arr(1);
Periods_counter = Time_passed/Period;

Estimations = fit_core.do_estimations(fit_core.Estimation.empty, ...
    T_arr, V_arr, Freq, Periods_counter);

[Properties_1, Properties_2] = get_fit_props(Periods_counter);
if Ch_num == 1
    Properties = Properties_1;
else
    Properties = Properties_2;
end

Ch_data = fit_core.Ch_data(T_arr, V_arr, Outliers_range, Overload, ...
    Estimations, Times_conf, Accuracy_conf, Fs, Periods_counter);

[Result_new, Residuals_new, DEBUG_new] = ...
    fit_one_channels(Ch_data, Properties, Harm_num, Max_points);

end