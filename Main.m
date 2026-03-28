

%% ------------------------------
clc

Gen_Voltage_level = 1; % [V]
Gen_Offset_level = 0; % [V]
Gen_freq = 0.5; % [Hz]

Save_data_flag = false;

Fs = 10e3; % FIXME: get from device!

%% Main part (Data gathering)

%--------------------------------
freq = Gen_freq;
Freq = freq;
Period = 1/freq;
Underrange_force = false;
Fig = figure('position', [471 217 690 691]);
Harm_num = [1 2 3];
MAX_CH1_LIMIT = 5;
MAX_CH2_LIMIT = 5;
Time_to_underrange = 0.1*Period; % [s]
Overrange_tolerance = 0; % [%]
Time_profile = "common"; % "ultra_fast", "common", "fine", "most_accurate"
Harm_profile = "common"; % "common", "most_accurate"
%--------------------------------

[Times_conf, Time_printer] = get_time_config_Aster(Period, Harm_num, ...
    Time_profile, Harm_profile);
Time_printer(); % FIXME: debug

%--------------------------------
% FIXME: undone legacy code; update by Time_profile
Accuracy_settings = struct();

% FIXME: debug
if Time_to_underrange < 0.3
    Time_to_underrange = 0.3; % FIXME: magic constant
end
%--------------------------------


% ----------------------------------------------------------------
Channel_settings_1.underrange_force = Underrange_force;
Channel_settings_1.max_ch1_limit = MAX_CH1_LIMIT;
Channel_settings_1.time_to_underrange = Time_to_underrange;
Channel_settings_1.overrange_tolerance = Overrange_tolerance;

Channel_settings_2.underrange_force = Underrange_force;
Channel_settings_2.max_ch1_limit = MAX_CH2_LIMIT;
Channel_settings_2.time_to_underrange = Time_to_underrange;
Channel_settings_2.overrange_tolerance = Overrange_tolerance;

Profile.times_conf = Times_conf;

% ----------------------------------------------------------------


%--------------------------------%--------------------------------%
clc

Gen = AFG1022_dev();
Gen.set_func("sin");
Gen.set_amp(Gen_Voltage_level, "amp");
Gen.set_freq(Gen_freq);
Gen.set_offset(Gen_Offset_level);
Gen.initiate();
Aster = Aster_dev(3);
Aster.set_connection_mode("I2V");
Aster.initiate();
[flag, R_Scale, Aster_Range] = Aster_set_range(Aster, 1);

ERR = [];
try
    FRA_dev = Aster;
    Try_num = 0;
    stop = false;
    while ~stop
        Try_num = Try_num + 1;
        disp(['Try num = ' num2str(Try_num)])
    
        Aster.CMD_data_stream(1);
    
        [Exit_flag, Ch_data_1, Ch_data_2] = data_gathering_loop(FRA_dev, ...
            Freq, Harm_num, Profile, Channel_settings_1, Channel_settings_2, Fig);
    
        Aster.CMD_data_stream(0);
        
        disp(['Exit flag: ' num2str(Exit_flag)])
    
        if Exit_flag == 0
            stop = true;
        elseif Exit_flag == 102
            Aster_Range = Aster_Range + 1;
            [flag, R_Scale, Aster_Range] = Aster_set_range(Aster, Aster_Range);
            if ~flag
                stop = true;
            end
        elseif Exit_flag == 202
            Aster_Range = Aster_Range - 1;
            [flag, R_Scale, Aster_Range] = Aster_set_range(Aster, Aster_Range);
            if ~flag
                stop = true;
            end
        elseif Exit_flag == 30
            stop = true;
        end
    end
catch ERR
    Aster.terminate();
    Gen.terminate();
    delete(Aster);
    delete(Gen);
    disp('ERR finish // devices closed')
    rethrow(ERR)
end

if isempty(ERR)
    Aster.terminate();
    Gen.terminate();
    delete(Aster);
    delete(Gen);
    disp('OK finish')
end

%
% FIT PART

%--------------------------------%--------------------------------%
T_arr = Ch_data_1.time;
V1_arr = Ch_data_1.voltage;
Overload_1 = Ch_data_1.overload;
Estimations_1 = Ch_data_1.estimations;

% T_arr = Ch_data_2.time; % NOTE: same as in CH1
V2_arr = Ch_data_2.voltage;
Overload_2 = Ch_data_2.overload;
Estimations_2 = Ch_data_2.estimations;
%--------------------------------%--------------------------------%

if Exit_flag == 0 % FIXME: debug
    disp(['Exit_flag: ' num2str(Exit_flag)]);
else
    for i = 1:10
        disp(['Exit_flag: ' num2str(Exit_flag)]);
    end
end


Time_length = T_arr(end) - T_arr(1);
Periods_counter = Time_length/Period;

Estimations_1 = fit_core.finish_estimations(Estimations_1, T_arr, V1_arr, Period);
Estimations_2 = fit_core.finish_estimations(Estimations_2, T_arr, V2_arr, Period);

Estimations_1 = estimation_fix(Estimations_1, Periods_counter, freq);
Estimations_2 = estimation_fix(Estimations_2, Periods_counter, freq);


Harm_num_1 = Harm_num;
Harm_num_2 = Harm_num;

if Overload_1.count > 0
    Harm_num_1 = [];
end

if Overload_2.count > 0
    Harm_num_2 = [];
end

if Exit_flag == 0 && Overload_1.count > 0
    error('FIXME: undone function')
%     T_arr = T_arr(~Overload_1.range);
%     V1_arr = V1_arr(~Overload_1.range);
end


%
% Fitting part
% clc

disp(['Start final fit:' newline])

% FIXME undone section
% "const" "linear" "poly2"
Properties_1.Amp_type = "linear";
Properties_1.BG_type = "poly2";
Properties_1.Phi_type = "const";

Properties_2.Amp_type = "const";
Properties_2.BG_type = "poly2";
Properties_2.Phi_type = "const";

Fit_settings_1.freq_dev_flag = true;
Fit_settings_1.freq_dev_const = 0;

disp('---- Channel 1: ----')
Time_start_1_fit = tic;
[Result_1, Residuals_1, DEBUG_1] = fit_channel(T_arr, V1_arr, Fs, freq, ...
    Estimations_1, Properties_1, Harm_num_1, Fit_settings_1);
Time_ch1_fit = toc(Time_start_1_fit);
disp(['--------------------' newline])


Fit_settings_2.freq_dev_flag = false;
Fit_settings_2.freq_dev_const = Result_1.f_dev_ppm;


disp('---- Channel 2: ----')
Time_start_2_fit = tic;
[Result_2, Residuals_2, DEBUG_2] = fit_channel(T_arr, V2_arr, Fs, freq, ...
    Estimations_2, Properties_2, Harm_num_2, Fit_settings_2);
Time_ch2_fit = toc(Time_start_2_fit);
disp('--------------------')


disp(' ')
disp(['Time to fit 1: ' num2str(Time_ch1_fit, '%0.2f') ' s'])
disp(['Time to fit 2: ' num2str(Time_ch2_fit, '%0.2f') ' s'])
disp(['Time full: ' num2str(Time_ch1_fit + Time_ch2_fit, '%0.2f') ' s' newline])


if isempty(Result_1)
    disp('No result on ch 1')
else
    disp('OK fit on ch1')
end

if isempty(Result_2)
    disp('No result on ch 2')
else
    disp('OK fit on ch2')
end

disp([newline 'Finish'])

if Save_data_flag
    Savedata = struct( ...
        'time', T_arr, ...
        'ch1', V1_arr, ...
        'ch2', [], ...
        'harm_est_1', Harm_est_1, ...
        'harm_est_2', [], ...
        'estimations', Estimations_1, ...
        'result', Result_1, ...
        'freq', Freq, ...
        'Synth_time', Synth_time, ... % FIXME: debug (must be replaced)
        'Synth_signal', Synth_signal, ... % FIXME: debug (must be replaced)
        'Props', Props ... % FIXME: debug (must be replaced)
        );
    
    Info = whos('Savedata');
    Size = Info.bytes/1024;
    if Size < 10e3
        disp(['File size: ' num2str(Size, '%.1f') ' kB']);
    else
        disp(['File size: ' num2str(Size/1024, '%.1f') ' MB']);
    end
end















%%

function [Result, Residuals, DEBUG] = fit_channel(T_arr, V_arr, Fs, freq, ...
    Estimations, Properties, Harm_num, Fit_settings)

if ~isempty(Estimations)

    if ~isempty(Harm_num)
        try % FIXME: debug
            Harm_est = fit_core.estimate_harmonics(T_arr, V_arr, Fs, freq, Harm_num);
        catch
            Harm_est = [];
        end
    else
        Harm_est = [];
    end

    % FIXME: check Harm_num here?
    Noise_freq_low = freq*max(Harm_num);
    Noise_rms = fit_core.noise_rms_calc(V_arr, Fs, Noise_freq_low);

    Max_points = 1000e3; % FIXME: magic constant
    % FIXME: upgrade function make_fs_lower
    % FIXME: make it single channel
    [T_arr, V_arr, ~, Fs2] = fit_core.make_fs_lower(T_arr, V_arr, V_arr, Fs, ...
        freq, Harm_num, Max_points);

    if Fs2 ~= Fs % FIXME: debug print
        disp(' ')
        warning(['Sampling freq reduced: ' num2str(Fs) ' -> ' num2str(Fs2)])
        disp(' ')
    end

    % NOTE: fit with harmonics estimations
    [Result, Residuals, DEBUG] = fit_core.any_sin_fit(T_arr, V_arr, freq, ...
        Estimations, Properties, Harm_est, Fit_settings);
    
    DEBUG.Fs_new = Fs2;
    DEBUG.T_arr_new = T_arr;

    Refit_flag = false;

    % NOTE: analize residuals here
    if ~isempty(Harm_num)
        Harm_est_2 = fit_core.estimate_harms_from_res(T_arr, Residuals, freq, ...
            Noise_rms, Harm_num);
    else
        Harm_est_2 = [];
    end
    
    if ~isempty(Harm_est_2) && ~isempty(Result.harm)
        Fitted_harm = Result.harm;
        for i = 1:numel(Harm_est_2)
            hn = Harm_est_2(i).n;
            ind = find([Fitted_harm.n] == hn);
            if ~isempty(ind)
                disp([num2str(i) ' : ' num2str(ind)])
                Fitted_harm(ind).amp = Fitted_harm(ind).amp + Harm_est_2(i).amp;
                Fitted_harm(ind).phi = Harm_est_2(i).phi;
            end
        end
        Refit_flag = true;
    end
    
    % NOTE: fit residuals here to find lost harms
    if Refit_flag
        [Result, Residuals, DEBUG] = fit_core.any_sin_fit(T_arr, V_arr, freq, ...
            Estimations, Properties, Fitted_harm, Fit_settings);
    end
    
else
    Result = [];
    Residuals = [];
    DEBUG = [];
end

end




function Result = do_initial_estimation(T_arr, V_arr, Period)
    [Mean, Span, ~, ~] = fit_core.singal_stats(V_arr);
    
    Start_Phi = fit_core.estimate_phi_part_sin(T_arr, V_arr, Period);
    if isempty(Start_Phi)
        Start_Phi = 0;
    end

    Result = fit_core.Estimation;
    Result.amp = Span;
    Result.phi = Start_Phi;
    Result.bg = Mean;
    Result.status = "ok";
    Result.source = "initial";
end





function state = signal_per_duration(Periods_counter)
    if Periods_counter > 0 && Periods_counter <= 0.45
        state = "invalid";
    end
    
    if Periods_counter > 0.45 && Periods_counter <= 0.5
        state = "get_lucky";
    end

    if Periods_counter > 0.5 && Periods_counter <= 1.0
        state = "min";
    end

    if Periods_counter > 1.0 && Periods_counter <= 2.0
        state = "single";
    end

    if Periods_counter > 2.0 && Periods_counter <= 10.0
        state = "long";
    end

    if Periods_counter > 10.0
        state = "max";
    end
end





function Estimations = estimation_fix(Estimations_all, Periods_counter, ...
    freq)

Legacy_status = [Estimations_all.legacy_status];

est_range_norm = Legacy_status == "";
est_range_low = Legacy_status == "low";
est_range_extra = Legacy_status == "extra";

Estimations = Estimations_all(est_range_norm);
Estimations_low = Estimations_all(est_range_low);
Estimations_extra = Estimations_all(est_range_extra);

% 
% disp('-----------')
% % FIXME: nyan
% Estimations
% isempty(Estimations)
% [Estimations.legacy_status]
% [Estimations_low.legacy_status]
% [Estimations_extra.legacy_status]
% disp('-----------')

Period = 1/freq;
% NOTE: delete early estimations
Est_time_min = [Estimations.t_max];
Est_time_max = [Estimations.t_max];

Est_status = "";
for i = 1:numel(Estimations)
    Est_status(i) = string(Estimations(i).status);
end
range2 = Est_status == "fixed";

if Periods_counter > 2
    range = Est_time_min < Period & Est_time_max < Period;
else
    range = Est_time_max < Period*0.5;
end

Estimations(range & ~range2) = [];

% NOTE: Replce estimations (is none) by bad estimations
if isempty(Estimations) && isempty(Estimations_low) && ...
        ~isempty(Estimations_extra)
    disp([newline '! YOLO FIT ! („• ֊ •„)' newline])
    Estimations = Estimations_extra;
elseif isempty(Estimations) && ~isempty(Estimations_low)
    disp([newline '! FIT by bad estimations ! ⸜(｡˃ ᵕ ˂ )⸝♡' newline])
    Estimations = Estimations_low;
else
    disp([newline '! OK, we have something ! (˶ᵔ ᵕ ᵔ˶) ‹𝟹' newline])
end

end




function [Estimations] = do_estimations(Estimations, T_arr, V_arr, ...
    Freq, Periods_counter)

Period = 1/Freq;

% FIXME: do we need this?
if isempty(Estimations) && Periods_counter >= 1.0
    Init_values = do_initial_estimation(T_arr, V_arr, Period);
    Result = fit_core.simple_sin_fit_f(T_arr, V_arr, ...
        Freq, Init_values);
    Estimations = Result;
end

switch signal_per_duration(Periods_counter)
    case "invalid" % 0 : 0.45
        disp("invalid") % FIXME: debug
        % DO SOMETHING:
        % - noise analysis
        % pause(0.05*Period)

    case "get_lucky" % 0.45 : 0.5
        disp("get_lucky") % FIXME: debug
        if isempty(Estimations)
            Init_values = do_initial_estimation(T_arr, V_arr, Period);
            Result = fit_core.simple_sin_fit_f(T_arr, V_arr, ...
                Freq, Init_values);
            Result.legacy_status = "extra";
            Estimations = Result;
        else
            Result = fit_core.simple_sin_fit_f(T_arr, V_arr, ...
                Freq, Estimations);
            Result.legacy_status = "extra";
            Estimations = [Estimations Result];
        end

    case "min" % 0.5 : 1.0
        disp("min") % FIXME: debug
        if isempty(Estimations)
            Init_values = do_initial_estimation(T_arr, V_arr, Period);
            Result = fit_core.simple_sin_fit_f(T_arr, V_arr, ...
                Freq, Init_values);
            Result.legacy_status = "low";
            Estimations = Result;
        else
            Result = fit_core.simple_sin_fit_f(T_arr, V_arr, ...
                Freq, Estimations);
            Result.legacy_status = "low";
            Estimations = [Estimations Result];
        end

    case "single" % 1.0 : 2
        disp("single") % FIXME: debug
        Result = fit_core.simple_sin_fit_f(T_arr, V_arr, ...
            Freq, Estimations);
        [out_time, out_sig] = fit_core.get_one_period(T_arr, V_arr, Period, ...
            "last", 1.05);
        Result2 = fit_core.DFT_estimation(out_time, out_sig, Period);
        Estimations = [Estimations Result Result2];


    case "long" % 2 : 10
        disp("long") % FIXME: debug
        [out_time, out_sig] = fit_core.get_one_period(T_arr, V_arr, Period, ...
            "last", 1.05);
        Result1 = fit_core.simple_sin_fit_f(out_time, out_sig, ...
            Freq, Estimations);
        Result2 = fit_core.DFT_estimation(out_time, out_sig, Period);
        Estimations = [Estimations Result1 Result2];


    case "max" % 10 : inf
        [out_time, out_sig] = fit_core.get_one_period(T_arr, V_arr, Period, ...
            "last", 1.05);
        Result = fit_core.DFT_estimation(out_time, out_sig, Period);
        Estimations = [Estimations Result];

end

end


function Underrange = check_underrange(V_arr, Underrange, Underrange_force)
if Underrange
    [Mean, Span, ~, ~] = fit_core.singal_stats(V_arr);
    if Underrange_force
        Underrange_level = 0.0001*5; % FIXME: magic constant
    else
        Underrange_level = 0.002*5; % FIXME: magic constant
    end
    % FIXME: bad (maybe) condition
    Cond1 = abs(Mean) < Underrange_level;
    Cond2 = Span < Underrange_level;

%     disp(['und_lvl: ' num2str(Underrange_level) newline ...
%         '  Mean = ' num2str(abs(Mean)) ' V' newline ...
%         '  Span = ' num2str(Span) ' V' newline ...
%         'C1 = ' num2str(Cond1) ' C2 = ' num2str(Cond2) newline])

    if ~Cond1 && ~Cond2
        Underrange = false;
    end
    if Underrange
        disp('Underrange') % FIXME: debug
    end
end
end





function [Exit_flag, Ch_data_1, Ch_data_2] = data_gathering_loop(FRA_dev, ...
    Freq, Harm_num, Profile, Channel_settings_1, Channel_settings_2, Fig)

arguments
    FRA_dev
    Freq
    Harm_num
    Profile
    Channel_settings_1
    Channel_settings_2
    Fig = []
end

Period = 1/Freq;
Harm_num(Harm_num == 1) = [];

% ----------------------------------------------------------------
Underrange_force_1 = Channel_settings_1.underrange_force;
MAX_CH1_LIMIT = Channel_settings_1.max_ch1_limit;
Time_to_underrange_1 = Channel_settings_1.time_to_underrange;
Overrange_tolerance_1 = Channel_settings_1.overrange_tolerance;

Underrange_force_2 = Channel_settings_2.underrange_force;
MAX_CH2_LIMIT = Channel_settings_2.max_ch1_limit;
Time_to_underrange_2 = Channel_settings_2.time_to_underrange;
Overrange_tolerance_2 = Channel_settings_2.overrange_tolerance;

Times_conf = Profile.times_conf;



% ----------------------------------------------------------------
Min_FOP = Times_conf.min_fop;
Max_FOP = Times_conf.max_fop;
Period = Times_conf.period;
Time_profile = Times_conf.time_profile;

Max_time = Max_FOP*Period;
Min_time = Min_FOP*Period;

if Max_time < 0.25 % [s]
    Strategy = struct('do_estimations', false, ...
                      'do_pre_fit', false);
elseif Max_time < 1 % [s]
    Strategy = struct('do_estimations', true, ...
                      'do_pre_fit', false);
else % Max_time >= 1 [s]
    Strategy = struct('do_estimations', true, ...
                      'do_pre_fit', true);
end

% ----------------------------------------------------------------


% Shared data -------------------------
T_arr = [];
V1_arr = [];
V2_arr = [];

% FIXME: need refactor
Estimations_1 = fit_core.Estimation.empty;
Estimations_2 = fit_core.Estimation.empty;

Underrange_1 = true;
Underrange_2 = true;

Overload_1 = struct('range', [], 'count', 0, 'volume', 0);
Overload_2 = struct('range', [], 'count', 0, 'volume', 0);
% -------------------------------------


% Common data -------------------------
stop = false;
Exit_flag = 0;
First_time = true;
% -------------------------------------
while ~stop
    %FIXME: debug for fast signal
    pause(0.001);

    [T_part, V1_part, V2_part] = FRA_dev.get_VV();
    V2_part = -V2_part; % NOTE: Aster ch2 inv

    % FIXME: debug
    if isempty(T_part)
        stop = true;
    end
    
    if First_time
        Time_shift = T_part(1);
        First_time = false;
    end
    T_part = T_part - Time_shift;

    T_arr = [T_arr T_part];
    V1_arr = [V1_arr V1_part];
    V2_arr = [V2_arr V2_part];

    Time_passed = T_arr(end);
    Periods_counter = Time_passed/Period;
    
    %--------------------------------
    OV_scale = 0.999; % FIXME: magic constant
    Overload_1.range = abs(V1_arr) > MAX_CH1_LIMIT * OV_scale;
    Overload_1.count = numel(find(Overload_1.range));
    Overload_1.volume = Overload_1.count/numel(V1_arr);
    
    Overload_2.range = abs(V2_arr) > MAX_CH2_LIMIT * OV_scale;
    Overload_2.count = numel(find(Overload_2.range));
    Overload_2.volume = Overload_2.count/numel(V2_arr);

    % FIXME: debug print
    if Overload_1.count > 0
        disp(['Overload Ch 1: ' num2str(Overload_1.volume*100, '%0.2f') ' %'])
    end
    if Overload_2.count > 0
        disp(['Overload Ch 2: ' num2str(Overload_2.volume*100, '%0.2f') ' %'])
    end

    Underrange_1 = check_underrange(V1_arr, Underrange_1, Underrange_force_1);
    Underrange_2 = check_underrange(V2_arr, Underrange_2, Underrange_force_2);

    if Underrange_1 && Time_passed > Time_to_underrange_1
        Exit_flag = 101; % NOTE: EF 101: underrange ch1
        break;
    end

    if Underrange_2 && Time_passed > Time_to_underrange_2
        Exit_flag = 102; % NOTE: EF 102: underrange ch2
        break;
    end

    if Time_passed > 0.3 && Overload_1.volume > Overrange_tolerance_1
        Exit_flag = 201; % NOTE: EF 201: overrange
        break;
    end

    if Time_passed > 0.3 && Overload_2.volume > Overrange_tolerance_2
        Exit_flag = 202; % NOTE: EF 202: overrange
        break;
    end

    if Time_passed > Max_time
        Exit_flag = 30; % NOTE: EF 3: Timeout_max
        break;
    end

    if Strategy.do_estimations
        Estimations_1 = do_estimations(Estimations_1, T_arr, V1_arr, ...
            Freq, Periods_counter);

        Estimations_2 = do_estimations(Estimations_2, T_arr, V2_arr, ...
            Freq, Periods_counter);
    end
    %--------------------------------

    if Time_passed > 0.9 * Min_time && Strategy.do_pre_fit
        % FIXME: do full fit here and save results
    end

    if Time_passed > Min_time
        % FIXME: do full fit here and save results
    end

    if ~isempty(Fig)
        subplot(2, 1, 1)
        cla
        plot(T_arr, V1_arr);
        title(['Ch 1 (PC: ' num2str(Periods_counter, '%0.3f') ')'])

        subplot(2, 1, 2)
        cla
        plot(T_arr, V2_arr);
        title('Ch 2')
        drawnow
    end
end

Ch_data_1.time = T_arr;
Ch_data_1.voltage = V1_arr;
Ch_data_1.overload = Overload_1;
Ch_data_1.estimations = Estimations_1;

Ch_data_2.time = T_arr;
Ch_data_2.voltage = V2_arr;
Ch_data_2.overload = Overload_2;
Ch_data_2.estimations = Estimations_2;

end
