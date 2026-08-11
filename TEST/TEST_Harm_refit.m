

Extra_data = Extra_data_arr(2);

% Freq = Result_1.freq;
Ch_data_1 = Extra_data.ch_data_1;
Ch_data_2 = Extra_data.ch_data_2;
Result_1 = Extra_data.result_1;
Result_2 = Extra_data.result_2;
% Residuals_1 = Extra_data.residuals_1;
% Residuals_2 = Extra_data.residuals_2;
Score_1 = Extra_data.score.score_1;
Score_2 = Extra_data.score.score_2;
% Best_flag = Extra_data.score.best_flag;
% Max_score = Extra_data.score.max_score;
% DEBUG_1 = Extra_data.DEBUG.DEBUG_1;
% DEBUG_2 = Extra_data.DEBUG.DEBUG_2;
Used_ranges = Extra_data.used_ranges;


%%

clc

Ch_data = Ch_data_2;
Result = Result_2;

T_arr = Ch_data.time;
V2_arr = Ch_data.voltage;
Fs = Ch_data.fs;

[~, RMS_Ratio, Residuals, Residuals_harm] = ...
    fit_core.Harm_refit(Result, T_arr, V2_arr, Fs);


disp(['RMS_Ratio = ' num2str(RMS_Ratio, '%0.2f')])

figure
hold on
plot(T_arr, Residuals_harm, '-b')
plot(T_arr, Residuals, '--k')




