%% TEST FREQ LOOP

% FIXME: this function is beyond Real-time FRA module

% FIXME: add LCR terminate before start

Aster_addr = 3;

Harm_num = [ ];
Time_profile = "fine"; % "ultra_fast", "common", "fine", "most_accurate"

Gen_Voltage_level = 2; % [V]
F_min = 0.05;
F_max = 300e3;
F_num = 60;

% Fixed_range = [5];

Freq_arr = 10.^linspace(log10(F_min), log10(F_max), F_num);
% Freq_arr = 0.5;

Sample.info = "test";

Fixed_range = [];
Run_num = 2;

% Fixed_range = 6;
% Cal_cap_N = 1; % 10 pF
% Voltage_amp_arr = [    10    10    10     5      3      1    0.5   0.25  ];
% Freq_arr =        [0.001  0.002  0.005  0.01  0.02   0.05   0.1   0.2  ];

% Fixed_range = 4;
% Cal_cap_N = 3; % 1 nF
% Freq_arr =        [0.05   0.1    0.2   0.5   1    2   4   8   22    55    95];
% Voltage_amp_arr = ones(size(Freq_arr))*5;
% Voltage_amp_arr = [2  2  2  2  2];
% Freq_arr =        [95    125    140   180  195];

% Fixed_range = 4;
% Cal_cap_N = 3; % 1 nF
% Voltage_amp_arr = [  10    10     10    10     10    10    5    5   5  5   2.5  1  0.5];
% Freq_arr =        [0.01   0.02   0.05   0.1    0.2   0.5   1    2   4   8   22    55    69];


F_range_Aster = Freq_arr <= 200;
F_range_LCR = Freq_arr >= 20;

Freq_arr_Aster = Freq_arr(F_range_Aster);
Freq_arr_LCR = Freq_arr(F_range_LCR);

Fig = fit_gui.init_FRA_gui();
Ax_arr = [Fig.UserData.axes_top Fig.UserData.axes_bot];
Stop_button = Fig.UserData.stop_button;
Resources.stop_button = Stop_button;


Z_est = pre_measurment(Resources, Aster_addr, Gen_Voltage_level, Ax_arr);
% Zest = struct('type', 'cap', 'value', 10e-12);
% Zest = struct('type', 'res', 'value', 10e3);

Timer = tic;
Result_arr_Aster = [];
Extra_data_arr = [];
N = numel(Freq_arr_Aster);
for i = 1:N
    disp([num2str(i) '/' num2str(N)])

    Gen_freq = Freq_arr_Aster(i);
%     Gen_Voltage_level = Voltage_amp_arr(i);
    [Fit_Result, Extra_data] = Test_measurment_function(Resources, Aster_addr, ...
        Gen_freq, Gen_Voltage_level, Harm_num, Z_est, Time_profile, Ax_arr, Fixed_range);
    Fit_Result.freq = Gen_freq;
    Result_arr_Aster = [Result_arr_Aster Fit_Result];
    Extra_data_arr = [Extra_data_arr Extra_data];

    Z_est = struct('type', 'res', 'value', Fit_Result.res_abs);
end

Full_time = toc(Timer);
Time_to_compare = sum(2./Freq_arr_Aster);
disp(['Full time: ' num2str(Full_time/60, '%0.1f') ' min | NC_time ~ ' ...
    num2str(Time_to_compare/60, '%0.1f') ' min | ratio = ' ...
    num2str(Full_time/Time_to_compare, '%0.1f') ])


if ~isempty(Fixed_range)
    Save_file = ['Calibration_data_2/' 'C' num2str(Fixed_range, '%02d') ...
        '_' num2str(Run_num, '%02d') '.mat'];
    save(Save_file, "Result_arr_Aster", "Extra_data_arr", "Voltage_amp_arr", ...
        "Freq_arr_Aster", "Full_time", "Sample")
end

Aster_FRA.switch_to_LCR(Aster_addr);

Result_arr_LCR = [];
N = numel(Freq_arr_LCR);
for i = 1:N
    disp([num2str(i) '/' num2str(N)])

    Gen_freq = Freq_arr_LCR(i);
    LCR_Result = Aster_FRA.LCR_measure(Gen_freq, Gen_Voltage_level, Time_profile);
    LCR_Result.freq = Gen_freq;
    Result_arr_LCR = [Result_arr_LCR LCR_Result];
end


%%

figure('position', [468 218 686 783])

Freq_arr_plot_LCR = [Result_arr_LCR.freq];
Res_LCR = [Result_arr_LCR.res_abs];
Res_err_LCR = [Result_arr_LCR.res_abs_err];
Phi_LCR = [Result_arr_LCR.phi];
Phi_err_LCR = [Result_arr_LCR.phi_err];

Freq_arr_plot_Aster = [Result_arr_Aster.freq];
Res_Aster = [Result_arr_Aster.res_abs];
Res_err_Aster = [Result_arr_Aster.res_abs_err];
Phi_Aster = [Result_arr_Aster.phi];
Phi_err_Aster = [Result_arr_Aster.phi_err];

subplot(2, 1, 1)
hold on
% errorbar(Freq_arr_plot_LCR, Res_LCR, Res_err_LCR, '-.b')
% errorbar(Freq_arr_plot_Aster, Res_Aster, Res_err_Aster, '--.r')
plot(Freq_arr_plot_LCR, 1./(2*pi*Res_LCR.*Freq_arr_plot_LCR)*1e12, '.-b')
plot(Freq_arr_plot_Aster, 1./(2*pi*Res_Aster.*Freq_arr_plot_Aster)*1e12, '.-r')
% plot(Res./Res*100, '-b')
% plot((Res+Res_err)./Res*100, '--b')
% plot((Res-Res_err)./Res*100, '--b')
% ylabel('|Cap|, pF')
ylabel('|R|, Ohm')
xlabel('f, Hz')
set(gca, 'xscale', 'log')
% set(gca, 'yscale', 'log')
grid on
grid minor
box on

subplot(2, 1, 2)
hold on
errorbar(Freq_arr_plot_LCR, Phi_LCR, Phi_err_LCR, '.-b')
errorbar(Freq_arr_plot_Aster, Phi_Aster, Phi_err_Aster, '.--r')
% plot(Freq_arr_plot_Aster, abs(tan((Phi_Aster+90)/180*pi)))
% plot(Freq_arr, Phi_err)
% plot(Phi_err, '--b')
ylabel('Phi, deg')
xlabel('f, Hz')
set(gca, 'xscale', 'log')
grid on
grid minor
box on


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











%% TEST MEASUREMENT FUNCTNION

function [Fit_Result, Extra_data] = Test_measurment_function(Resources, ...
    Aster_addr, Gen_freq, Gen_Voltage_level, Harm_num, Zest, Time_profile, ...
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
    Used_ranges, Aster_range] = Aster_FRA.measure(Resources, Aster_addr, ...
    Settings, Fig_or_ax, Zest, Fixed_range);

warning(['>>>>>> Exit_flag: ' num2str(Exit_flag) ' >>>>>>>>']); % FIXME: disp

if Exit_flag == 40
    % FIXME: debug way to finish by stop button
    error('The program has been terminated by the user.')
end

% Fitting part
Period_counter = Ch_data_1.period_counter;

[Properties_1, Properties_2] = fit_core.get_fit_props(Period_counter);

Max_points = 50e3; % FIXME: magic constant

[Result_1, Residuals_1, DEBUG_1, Result_2, Residuals_2, DEBUG_2] = ...
    fit_core.fit_two_channels(Ch_data_1, Ch_data_2, Properties_1, Properties_2, ...
    Harm_num, Max_points);

[Score_1, Score_2, Best_flag, Max_score] = ...
    fit_viewer.score_calc(Result_1, Result_2, Accuracy_conf);

disp([newline 'Scores:' newline 'Ch1: ' num2str(Score_1) newline ...
    'Ch2: ' num2str(Score_2)]) % FIXME: disp

% Final plot part
Axes_arr = fit_gui.init_gather_axes(Fig_or_ax);
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
    Fit_Result = Aster_FRA.do_FRA_result(Result_1, Result_2, Freq, Aster_range);
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






function Zest = pre_measurment(Resources, Aster_addr, Gen_Voltage_level, Ax_arr)
% NOTE: bad version
% FIXME: it is bad to estimate on single point
    Harm_num = [1 2 3];
    Gen_freq = 1;
    Time_profile = 'ultra_fast';
    Zest = struct('type', 'res', 'value', 50e3);
    [Fit_Result, Extra_data] = Test_measurment_function(Resources, Aster_addr, ...
        Gen_freq, Gen_Voltage_level, Harm_num, Zest, Time_profile, Ax_arr, []);

    Zest = struct('type', 'res', 'value', Fit_Result.res_abs);
end




