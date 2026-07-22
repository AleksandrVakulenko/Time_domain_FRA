
clc

V_in = 5.00;
Freq = 0.5;

Cap = 200e-12;


R_FB_arr = [200 10e3 1e6 100e6 10e9 1e12];

Range_N = 3;

Res_FB = R_FB_arr(Range_N);

C_res = 1./(2*pi*Freq*Cap);

Cur = V_in/C_res;

Vout = Cur*Res_FB;

disp(['Range : ' num2str(Range_N)])
disp(['V_in = ' num2str(V_in, '%0.2f') ' V'])
disp(['Freq = ' num2str(Freq, '%0.4f') ' Hz'])
disp(['Vout = ' num2str(Vout, '%0.3f') ' V'])


%% LONG

Fixed_range_6 =     [6       6      6      6     6     6     6     6     6     6];
Gen_voltage_arr_6 = [3.00    3.00   0.75   0.35  0.16  0.10  0.06  0.03  0.02  0.015];
Freq_arr_6 =        [0.0005  0.001  0.005  0.01  0.02  0.03  0.05  0.1   0.15  0.2];

Fixed_range_5 =     [5      5     5     5     5     5     5    5     5     5];
Gen_voltage_arr_5 = [5.00   5.00  5.00  5.00  3.50  1.50  0.5  0.25  0.20  0.15];
Freq_arr_5 =        [0.005  0.01  0.02  0.05  0.1   0.2   0.5  1.0   1.5   2.0];

Fixed_range_4 =     [4     4     4     4     4     4     4     4     4     4     4     4     4];
Gen_voltage_arr_4 = [5.00  5.00  5.00  5.00  5.00  5.00  5.00  3.00  1.60  1.20  0.90  0.60  0.50];
Freq_arr_4 =        [0.02  0.1   0.2   0.5   1.0   2.0   5.0   10.0  20.0  30.0  40.0  60.0  70.0];

Fixed_range_3 =     [3    3    3    3    3    3    3    3    3    3    3    3     3     3     3     3     3     3     3];
Gen_voltage_arr_3 = [5.0  5.0  5.0  5.0  5.0  5.0  5.0  5.0  5.0  5.0  5.0  5.0   5.0   5.0   5.0   5.0   5.0   5.0   5.0];
Freq_arr_3 =        [1    2    5    10   20   30   40   60   70   80   90   110   120   130   140   160   170   180   195];

Fixed_range_arr = [Fixed_range_6 Fixed_range_5 Fixed_range_4 Fixed_range_3]; 
Gen_voltage_arr = [Gen_voltage_arr_6 Gen_voltage_arr_5 Gen_voltage_arr_4 Gen_voltage_arr_3];
Freq_arr = [Freq_arr_6 Freq_arr_5 Freq_arr_4 Freq_arr_3];



%% SHORT

Fixed_range_6 =     [6      6     6     6     6     6     6     6];
Gen_voltage_arr_6 = [0.75   0.35  0.16  0.10  0.06  0.03  0.02  0.015];
Freq_arr_6 =        [0.005  0.01  0.02  0.03  0.05  0.1   0.15  0.2];

Fixed_range_5 =     [5     5     5     5     5     5    5     5     5];
Gen_voltage_arr_5 = [5.00  5.00  5.00  3.50  1.50  0.5  0.25  0.20  0.15];
Freq_arr_5 =        [0.01  0.02  0.05  0.1   0.2   0.5  1.0   1.5   2.0];

Fixed_range_4 =     [4     4     4     4     4     4     4     4     4     4     4     4];
Gen_voltage_arr_4 = [5.00  5.00  5.00  5.00  5.00  5.00  3.00  1.60  1.20  0.90  0.60  0.50];
Freq_arr_4 =        [0.1   0.2   0.5   1.0   2.0   5.0   10.0  20.0  30.0  40.0  60.0  70.0];

Fixed_range_3 =     [3    3    3    3    3    3    3    3    3    3    3    3     3     3     3     3     3     3     3];
Gen_voltage_arr_3 = [5.0  5.0  5.0  5.0  5.0  5.0  5.0  5.0  5.0  5.0  5.0  5.0   5.0   5.0   5.0   5.0   5.0   5.0   5.0];
Freq_arr_3 =        [1    2    5    10   20   30   40   60   70   80   90   110   120   130   140   160   170   180   195];

Fixed_range_arr = [Fixed_range_6 Fixed_range_5 Fixed_range_4 Fixed_range_3]; 
Gen_voltage_arr = [Gen_voltage_arr_6 Gen_voltage_arr_5 Gen_voltage_arr_4 Gen_voltage_arr_3];
Freq_arr = [Freq_arr_6 Freq_arr_5 Freq_arr_4 Freq_arr_3];

%% RANGE N 4

F_min = 0.05;
F_max = 70;
F_num = 100;
Freq_arr = fit_other.gen_freq_arr(F_min, F_max, F_num, ...
    "shuffle", "off", "repeat", 1);
Gen_voltage_arr_4 = 24.18./Freq_arr+0.3114;
Gen_voltage_arr_4(Gen_voltage_arr_4 > 5) = 5;
Fixed_range_arr = 4*ones(size(Freq_arr));


%% RANGE N 3

F_min = 0.5;
F_max = 200;
F_num = 100;
Freq_arr = fit_other.gen_freq_arr(F_min, F_max, F_num, ...
    "shuffle", "off", "repeat", 1);
Gen_voltage_arr = 5*ones(size(Freq_arr));
Fixed_range_arr = 3*ones(size(Freq_arr));


%% TEST FREQ LOOP

% FIXME: this function is beyond Real-time FRA module

% FIXME: add LCR terminate before start

LCR_type = {"LCR_E4980AL", []};
Aster_addr = 6;

Harm_num = [ ];
Time_profile = "fine"; % "ultra_fast", "common", "fine", "most_accurate"

Sample.info = "test";


Fig = fit_gui.init_Aster_FRA_gui();
Ax_arr = [Fig.UserData.axes_top Fig.UserData.axes_bot];
Stop_button = Fig.UserData.stop_button;
Resources.stop_button = Stop_button;
Resources.underrange_ind = Fig.UserData.underrange_ind;

% NOTE: terminate LCR
try
    LCR_dev = feval(LCR_type{1}, LCR_type{2});
    LCR_active = true;
catch
    LCR_active = false;
end

if LCR_active
    try
        LCR_dev.terminate;
    catch err
        delete(LCR_dev);
        rethrow(err);
    end
    delete(LCR_dev);
else
    disp('NO LCR device')
end


% Results_arr_PRE = pre_measurment(Resources, Aster_addr, Gen_Voltage_level, Ax_arr);
Results_arr_PRE = [];
% Zest = struct('type', 'cap', 'value', 10e-12);
% Zest = struct('type', 'res', 'value', 10e3);
disp('PRE MEASURMENTS FINISH')
pause(1);

Timer = tic;
Result_arr_Aster = [];
Extra_data_arr = [];
N = numel(Gen_voltage_arr);
for i = 1:N
    disp([num2str(i) '/' num2str(N)])

    Fixed_range = Fixed_range_arr(i);
    Gen_Voltage_level = Gen_voltage_arr(i);
    Gen_freq = Freq_arr(i);
    Self_cal_mode = true;
    DC_bias = 0;

    Zmodel = LCR_res_to_Zmodel(Result_arr_Aster, Results_arr_PRE);
    Z_est = struct('type', 'res', 'value', Zmodel(Gen_freq));

    [Fit_Result, Extra_data] = single_freq_measurment(Resources, Aster_addr, ...
        Gen_freq, Gen_Voltage_level, DC_bias, Harm_num, Z_est, Time_profile, ...
        Ax_arr, Fixed_range, Self_cal_mode);
    Fit_Result.freq = Gen_freq;
    Result_arr_Aster = [Result_arr_Aster Fit_Result];
    Extra_data_arr = [Extra_data_arr Extra_data];

    % FIXME: it is bad in shuffled freq array
end

Full_time = toc(Timer);
Time_to_compare = sum(2./Freq_arr);
disp(['Full time: ' num2str(Full_time/60, '%0.1f') ' min | NC_time ~ ' ...
    num2str(Time_to_compare/60, '%0.1f') ' min | ratio = ' ...
    num2str(Full_time/Time_to_compare, '%0.1f') ])



disp('Finish')

%%

figure('position', [468 218 686 783])


Freq_arr_plot_Aster = [Result_arr_Aster.freq];
Res_Aster = [Result_arr_Aster.res_abs];
Res_err_Aster = [Result_arr_Aster.res_abs_err];
Phi_Aster = [Result_arr_Aster.phi];
Phi_err_Aster = [Result_arr_Aster.phi_err];


subplot(2, 1, 1)
hold on
% errorbar(Freq_arr_plot_Aster, Res_Aster, Res_err_Aster, '.r')
errorbar(Freq_arr_plot_Aster, Res_Aster.*Freq_arr_plot_Aster, Res_err_Aster.*Freq_arr_plot_Aster, '.r')
% plot(Freq_arr_plot_Aster, 1./(2*pi*Res_Aster.*Freq_arr_plot_Aster)*1e12, '.r')
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











%% TEST MEASUREMENT FUNCTNION

function [Fit_Result, Extra_data] = single_freq_measurment(Resources, ...
    Aster_addr, Gen_freq, Gen_Voltage_level, DC_bias, Harm_num, Zest, Time_profile, ...
    Fig_or_ax, Fixed_range, Self_cal_mode)

%--------------------------------
Freq = Gen_freq;
Gen_Offset_level = DC_bias; % [V] % FIXME: unused
Harm_profile = "common"; % "common", "most_accurate"
Use_power_line_filter = false; % FIXME: must be an argument
%--------------------------------

Settings.amp = Gen_Voltage_level;
Settings.freq = Gen_freq;
Settings.dc = Gen_Offset_level;
Settings.harm_num = Harm_num;
Settings.time_profile = Time_profile;
Settings.harm_profile = Harm_profile;
Settings.use_power_line_filter = Use_power_line_filter;

% Measurement part
[Exit_flag, Ch_data_1, Ch_data_2, R_Scale, Accuracy_conf, ...
    Used_ranges, Aster_range] = Aster_FRA.measure(Resources, Aster_addr, ...
    Settings, Fig_or_ax, Zest, Fixed_range, Self_cal_mode);

warning(['>>>>>> Exit_flag: ' num2str(Exit_flag) ' >>>>>>>>']); % FIXME: disp

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






function Results_arr_PRE = pre_measurment(Resources, Aster_addr, Gen_Voltage_level, Ax_arr)
% NOTE: bad version
% FIXME: it is bad to estimate on single point
    Harm_num = [1 2 3];
    Gen_freq = [1 70];
    DC_bias = 0;
    Time_profile = 'ultra_fast';
    Zest = struct('type', 'res', 'value', 50e3); % FIXME: magic constant
    Fit_Result_1 = single_freq_measurment(Resources, Aster_addr, ...
        Gen_freq(1), Gen_Voltage_level, DC_bias, Harm_num, Zest, Time_profile, Ax_arr, [], false);

    Fit_Result_2 = single_freq_measurment(Resources, Aster_addr, ...
        Gen_freq(2), Gen_Voltage_level, DC_bias, Harm_num, Zest, Time_profile, Ax_arr, [], false);
    
    Results_arr_PRE = [Fit_Result_1 Fit_Result_2];
    
    
    % --- FXIME: debug section ---
%     Res = Fit_Result.res_abs;
%     Cap = 1/(2*pi*Res*Gen_freq);
%     Zest = struct('type', 'cap', 'value', Cap);
    % --- NOTE: end of debug section ---

%     Zest = struct('type', 'res', 'value', Fit_Result.res_abs);
end




