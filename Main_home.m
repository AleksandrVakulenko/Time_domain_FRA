%% TEST FREQ LOOP

% FIXME: this function is beyond Real-time FRA module

% FIXME: add LCR terminate before start

LCR_type = {"LCR_E4980AL", []};
Aster_addr = 6;

Harm_num = [3];
Time_profile = "common"; % "ultra_fast", "common", "fine", "most_accurate"

Gen_Voltage_level = 1.0; % [V]
DC_bias = 0.0;
F_min = 0.1;
F_max = 200;
F_num = 60;
Noisy_env = true;
% Fixed_range = [5];

Freq_arr = fit_other.gen_freq_arr(F_min, F_max, F_num, ...
    "shuffle", "off", "repeat", 2);

Periods = 1./Freq_arr;
Periods = Periods*1.5;
Periods(Periods < 5) = 5;
sum(Periods)/60

%%
% Freq_arr = 0.1;

Sample.info = "test";



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

    Fixed_range = [];
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
errorbar(Freq_arr_plot_Aster, Res_Aster, Res_err_Aster, '.r')
% errorbar(Freq_arr_plot_Aster, Res_Aster.*Freq_arr_plot_Aster, Res_err_Aster.*Freq_arr_plot_Aster, '.r')
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






