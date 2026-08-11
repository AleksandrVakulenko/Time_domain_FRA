

function [Fit_Result, Extra_data] = single_freq_measurment(Resources, ...
    Aster_addr, Gen_freq, Gen_Voltage_level, DC_bias, Harm_num, Zest, Time_profile, ...
    Fig_or_ax, Fixed_range, Self_cal_mode, Noisy_env)

%--------------------------------
Freq = Gen_freq;
Gen_Offset_level = DC_bias; % [V] % FIXME: unused
Harm_profile = "common"; % "common", "most_accurate"
Use_power_line_filter = Noisy_env; % FIXME: must be an argument
% FIXME: use Noisy_env to extend gathering time until power line filter is
% applied
%--------------------------------

Settings.amp = Gen_Voltage_level;
Settings.freq = Gen_freq;
Settings.dc = Gen_Offset_level;
Settings.harm_num = Harm_num;
Settings.time_profile = Time_profile;
Settings.harm_profile = Harm_profile;
Settings.use_power_line_filter = Use_power_line_filter;

% Measurement part
try
[Exit_flag, Ch_data_1, Ch_data_2, R_Scale, Accuracy_conf, ...
    Used_ranges, Aster_range] = Aster_FRA.measure(Resources, Aster_addr, ...
    Settings, Fig_or_ax, Zest, Fixed_range, Self_cal_mode);
catch ERR
    Fit_Result = [];
    Extra_data = [];
    print_error_msg(ERR);
    return
end

klog.warning(['>>>>>> Exit_flag: ' num2str(Exit_flag) ' >>>>>>>>'], 'debug_light');

if Exit_flag == 40
    % FIXME: debug way to finish by stop button
    error('The program has been terminated by the user.')
end

% Fitting part
Period_counter = Ch_data_1.period_counter;

[Properties_1, Properties_2] = fit_core.get_fit_props(Period_counter);

Max_points = 50e3; % FIXME: get from settings

[Result_1, Residuals_1, DEBUG_1, Result_2, Residuals_2, DEBUG_2] = ...
    fit_core.fit_two_channels(Ch_data_1, Ch_data_2, Properties_1, Properties_2, ...
    Harm_num, Max_points);

[Score_1, Score_2, Best_flag, Max_score] = ...
    fit_viewer.score_calc(Result_1, Result_2, Accuracy_conf);

klog.disp([newline 'Scores:' newline 'Ch1: ' num2str(Score_1) newline ...
    'Ch2: ' num2str(Score_2) newline], "common")

% Final plot part
Axes_arr = fit_gui.init_gather_axes(Fig_or_ax);
if numel(Axes_arr) == 2 && all(isvalid(Axes_arr))
    style_num = 2;

    Ax1 = Axes_arr(1);
    Ax2 = Axes_arr(2);

    fit_viewer.data_gather_plot(Ax1, Ch_data_1.time, Ch_data_1.voltage, ...
        Ch_data_1.outliers_range, Result_1, style_num);
    xlabel('t, s', 'Parent', Ax1)
    ylabel('V1, V', 'Parent', Ax1)

    fit_viewer.data_gather_plot(Ax2, Ch_data_2.time, Ch_data_2.voltage, ...
        Ch_data_2.outliers_range, Result_2, style_num);
    xlabel('t, s', 'Parent', Ax2);
    ylabel('V2, V', 'Parent', Ax2);

    drawnow
end


% FIXME: use debug function to show results
if ~isempty(Result_1) && ~isempty(Result_2)
    Fit_Result = Aster_FRA.do_FRA_result(Result_1, Result_2, Freq, Aster_range);
else
    Fit_Result = []; % FIXME: use FRA type
end

Extra_data.ch_data_1 = Ch_data_1;
Extra_data.ch_data_2 = Ch_data_2;
Extra_data.result_1 = Result_1;
Extra_data.result_2 = Result_2;
Extra_data.residuals_1 = Residuals_1;
Extra_data.residuals_2 = Residuals_2;
Extra_data.score.score_1 = Score_1;
Extra_data.score.score_2 = Score_2;
Extra_data.score.best_flag = Best_flag;
Extra_data.score.max_score = Max_score;
Extra_data.DEBUG.DEBUG_1 = DEBUG_1;
Extra_data.DEBUG.DEBUG_2 = DEBUG_2;
Extra_data.used_ranges = Used_ranges;
Extra_data.aster_range = Aster_range;

end