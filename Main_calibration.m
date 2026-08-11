
clc

V_in = 5;
Freq = 0.00002;

Cap = 200e-12;


R_FB_arr = [200 10e3 1e6 100e6 10e9 1e12];

Range_N = 6;

Res_FB = R_FB_arr(Range_N);

C_res = 1./(2*pi*Freq*Cap);

Cur = V_in/C_res;

Vout = Cur*Res_FB;

disp(['Range : ' num2str(Range_N)])
disp(['V_in = ' num2str(V_in, '%0.2f') ' V'])
disp(['Freq = ' num2str(Freq, '%0.4f') ' Hz'])
disp(['Vout = ' num2str(Vout, '%0.3f') ' V'])


%% LONG (~14 hours)

Fixed_range_6 =     [6        6        6       6       6      6      6      6       6     6      6     6     6     6     6      6     6       6];
Gen_voltage_arr_6 = [5.00     4.00     4.00    3.00    3.00   1.00   0.75   0.40    0.35  0.25   0.16  0.10  0.06  0.03  0.02   0.02  0.02    0.015];
Freq_arr_6 =        [0.00006  0.00012  0.0002  0.0005  0.001  0.002  0.005  0.0075  0.01  0.013  0.02  0.03  0.05  0.10  0.125  0.15  0.175  0.2];
% Fixed_range_6 =     [6      6      6      6       6     6      6     6     6     6     6      6     6       6];
% Gen_voltage_arr_6 = [3.00   1.00   0.75   0.40    0.35  0.25   0.16  0.10  0.06  0.03  0.02   0.02  0.02    0.015];
% Freq_arr_6 =        [0.001  0.002  0.005  0.0075  0.01  0.013  0.02  0.03  0.05  0.10  0.125  0.15  0.175  0.2];

Fixed_range_5 =     [5      5     5     5     5     5     5    5     5     5];
Gen_voltage_arr_5 = [5.00   5.00  5.00  5.00  3.50  1.50  0.5  0.25  0.20  0.15];
Freq_arr_5 =        [0.005  0.01  0.02  0.05  0.1   0.2   0.5  1.0   1.5   2.0];

Fixed_range_4 =     [4     4     4     4     4     4     4     4     4     4     4     4     4];
Gen_voltage_arr_4 = [5.00  5.00  5.00  5.00  5.00  5.00  5.00  3.00  1.60  1.20  0.90  0.60  0.50];
Freq_arr_4 =        [0.02  0.1   0.2   0.5   1.0   2.0   5.0   10.0  20.0  30.0  40.0  60.0  70.0];

Fixed_range_3 =     [3    3    3    3    3    3    3    3    3    3    3     3     3     3     3     3     3     3];
Gen_voltage_arr_3 = [5.0  5.0  5.0  5.0  5.0  5.0  5.0  5.0  5.0  5.0  5.0   5.0   5.0   5.0   5.0   5.0   5.0   5.0];
Freq_arr_3 =        [2    5    10   20   30   40   60   70   80   90   110   120   130   140   160   170   180   195];

Fixed_range_arr = [Fixed_range_6 Fixed_range_5 Fixed_range_4 Fixed_range_3]; 
Gen_voltage_arr = [Gen_voltage_arr_6 Gen_voltage_arr_5 Gen_voltage_arr_4 Gen_voltage_arr_3];
Freq_arr = [Freq_arr_6 Freq_arr_5 Freq_arr_4 Freq_arr_3];

numel(Fixed_range_arr)
numel(Gen_voltage_arr)
numel(Freq_arr)

Periods = 1./Freq_arr;
Periods = Periods*1.5;
Periods(Periods < 5) = 5;
sum(Periods)/3600

%% MID (~9 hours)

Fixed_range_6 =     [6        6       6       6      6      6      6       6     6      6     6     6     6     6      6     6       6];
Gen_voltage_arr_6 = [4.00     4.00    3.00    3.00   1.00   0.75   0.40    0.35  0.25   0.16  0.10  0.06  0.03  0.02   0.02  0.02    0.015];
Freq_arr_6 =        [0.00008  0.0002  0.0005  0.001  0.002  0.005  0.0075  0.01  0.013  0.02  0.03  0.05  0.10  0.125  0.15  0.175  0.2];
% Fixed_range_6 =     [6      6      6      6       6     6      6     6     6     6     6      6     6       6];
% Gen_voltage_arr_6 = [3.00   1.00   0.75   0.40    0.35  0.25   0.16  0.10  0.06  0.03  0.02   0.02  0.02    0.015];
% Freq_arr_6 =        [0.001  0.002  0.005  0.0075  0.01  0.013  0.02  0.03  0.05  0.10  0.125  0.15  0.175  0.2];

Fixed_range_5 =     [5      5     5     5     5     5     5    5     5     5];
Gen_voltage_arr_5 = [5.00   5.00  5.00  5.00  3.50  1.50  0.5  0.25  0.20  0.15];
Freq_arr_5 =        [0.005  0.01  0.02  0.05  0.1   0.2   0.5  1.0   1.5   2.0];

Fixed_range_4 =     [4     4     4     4     4     4     4     4     4     4     4     4     4];
Gen_voltage_arr_4 = [5.00  5.00  5.00  5.00  5.00  5.00  5.00  3.00  1.60  1.20  0.90  0.60  0.50];
Freq_arr_4 =        [0.02  0.1   0.2   0.5   1.0   2.0   5.0   10.0  20.0  30.0  40.0  60.0  70.0];

Fixed_range_3 =     [3    3    3    3    3    3    3    3    3    3    3     3     3     3     3     3     3     3];
Gen_voltage_arr_3 = [5.0  5.0  5.0  5.0  5.0  5.0  5.0  5.0  5.0  5.0  5.0   5.0   5.0   5.0   5.0   5.0   5.0   5.0];
Freq_arr_3 =        [2    5    10   20   30   40   60   70   80   90   110   120   130   140   160   170   180   195];

Fixed_range_arr = [Fixed_range_6 Fixed_range_5 Fixed_range_4 Fixed_range_3]; 
Gen_voltage_arr = [Gen_voltage_arr_6 Gen_voltage_arr_5 Gen_voltage_arr_4 Gen_voltage_arr_3];
Freq_arr = [Freq_arr_6 Freq_arr_5 Freq_arr_4 Freq_arr_3];

numel(Fixed_range_arr)
numel(Gen_voltage_arr)
numel(Freq_arr)

Periods = 1./Freq_arr;
Periods = Periods*1.5;
Periods(Periods < 5) = 5;
sum(Periods)/3600

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
Scale = 1.0;
Freq_arr = Freq_arr*Scale;
Gen_voltage_arr = Gen_voltage_arr / Scale;
Gen_voltage_arr(Gen_voltage_arr > 5) = 5;

%% Flash

Fixed_range_6 =     [6     6     6];
Gen_voltage_arr_6 = [0.03  0.02  0.015];
Freq_arr_6 =        [0.1   0.15  0.2];

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
Scale = 1.0;
Freq_arr = Freq_arr*Scale;
Gen_voltage_arr = Gen_voltage_arr / Scale;
Gen_voltage_arr(Gen_voltage_arr > 5) = 5;

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
F_num = 200;
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


% Results_arr_PRE = Aster_FRA.pre_measurment(Resources, Aster_addr, Gen_Voltage_level, Ax_arr);
Results_arr_PRE = [];
% Zest = struct('type', 'cap', 'value', 10e-12);
% Zest = struct('type', 'res', 'value', 10e3);
disp('PRE MEASURMENTS FINISH')
pause(1);

Noisy_env = false;
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

    [Fit_Result, Extra_data] = Aster_FRA.single_freq_measurment(Resources, Aster_addr, ...
        Gen_freq, Gen_Voltage_level, DC_bias, Harm_num, Z_est, Time_profile, ...
        Ax_arr, Fixed_range, Self_cal_mode, Noisy_env);
    if ~isempty(Fit_Result) && Aster_FRA.FRA_results_check_valid(Fit_Result)
        Fit_Result.freq = Gen_freq;
        Result_arr_Aster = [Result_arr_Aster Fit_Result];
        Extra_data_arr = [Extra_data_arr Extra_data];
    end

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
Cap_arr = 1./(2*pi*Res_Aster.*Freq_arr_plot_Aster);
Cap_arr_err = abs(-1./(2*pi*Res_Aster.^2.*Freq_arr_plot_Aster).*Res_err_Aster);

subplot(2, 1, 1)
hold on
% errorbar(Freq_arr_plot_Aster, Res_Aster, Res_err_Aster, '.r')
% errorbar(Freq_arr_plot_Aster, Res_Aster.*Freq_arr_plot_Aster, Res_err_Aster.*Freq_arr_plot_Aster, '.r')
% errorbar(Freq_arr_plot_Aster, Cap_arr*1e12, Cap_arr_err*1e12, '.r')
plot(Freq_arr_plot_Aster, Cap_arr_err./Cap_arr*100, '.r')
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
errorbar(Freq_arr_plot_Aster, Phi_Aster, Phi_err_Aster, '.r', 'MarkerSize', 12)
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










