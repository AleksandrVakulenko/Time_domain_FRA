
function [range, Outliers_volume, Limits, Residuals] = ...
    find_outliers(Ch_data, Result)

T_arr = Ch_data.time;
Fs = Ch_data.fs;
Freq = Result.freq;

Residuals = calc_residuals(Ch_data, Result);
[range, Top_limit, Bot_limit] = find_outliers_range_2(Residuals);

range = range_smooth(range, Freq, Fs);

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

Residuals = Data_signal - ym;

end


function [range, Top_limit, Bot_limit] = find_outliers_range_2(Residuals)

Scale = 1000;

Residuals_scaled = Residuals*Scale;

[~, ~, Residuals_scaled] = find_cat_values(Residuals_scaled);

[mu_start, sigma_start] = estimate_mu_sigma(Residuals_scaled);

N = numel(Residuals);
N = round(4*sqrt(N));
if N > 100
    N = 100;
end

% figure
% histogram(Residuals_scaled, N, 'Normalization', 'pdf')
[Values, BinEdges] = histcounts(Residuals_scaled, N, 'Normalization', 'pdf');
hx = (BinEdges(2:end)+BinEdges(1:end-1))/2;
hy = Values;

fit_res = fit(hx', hy', '1/(sqrt(2*pi)*sigma)*exp(-1/2*((x-mu)/sigma)^2)', ...
    'StartPoint', [mu_start sigma_start]);
Mu = fit_res.mu/Scale;
Sigma = fit_res.sigma/Scale;

Top_limit = Mu + 4*Sigma;
Bot_limit = Mu - 4*Sigma;

range = Residuals > Top_limit | Residuals < Bot_limit;

end


function [range, Top_limit, Bot_limit] = find_outliers_range(Residuals)

Mean = mean(Residuals);
Sigma = std(Residuals);

% FIXME: need to analyze histogram
Sigma_scale = 3; % FIXME: get_from_settings
Top_limit = Mean + Sigma_scale*Sigma;
Bot_limit = Mean - Sigma_scale*Sigma;

range = Residuals > Top_limit | Residuals < Bot_limit;

end


function range = range_smooth(range, Freq, Fs)

Period = 1/Freq;

Kernel_length_time = 0.01 * Period; % FIXME: magic constant
Kernel_length_num = round(Kernel_length_time*Fs);

Kernel = ones(1, Kernel_length_num)/Kernel_length_num;

range = conv(range, Kernel, "same");
range = range > 0;

end


function [mu_start, sigma_start] = estimate_mu_sigma(Residuals)

std(Residuals)
P10 = prctile(Residuals, 50 - 18);
P90 = prctile(Residuals, 50 + 18);

% disp(['== ' num2str(P90-P10)])

mu_start = mean(Residuals); % FIXME
sigma_start = P90-P10; % FIXME

end





function [Bot_cut, Top_cut, Data] = find_cat_values(Data)

P01 = prctile(Data, 1);
P99 = prctile(Data, 99);

% Mu = mean(Data);
Top = mean(Data) + 5*std(Data);
Bot = mean(Data) - 5*std(Data);


Bot_cut = max([P01 Bot]);
Top_cut = min([P99 Top]);


Data(Data < Bot_cut) = [];
Data(Data > Top_cut) = [];

end