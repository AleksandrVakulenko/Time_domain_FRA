

clc



i = 10;


Result_1 = Extra_data_arr(i).result_1;
Result_2 = Extra_data_arr(i).result_2;

Ch_data_1 = Extra_data_arr(i).ch_data_1;
Ch_data_2 = Extra_data_arr(i).ch_data_2;
% Residuals_1 = Extra_data_arr(i).residuals_1;

Extra_data = Extra_data_arr(i);

Freq = Result_arr_Aster(i).freq;
Harm_profile = "common";
Harm_num = [1 2 3];
Time_profile = "fine"; % "ultra_fast", "common", "fine", "most_accurate"



Period = 1/Freq;

[Times_conf, Time_printer, Accuracy_conf] = get_time_config(Period, Harm_num, ...
    Time_profile, Harm_profile);


[Score_1, Score_2, Best_flag, Max_score] = ...
    fit_viewer.score_calc(Result_1, Result_2, Accuracy_conf);

disp(['Score 1: ' num2str(Score_1)])
disp(['Score 2: ' num2str(Score_2)])


[Res_to_noise, Residuals_rms, Noise_rms] = ...
    fit_core.calc_res_to_noise(Ch_data_1, Result_1, Harm_num);



hold on
plot(Ch_data_1.time, Ch_data_1.voltage)
% plot(Ch_data_1.time, ym)
% plot(Ch_data_1.time, Residuals_1)


yline(Noise_rms, '--r')
yline(Residuals_rms, '-b')






if Res_to_noise > 5 % FIXME: magic constant
    Refit_flag = true;
else
    Refit_flag = false;
end

Refit_flag




% Result_refit = fit_core.DFT_estimation(Ch_1_time, Ch_1_V, Period);

%%

clc

Ch_data = Ch_data_2;
% Freq
% Harm_num
% Time_profile
% Harm_profile

Harm_num = [1 2 3 4 5]
% plot(Residuals_new)

[Score_prev, ~] = fit_viewer.score_calc_ch(Result_1, Accuracy_conf);

[Result_new, Residuals_new, DEBUG_new] = fit_refit_one_ch(Ch_data_2, ...
    Freq, Harm_num, Time_profile, Harm_profile, 1);

[Score_new, Max_score] = fit_viewer.score_calc_ch(Result_new, Accuracy_conf);

disp(['Score: ' num2str(Score_prev) ' -> ' num2str(Score_new)]);



%%
Noise_rms = fit_core.noise_rms_calc(Ch_data_1.voltage, Ch_data_1.fs, Freq, Harm_num);

Residuals_rms = sqrt(mean(Residuals_new.^2));

figure
plot(Ch_data_1.time, Residuals_new)

yline(Noise_rms, '--r')
yline(Residuals_rms, '-b')









