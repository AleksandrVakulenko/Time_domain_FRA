%% TEST FREQ LOOP

Freq_arr = 10.^linspace(log10(0.1), log10(200), 15);
Freq_arr(Freq_arr > 200) = [];

Aster_addr = 3;

Gen_Voltage_level = 1; % [V]

% Gen_freq = 2; % [Hz]
Harm_num = [1];
Time_profile = "common"; % "ultra_fast", "common", "fine", "most_accurate"


Cap_exp = 1e-9;
Fig = figure('position', [471 217 690 691]);

Result_arr = [];
N = numel(Freq_arr);
for i = 1:N
    disp([num2str(i) '/' num2str(N)])

    Gen_freq = Freq_arr(i);
    [Fit_Result, Extra_data] = Test_measurment_function(Aster_addr, Gen_freq, ...
        Gen_Voltage_level, Harm_num, Cap_exp, Time_profile, Fig);
    Result_arr = [Result_arr Fit_Result];

    Cap_exp = Fit_Result.cap_par;
end

%%

figure('position', [468 218 686 783])

Res = [Result_arr.res_abs];
Res_err = [Result_arr.res_abs_err];
Phi = [Result_arr.phi];
Phi_err = [Result_arr.phi_err];

subplot(2, 1, 1)
hold on
% errorbar(Freq_arr, Res, Res_err, '-b')
plot(Freq_arr, 1./(2*pi*Res.*Freq_arr)*1e12)
% plot(Res./Res*100, '-b')
% plot((Res+Res_err)./Res*100, '--b')
% plot((Res-Res_err)./Res*100, '--b')
ylabel('|Cap|, pF')
xlabel('f, Hz')
set(gca, 'xscale', 'log')
set(gca, 'yscale', 'log')

subplot(2, 1, 2)
hold on
errorbar(Freq_arr, Phi, Phi_err, '-b')
% plot(Freq_arr, Phi_err)
% plot(Phi_err, '--b')
ylabel('Phi, deg')
xlabel('f, Hz')
set(gca, 'xscale', 'log')



%% Extra_data

% Freq = Result_1.freq;
Ch_data_1 = Extra_data.ch_data_1;
Ch_data_2 = Extra_data.ch_data_1;
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






%% TEST MEASUREMENT LOOP

Aster_addr = 3;

Gen_Voltage_level = 1; % [V]

Gen_freq = 0.01; % [Hz]
Harm_num = [1];
Time_profile = "common"; % "ultra_fast", "common", "fine", "most_accurate"


Cap_exp = 1e-9;
Fig = figure('position', [471 217 690 691]);

Result_arr = [];
N = 1;
for i = 1:N
    disp([num2str(i) '/' num2str(N)])

    [Fit_Result, Extra_data] = Test_measurment_function(Aster_addr, Gen_freq, ...
        Gen_Voltage_level, Harm_num, Cap_exp, Time_profile, Fig);
    Result_arr = [Result_arr Fit_Result];

    Cap_exp = Fit_Result.cap_par;
end

%%
% Result_arr1 = Result_arr; % common
% Result_arr2 = Result_arr; % ultra_fast
% Result_arr3 = Result_arr; % fine
% Result_arr4 = Result_arr; % most_accurate

Result_arr = [Result_arr2 Result_arr1 Result_arr3 Result_arr4]

figure('position', [468 218 686 783])

Res = [Result_arr.res_abs];
Res_err = [Result_arr.res_abs_err];
Phi = [Result_arr.phi];
Phi_err = [Result_arr.phi_err];

subplot(2, 1, 1)
hold on
plot(Res, '-b')
plot(Res+Res_err, '--b')
plot(Res-Res_err, '--b')
% plot(Res./Res*100, '-b')
% plot((Res+Res_err)./Res*100, '--b')
% plot((Res-Res_err)./Res*100, '--b')
ylabel('|R|, Ohm')


subplot(2, 1, 2)
hold on
plot(Phi, '-b')
plot(Phi+Phi_err, '--b')
plot(Phi-Phi_err, '--b')
% plot(Phi_err, '--b')
ylabel('Phi, deg')









%% TEST MEASUREMENT FUNCTNION

function [Fit_Result, Extra_data] = Test_measurment_function(Aster_addr, ...
    Gen_freq, Gen_Voltage_level, Harm_num, Cap_exp, Time_profile, Fig)

%--------------------------------
Freq = Gen_freq;
Gen_Offset_level = 0; % [V] % FIXME: unused
Harm_profile = "common"; % "common", "most_accurate"
%--------------------------------

Settings.amp = Gen_Voltage_level;
Settings.freq = Gen_freq;
Settings.dc = Gen_Offset_level;
Settings.harm_num = Harm_num;
Settings.time_profile = Time_profile;
Settings.harm_profile = Harm_profile;


% Measurement part
[Exit_flag, Ch_data_1, Ch_data_2, R_Scale, Accuracy_conf, Used_ranges] = ...
    Aster_FRA_measure(Aster_addr, Settings, Fig, Cap_exp);

warning(['>>>>>> Exit_flag: ' num2str(Exit_flag) ' >>>>>>>>']); % FIXME: disp


% Fitting part
Period_counter = Ch_data_1.period_counter;

[Properties_1, Properties_2] = get_fit_props(Period_counter);

Max_points = 50e3;

[Result_1, Residuals_1, DEBUG_1, Result_2, Residuals_2, DEBUG_2] = ...
    fit_two_channels(Ch_data_1, Ch_data_2, Properties_1, Properties_2, ...
    Harm_num, Max_points);

[Score_1, Score_2, Best_flag, Max_score] = ...
    fit_viewer.score_calc(Result_1, Result_2, Accuracy_conf);

disp([newline 'Scores:' newline 'Ch1: ' num2str(Score_1) newline ...
    'Ch2: ' num2str(Score_2)]) % FIXME: disp


% FIXME: use debug function to show results
Fit_Result = fit_viewer.show_result_debug(Result_1, Result_2, Freq,  R_Scale);
Extra_data.ch_data_1 = Ch_data_1;
Extra_data.ch_data_1 = Ch_data_2;
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

end