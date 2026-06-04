

%% Fern load

Fern.load('aDevice')
Fern.load('FRA_tools')
Fern.load('Common') 


%% ------------------------------
clc

Gen_Voltage_level = 0.2; % [V]
Gen_Offset_level = 0; % [V]
Gen_freq = 2; % [Hz]

Save_data_flag = false;

Aster_addr = 3;

Time_profile = "most_accurate"; % "ultra_fast", "common", "fine", "most_accurate"
Harm_profile = "common"; % "common", "most_accurate"

%--------------------------------
Freq = Gen_freq;
Harm_num = [1 2 3];
Fig = figure('position', [471 217 690 691]);
Cap_exp = 1e-9;
%--------------------------------



%% Main part (Data gathering)


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

[Score1, Score2, Best_flag, Max_score] = ...
    fit_viewer.score_calc(Result_1, Result_2, Accuracy_conf);

disp([newline 'Scores:' newline 'Ch1: ' num2str(Score1) newline ...
    'Ch2: ' num2str(Score2)]) % FIXME: disp


% FIXME: use debug function to show results
Result = fit_viewer.show_result_debug(Result_1, Result_2, Freq,  R_Scale);






% Data save part

% FIXME: undone
% if Save_data_flag
%     Savedata = struct( ...
%         'time', T_arr, ...
%         'ch1', V1_arr, ...
%         'ch2', [], ...
%         'harm_est_1', Harm_est_1, ...
%         'harm_est_2', [], ...
%         'estimations', Estimations_1, ...
%         'result', Result_1, ...
%         'freq', Freq, ...
%         'Synth_time', Synth_time, ... % FIXME: debug (must be replaced)
%         'Synth_signal', Synth_signal, ... % FIXME: debug (must be replaced)
%         'Props', Props ... % FIXME: debug (must be replaced)
%         );
%     
%     Info = whos('Savedata');
%     Size = Info.bytes/1024;
%     if Size < 10e3
%         disp(['File size: ' num2str(Size, '%.1f') ' kB']); % FIXME: disp
%     else
%         disp(['File size: ' num2str(Size/1024, '%.1f') ' MB']); % FIXME: disp
%     end
% end



