%% TEST FREQ LOOP

% FIXME: this function is beyond Real-time FRA module

% FIXME: add LCR terminate before start

LCR_type = {"LCR_E4980AL", []};
Aster_addr = 3;

Harm_num = [ ];
Time_profile = "fine"; % "ultra_fast", "common", "fine", "most_accurate"

Gen_Voltage_level = 1.0; % [V]
DC_bias = 0.0;
F_min = 0.1;
F_max = 300e3;
F_num = 25;
Noisy_env = true;

% Fixed_range = [5];

Freq_arr = fit_other.gen_freq_arr(F_min, F_max, F_num, ...
    "shuffle", "on", "repeat", 1);
% Freq_arr = 0.1;

Sample.info = "test";

Fixed_range = [ ];
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

Fig = fit_gui.init_Aster_FRA_gui();
Ax_arr = [Fig.UserData.axes_top Fig.UserData.axes_bot];
Stop_button = Fig.UserData.stop_button;
Resources.stop_button = Stop_button;
Resources.underrange_ind = Fig.UserData.underrange_ind;

% NOTE: terminate LCR
LCR_dev = feval(LCR_type{1}, LCR_type{2});
try
    LCR_dev.terminate;
catch err
    delete(LCR_dev);
    rethrow(err);
end
delete(LCR_dev);

Results_arr_PRE = Aster_FRA.pre_measurment(Resources, Aster_addr, Gen_Voltage_level, Ax_arr);
% Zest = struct('type', 'cap', 'value', 10e-12);
% Zest = struct('type', 'res', 'value', 10e3);
disp('PRE MEASURMENTS FINISH')
pause(1);

Timer = tic;
Result_arr_Aster = [];
Extra_data_arr = [];
N = numel(Freq_arr_Aster);
for i = 1:N
    disp([num2str(i) '/' num2str(N)])

    Gen_freq = Freq_arr_Aster(i);
%     Gen_Voltage_level = Voltage_amp_arr(i);

    Zmodel = LCR_res_to_Zmodel(Result_arr_Aster, Results_arr_PRE);
    Z_est = struct('type', 'res', 'value', Zmodel(Gen_freq));

    [Fit_Result, Extra_data] = Aster_FRA.single_freq_measurment(Resources, Aster_addr, ...
        Gen_freq, Gen_Voltage_level, DC_bias, Harm_num, Z_est, Time_profile, ...
        Ax_arr, Fixed_range, false, Noisy_env);
    if ~isempty(Fit_Result) && Aster_FRA.FRA_results_check_valid(Fit_Result)
        Fit_Result.freq = Gen_freq;
        Result_arr_Aster = [Result_arr_Aster Fit_Result];
        Extra_data_arr = [Extra_data_arr Extra_data];
    end

    % FIXME: it is bad in shuffled freq array
end

Full_time = toc(Timer);
Time_to_compare = 2./Freq_arr_Aster;
Time_to_compare(Time_to_compare < 1) = 1;
Time_to_compare = sum(Time_to_compare);
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
    LCR_Result = Aster_FRA.LCR_measure(LCR_type, Gen_freq, Gen_Voltage_level, Time_profile);
    LCR_Result.freq = Gen_freq;
    Result_arr_LCR = [Result_arr_LCR LCR_Result];
end

disp('Finish')

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
% errorbar(Freq_arr_plot_LCR, Res_LCR, Res_err_LCR, '.b')
% errorbar(Freq_arr_plot_Aster, Res_Aster, Res_err_Aster, '.r')

% errorbar(Freq_arr_plot_LCR, Res_LCR.*Freq_arr_plot_LCR, Res_err_LCR.*Freq_arr_plot_LCR, '.b')
% errorbar(Freq_arr_plot_Aster, Res_Aster.*Freq_arr_plot_Aster, Res_err_Aster.*Freq_arr_plot_Aster, '.r')
plot(Freq_arr_plot_LCR, 1./(2*pi*Res_LCR.*Freq_arr_plot_LCR)*1e12, '.b')
plot(Freq_arr_plot_Aster, 1./(2*pi*Res_Aster.*Freq_arr_plot_Aster)*1e12, '.r')
% plot(Res./Res*100, '-b')
% plot((Res+Res_err)./Res*100, '--b')
% plot((Res-Res_err)./Res*100, '--b')
% ylabel('|Cap|, pF')
ylabel('|R|, Ohm')
xlabel('f, Hz')
set(gca, 'xscale', 'log')
set(gca, 'yscale', 'log')
grid on
grid minor
box on

subplot(2, 1, 2)
hold on
errorbar(Freq_arr_plot_LCR, Phi_LCR, Phi_err_LCR, '.b')
errorbar(Freq_arr_plot_Aster, Phi_Aster, Phi_err_Aster, '.r')
% plot(Freq_arr_plot_Aster, abs(tan((Phi_Aster+90)/180*pi)), '.b')
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





