%% TEST FREQ LOOP

% FIXME: this function is beyond Real-time FRA module

% FIXME: add LCR terminate before start

LCR_type = Aster_FRA_helper.LCR_device_name_type("LCR_E4980AL", []);
% LCR_type = Aster_FRA_helper.LCR_device_name_type.empty;

if ispc
    Aster_addr = 6;
elseif isunix
    Aster_addr = "/dev/ttyACM0"; % FIXME: debug
end

Harm_num = [3];
Time_profile = "most_accurate"; % "ultra_fast", "common", "fine", "most_accurate"

Gen_Voltage_level = 0.001; % [V]
DC_bias = 0.0;
% F_min = 0.1;
% F_max = 200;
% F_num = 45;

F_min = 0.02;
F_max = 0.02;
F_num = 1;

% F_min = 0.005;
% F_max = 200;
% F_num = 80;

Noisy_env = true;

Freq_arr = TDFRA_fit_other.gen_freq_arr(F_min, F_max, F_num, ...
    "shuffle", "off", "repeat", 1, 'correction', 'max');

% Freq_arr = 0.005;

Time_prediction_m = Aster_FRA_helper.time_prediction(Freq_arr, Time_profile);
disp(['Time prediction: ' num2str(Time_prediction_m, '%0.1f') ' min']);

%%

% NOTE: run GUI
Fig = TDFRA_fit_gui.init_Aster_FRA_gui();
Ax_arr = [Fig.UserData.axes_top Fig.UserData.axes_bot];
Stop_button = Fig.UserData.stop_button;
Resources.stop_button = Stop_button;
Resources.underrange_ind = Fig.UserData.underrange_ind;
% FIXME: (1) place Ax_arr to Resourses
% Resources = [];

% FIXME: make it static and abstract:
% Limits = LCR_dev.get_max_amp_and_freq();
Aster_highest_freq = 200; % FIXME: get from instrument
LCR_lowest_freq = 20; % FIXME: get from instrument

F_range_Aster = Freq_arr <= Aster_highest_freq; 
F_range_LCR = Freq_arr >= LCR_lowest_freq; 

Freq_arr_Aster = Freq_arr(F_range_Aster);
Freq_arr_LCR = Freq_arr(F_range_LCR);

if ~isempty(Freq_arr_LCR)
    LCR_avilable = Aster_FRA_helper.check_LCR_avilable(LCR_type);
    if ~LCR_avilable
        warning('LCR dev anavilable'); % FIXME: disp
    end
else
    % USED is flag what we dont need an LCR measurments
    LCR_avilable = false; 
end


% NOTE: run LCR first if possible
Result_arr_LCR = Aster_FRA.LCR_result_type.empty;
if LCR_avilable
    Aster_FRA.switch_to_LCR(Aster_addr);
   
    N = numel(Freq_arr_LCR);
    for i = 1:N
        disp([newline 'LCR freq list: ' num2str(i) '/' num2str(N)]); % FIXME: disp

        Gen_freq = Freq_arr_LCR(i);
        LCR_Result = Aster_FRA.LCR_measure(LCR_type, Gen_freq, Gen_Voltage_level, Time_profile);
        LCR_Result.freq = Gen_freq;
        Result_arr_LCR = [Result_arr_LCR LCR_Result];
    end
end

% NOTE: terminate LCR
if LCR_avilable
    Aster_FRA_helper.LCR_terminate(LCR_type);
end


% NOTE: do not do pre measurments if LCR results avilable in freq range
%   in range from 20 Hz to 200 Hz
flag = Aster_FRA_helper.is_LCR_results_valid_as_pre(Result_arr_LCR);
if ~flag
    disp(['RUN MEASURMENTS FINISH' newline]) % FIXME: disp
    Results_arr_PRE = Aster_FRA.pre_measurment(Resources, Aster_addr, ...
        Gen_Voltage_level, Ax_arr);
    disp(['PRE MEASURMENTS FINISH' newline]) % FIXME: disp
else
    Results_arr_PRE = Result_arr_LCR;
end

Timer = tic;
Result_arr_Aster = Aster_FRA.LCR_result_type.empty;
Extra_data_arr = Aster_FRA.LCR_extra_data_type.empty;
N = numel(Freq_arr_Aster);
for i = 1:N
    disp([newline 'Aster freq list: ' num2str(i) '/' num2str(N)]); % FIXME: disp

    Gen_freq = Freq_arr_Aster(i);
%     Gen_Voltage_level = Voltage_amp_arr(i);

    Zmodel = Aster_FRA.LCR_res_to_Zmodel(Result_arr_Aster, Results_arr_PRE);
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

% FIXME: debug section
Full_time = toc(Timer);
Time_to_compare = 2./Freq_arr_Aster;
Time_to_compare(Time_to_compare < 1) = 1;
Time_to_compare = sum(Time_to_compare);
disp(['Full time: ' num2str(Full_time/60, '%0.1f') ' min | NC_time ~ ' ...
    num2str(Time_to_compare/60, '%0.1f') ' min | ratio = ' ...
    num2str(Full_time/Time_to_compare, '%0.1f') ])
disp(['Time prediction: ' num2str(Time_prediction_m, '%0.1f') ' min']);



disp('Finish')




%% Fit result recalc (FIXME: create recalc function)

Result_arr_Aster = [];
for i = 1:numel(Extra_data_arr)
    
    Result_1 = Extra_data_arr(i).result_1;
    Result_2 = Extra_data_arr(i).result_2;
    Freq = Result_1.freq;
    Aster_range = Extra_data_arr(i).aster_range;
    if ~isempty(Result_1) && ~isempty(Result_2)
        Fit_Result_new = Aster_FRA.do_FRA_result(Result_1, Result_2, Freq, Aster_range);
        Fit_Result_new.freq = Freq;
    else
        Fit_Result_new = []; % FIXME: use FRA type
    end

    Result_arr_Aster = [Result_arr_Aster Fit_Result_new];

end

% Fit_Result.freq = Gen_freq;

%%

figure('position', [468 218 686 783])


Freq_arr_plot_Aster = [Result_arr_Aster.freq];
Res_Aster = [Result_arr_Aster.res_abs];
Res_err_Aster = [Result_arr_Aster.res_abs_err];
Phi_Aster = [Result_arr_Aster.phi];
Phi_err_Aster = [Result_arr_Aster.phi_err];
Cap_arr = 1./(2*pi*Res_Aster.*Freq_arr_plot_Aster);
Cap_arr_err = -1./(2*pi*Res_Aster.^2.*Freq_arr_plot_Aster).*Res_err_Aster;

subplot(2, 1, 1)
hold on
% errorbar(Freq_arr_plot_Aster, Res_Aster, Res_err_Aster, '.r')
% errorbar(Freq_arr_plot_Aster, Res_Aster.*Freq_arr_plot_Aster, Res_err_Aster.*Freq_arr_plot_Aster, '.r')
errorbar(Freq_arr_plot_Aster, Cap_arr*1e12, Cap_arr_err*1e12, '.r')
% plot(Res./Res*100, '-b')
% plot((Res+Res_err)./Res*100, '--b')
% plot((Res-Res_err)./Res*100, '--b')
ylabel('|Cap|, pF')
ylabel('|R|, Ohm')
xlabel('f, Hz')
set(gca, 'xscale', 'log')
% set(gca, 'yscale', 'log')
grid on
grid minor
box on
% xline([45 55], 'LineWidth', 2)

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






