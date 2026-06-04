
function [range, Outliers_volume, Limits, Residuals] = ...
    find_outliers(Ch_data, Result)

T_arr = Ch_data.time;
Fs = Ch_data.fs;
Freq = Result.freq;

Residuals = calc_residuals(Ch_data, Result);
[range, Top_limit, Bot_limit] = find_outliers_range(Residuals, Freq, Fs);

Limits.top = Top_limit;
Limits.bot = Bot_limit;

Outliers_count = numel(find(range));
Signal_points_count = numel(T_arr);
Outliers_volume = Outliers_count/Signal_points_count;

end




function Residuals = calc_residuals(Ch_data, Result_in)

T_arr = Ch_data.time;
Data_signal = Ch_data.voltage;

ym = fit_viewer.calc_fitted_signal(Result_in, T_arr);

Harm_y = fit_viewer.Harm_calc(Result_in, T_arr);
if ~isempty(Harm_y)
    ym = ym + Harm_y;
end
Residuals = Data_signal - ym;

end


function [range, Top_limit, Bot_limit] = find_outliers_range(Residuals, Freq, Fs)

Mean = mean(Residuals);
Sigma = std(Residuals);

Top_limit = Mean + 3*Sigma; % FIXME: magic constant, need to analyze histogram
Bot_limit = Mean - 3*Sigma;

range = Residuals > Top_limit | Residuals < Bot_limit;

range = range_smooth(range, Freq, Fs);

end


function range = range_smooth(range, Freq, Fs)

Period = 1/Freq;

Kernel_length_time = 0.01 * Period; % FIXME: magic constant
Kernel_length_num = round(Kernel_length_time*Fs);

Kernel = ones(1, Kernel_length_num)/Kernel_length_num;

range = conv(range, Kernel, "same");
range = range > 0;

end