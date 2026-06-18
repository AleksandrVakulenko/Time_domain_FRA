%% TEST FREQ LOOP


Gen_Voltage_level = 0.7; % [V]
F_min = 0.005;
F_max = 300e3;
F_num = 100;

% Fixed_range = [5];

% Freq_arr = 10.^linspace(log10(F_min), log10(F_max), F_num);
% Freq_arr = [0.001 0.002 0.005 0.01 0.02 0.05 0.1 0.2];
% Voltage_amp_arr = [   8       8       8      6      3      1    0.5   0.25 ];
% Voltage_amp_arr = [   3       3       3      3      3      1    0.5   0.25 ];
% Freq_arr =        [ 0.001   0.002   0.005  0.01   0.02   0.05   0.1   0.2  ];
% Voltage_amp_arr = [  10    10     10     10    10    10   10   5];
% Freq_arr =        [0.005  0.01   0.02   0.05   0.1   0.2  0.5  1];

Run_num = 2;

Fixed_range = 6;
Cal_cap_N = 1; % 10 pF
Voltage_amp_arr = [    10    10    10     5      3      1    0.5   0.25  ];
Freq_arr =        [0.001  0.002  0.005  0.01  0.02   0.05   0.1   0.2  ];


F_range_Aster = Freq_arr <= 200;
F_range_LCR = Freq_arr >= 20;

Freq_arr_Aster = Freq_arr(F_range_Aster);
Freq_arr_LCR = Freq_arr(F_range_LCR);


Aster_addr = 3;

% Gen_freq = 2; % [Hz]
Harm_num = [1 2 3];
Time_profile = "fine"; % "ultra_fast", "common", "fine", "most_accurate"


Cap_exp = 100e-9;
Fig = figure('position', [471 217 690 691]);
Ax_arr = create_axes(Fig);

Timer = tic;
Result_arr_Aster = [];
Extra_data_arr = [];
N = numel(Freq_arr_Aster);
for i = 1:N
    disp([num2str(i) '/' num2str(N)])

    Gen_freq = Freq_arr_Aster(i);
    Gen_Voltage_level = Voltage_amp_arr(i);
    [Fit_Result, Extra_data] = Test_measurment_function(Aster_addr, Gen_freq, ...
        Gen_Voltage_level, Harm_num, Cap_exp, Time_profile, Ax_arr, Fixed_range);
    Fit_Result.freq = Gen_freq;
    Result_arr_Aster = [Result_arr_Aster Fit_Result];
    Extra_data_arr = [Extra_data_arr Extra_data];

    Cap_exp = Fit_Result.cap_par;
end

Full_time = toc(Timer);

disp(['Full time: ' num2str(Full_time/60, '%0.1f') ' min'])

Save_file = ['Calibration_data_2/' 'C' num2str(Fixed_range, '%02d') ...
    '_' num2str(Run_num, '%02d') '.mat'];
save(Save_file, "Result_arr_Aster", "Extra_data_arr", "Voltage_amp_arr", ...
    "Freq_arr_Aster", "Full_time")

% Aster_switch_to_LCR(Aster_addr);
% 
% Result_arr_LCR = [];
% N = numel(Freq_arr_LCR);
% for i = 1:N
%     disp([num2str(i) '/' num2str(N)])
% 
%     Gen_freq = Freq_arr_LCR(i);
%     LCR_Result = LCR_measure(Gen_freq, Gen_Voltage_level);
%     LCR_Result.freq = Gen_freq;
%     Result_arr_LCR = [Result_arr_LCR LCR_Result];
% end
% 
% 
% Result_arr = [Result_arr_Aster Result_arr_LCR];

%%

figure('position', [468 218 686 783])

% Freq_arr_plot_LCR = [Result_arr_LCR.freq];
% Res_LCR = [Result_arr_LCR.res_abs];
% Res_err_LCR = [Result_arr_LCR.res_abs_err];
% Phi_LCR = [Result_arr_LCR.phi];
% Phi_err_LCR = [Result_arr_LCR.phi_err];

Freq_arr_plot_Aster = [Result_arr_Aster.freq];
Res_Aster = [Result_arr_Aster.res_abs];
Res_err_Aster = [Result_arr_Aster.res_abs_err];
Phi_Aster = [Result_arr_Aster.phi];
Phi_err_Aster = [Result_arr_Aster.phi_err];

subplot(2, 1, 1)
hold on
% errorbar(Freq_arr_plot_LCR, Res_LCR, Res_err_LCR, '-b')
% errorbar(Freq_arr_plot_Aster, Res_Aster, Res_err_Aster, '-r')
% plot(Freq_arr_plot_LCR, 1./(2*pi*Res_LCR.*Freq_arr_plot_LCR)*1e12, '-b')
plot(Freq_arr_plot_Aster, 1./(2*pi*Res_Aster.*Freq_arr_plot_Aster)*1e12, '-r')
% plot(Res./Res*100, '-b')
% plot((Res+Res_err)./Res*100, '--b')
% plot((Res-Res_err)./Res*100, '--b')
ylabel('|Cap|, pF')
xlabel('f, Hz')
set(gca, 'xscale', 'log')
set(gca, 'yscale', 'log')

subplot(2, 1, 2)
hold on
% errorbar(Freq_arr_plot_LCR, Phi_LCR, Phi_err_LCR, '-b')
errorbar(Freq_arr_plot_Aster, Phi_Aster, Phi_err_Aster, '-r')
% plot(Freq_arr_plot_Aster, abs(tan((Phi_Aster+90)/180*pi)))
% plot(Freq_arr, Phi_err)
% plot(Phi_err, '--b')
ylabel('Phi, deg')
xlabel('f, Hz')
set(gca, 'xscale', 'log')



%% Extra_data

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






%% TEST MEASUREMENT LOOP

Aster_addr = 3;

Gen_Voltage_level = 0.5; % [V]

Gen_freq = 0.5; % [Hz]
Harm_num = [1];
Time_profile = "common"; % "ultra_fast", "common", "fine", "most_accurate"


Cap_exp = 1e-12;
Fig = figure('position', [471 217 690 691]);

Result_arr = [];
N = 1;
for i = 1:N
    disp([num2str(i) '/' num2str(N)])

    [Fit_Result, Extra_data] = Test_measurment_function(Aster_addr, Gen_freq, ...
        Gen_Voltage_level, Harm_num, Cap_exp, Time_profile, Fig, [5]);
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
    Gen_freq, Gen_Voltage_level, Harm_num, Cap_exp, Time_profile, ...
    Fig_or_ax, Fixed_range)

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
[Exit_flag, Ch_data_1, Ch_data_2, R_Scale, Accuracy_conf, ...
    Used_ranges, Aster_range] = ...
    Aster_FRA_measure(Aster_addr, Settings, Fig_or_ax, Cap_exp, Fixed_range);

warning(['>>>>>> Exit_flag: ' num2str(Exit_flag) ' >>>>>>>>']); % FIXME: disp


% Fitting part
Period_counter = Ch_data_1.period_counter;

[Properties_1, Properties_2] = get_fit_props(Period_counter);

Max_points = 50e3; % FIXME: magic constant

[Result_1, Residuals_1, DEBUG_1, Result_2, Residuals_2, DEBUG_2] = ...
    fit_two_channels(Ch_data_1, Ch_data_2, Properties_1, Properties_2, ...
    Harm_num, Max_points);

% FIXME: add Residuals check here; and refit

% % redefine outliers
% Outliers_range_1 = fit_core.find_outliers(Ch_data_1, Result_1);
% Outliers_range_2 = fit_core.find_outliers(Ch_data_2, Result_2);
% Ch_data_1.outliers_range = Outliers_range_1;
% Ch_data_2.outliers_range = Outliers_range_2;
% 
% % Refit after redefine outliers
% [Result_1, Residuals_1, DEBUG_1, Result_2, Residuals_2, DEBUG_2] = ...
%     fit_two_channels(Ch_data_1, Ch_data_2, Properties_1, Properties_2, ...
%     Harm_num, Max_points);

% NOTE: 1 is small, 5 is too much
Res_to_noise_ratio_max = 5; % FIXME: magic constant

Refit_1_flag = false;
if isempty(Result_1)
    Refit_1_flag = true;
else
    % FIXME: why refit if we could do good fit previously?
    Res_to_noise_1 = fit_core.calc_res_to_noise(Ch_data_1, Result_1, Harm_num);
    if Res_to_noise_1 > Res_to_noise_ratio_max
        Refit_1_flag = true;
    end
end

Refit_2_flag = false;
if isempty(Result_2)
    Refit_2_flag = true;
else
    % FIXME: why refit if we could do good fit previously?
    Res_to_noise_2 = fit_core.calc_res_to_noise(Ch_data_2, Result_2, Harm_num);
    if Res_to_noise_2 > Res_to_noise_ratio_max
        Refit_2_flag = true;
    end
end

if Refit_1_flag
    [Result_1, Residuals_1, DEBUG_1] = fit_refit_one_ch(Ch_data_1, ...
        Freq, Harm_num, Time_profile, Harm_profile, 1, Max_points);
end

if Refit_2_flag
    [Result_2, Residuals_2, DEBUG_2] = fit_refit_one_ch(Ch_data_2, ...
        Freq, Harm_num, Time_profile, Harm_profile, 2, Max_points);
end
% NOTE: end of refit part


[Score_1, Score_2, Best_flag, Max_score] = ...
    fit_viewer.score_calc(Result_1, Result_2, Accuracy_conf);

disp([newline 'Scores:' newline 'Ch1: ' num2str(Score_1) newline ...
    'Ch2: ' num2str(Score_2)]) % FIXME: disp

% Final plot part
Axes_arr = init_gather_axes(Fig_or_ax);
if numel(Axes_arr) == 2 && all(isvalid(Axes_arr))
    style_num = 2;

    Ax1 = Axes_arr(1);
    Ax2 = Axes_arr(2);

    data_gather_plot(Ax1, Ch_data_1.time, Ch_data_1.voltage, ...
        Ch_data_1.outliers_range, Result_1, style_num);
    xlabel('t, s', 'Parent', Ax1)
    ylabel('V1, V', 'Parent', Ax1)

    data_gather_plot(Ax2, Ch_data_2.time, Ch_data_2.voltage, ...
        Ch_data_2.outliers_range, Result_2, style_num);
    xlabel('t, s', 'Parent', Ax2);
    ylabel('V2, V', 'Parent', Ax2);

    drawnow
end


% FIXME: use debug function to show results
if ~isempty(Result_1) && ~isempty(Result_2)
    Fit_Result = fit_viewer.show_result_debug(Result_1, Result_2, Freq,  R_Scale);
else
    Fit_Result = [];
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




function Axes_arr = create_axes(Fig)
if ~isempty(Fig)
    figure(Fig)

    Ax1 = subplot(2, 1, 1);
    grid on
    grid minor
    box on
    hold on
    cla

    Ax2 = subplot(2, 1, 2);
    grid on
    grid minor
    box on
    hold on
    cla

    Axes_arr = [Ax1 Ax2];
else
    Axes_arr = [];
end
end