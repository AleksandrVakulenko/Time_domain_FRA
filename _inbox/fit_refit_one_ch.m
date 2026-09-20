
% NOTE: this function is a part of post gather fit (without prefit)
% NOTE: but it must be updated

function [Result_new, Residuals_new, DEBUG_new, Estimations] = fit_refit_one_ch(Ch_data, ...
    Freq, Harm_num, Time_profile, Harm_profile, Ch_num, Max_points)
arguments
    Ch_data TDFRA_TDFRA_fit_core.Ch_data_type
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
Outliers_range = TDFRA_TDFRA_fit_core.uppend_outliers(T_arr, Outliers_range, []);
Fs = Ch_data.fs;

% Freq = Result.freq;
Period = 1/Freq;

[Times_conf, ~, Accuracy_conf] = TDFRA_TDFRA_fit_core.get_time_config(Period, ...
    Time_profile, Harm_profile);

Time_passed = T_arr(end) - T_arr(1);
Periods_counter = Time_passed/Period;

% Estimations = TDFRA_TDFRA_fit_core.do_estimations(TDFRA_TDFRA_fit_core.Estimation_type.empty, ...
%     T_arr, V_arr, Freq, Periods_counter);
Estimations = Ch_data.estimations;

[Properties_1, Properties_2] = TDFRA_TDFRA_fit_core.get_fit_props(Periods_counter);
if Ch_num == 1
    Properties = Properties_1;
else
    Properties = Properties_2;
end

Ch_data = TDFRA_TDFRA_fit_core.Ch_data_type(T_arr, V_arr, Outliers_range, Overload, ...
    Estimations, Times_conf, Accuracy_conf, Fs, Freq, Periods_counter);

[Result_new, Residuals_new, DEBUG_new] = ...
    TDFRA_TDFRA_fit_core.fit_one_channels(Ch_data, Properties, Harm_num, Max_points);

end