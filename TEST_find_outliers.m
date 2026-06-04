

T_arr = Ch_data_2.time;
V2_arr = Ch_data_2.voltage;

[range, Outliers_volume, Limits, Residuals] = ...
    fit_core.find_outliers(Ch_data_2, Result_2);

disp(['Outliers volume = ' num2str(Outliers_volume*100, '%0.2f') ' %'])

figure
hold on
plot(T_arr(~range), V2_arr(~range), '-b')
plot(T_arr(range), V2_arr(range), '.k')




%%



clc

Residuals_scaled = Residuals*1000;


[Bot_cut, Top_cut, Residuals_scaled] = find_cat_values(Residuals_scaled);

[mu_start, sigma_start] = estimate_mu_sigma(Residuals_scaled);

% disp(['Mu_start = ' num2str(mu_start)])
% disp(['Sigma_start = ' num2str(sigma_start)])

% figure
% hold on
% Hist = histogram(Residuals_scaled, N, 'Normalization', 'pdf');
[Values, BinEdges] = histcounts(Residuals_scaled, N, 'Normalization', 'pdf');
% BinEdges = Hist.BinEdges;
hx = (BinEdges(2:end)+BinEdges(1:end-1))/2;
% hy = Hist.Values;
hy = Values;

fit_res = fit(hx', hy', '1/(sqrt(2*pi)*sigma)*exp(-1/2*((x-mu)/sigma)^2)', ...
    'StartPoint', [mu_start sigma_start]);
Mu = fit_res.mu;
Sigma = fit_res.sigma;


% disp(['Mu = ' num2str(Mu)])
% disp(['Sigma = ' num2str(Sigma)])

% figure
% hold on
% hy_model = feval(fit_res, hx);
% plot(hx, hy)
% plot(hx, hy_model, '-k', 'LineWidth', 2)

% 3*std(Residuals_scaled)
% 3*Sigma

% xline(Mu + 3*Sigma, 'r')
% xline(Mu - 3*Sigma, 'r')

%%


figure
hold on

[range, Top_limit, Bot_limit] = find_outliers_range_3(Residuals);

% plot(Residuals)
% yline(Top_limit)
% yline(Bot_limit)

plot(T_arr(~range), V2_arr(~range), '-b')
plot(T_arr(range), V2_arr(range), '.r')

%%







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
















