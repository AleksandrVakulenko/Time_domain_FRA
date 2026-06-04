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
Fs = Channel_settings_1.fs; % NOTE: ch2 fs same as ch1

Underrange_force_2 = Channel_settings_2.underrange_force;
MAX_CH2_LIMIT = Channel_settings_2.max_ch1_limit;
Time_to_underrange_2 = Channel_settings_2.time_to_underrange;
Overrange_tolerance_2 = Channel_settings_2.overrange_tolerance;

Times_conf = Profile.times_conf;
Accuracy_conf = Profile.accuracy_conf;

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

Prefit_max_points = 10e3; % FIXME: magic constant
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

Outliers_range_1 = [];
Outliers_range_2 = [];

Prefit_need_1 = true;
Prefit_need_2 = true;
Prefit_ready_1 = false;
Prefit_ready_2 = false;
% -------------------------------------


% Common data -------------------------
stop = false;
Exit_flag = 0;
First_time = true;
Fit_local_timer = [];
Time_shift = 0;
% -------------------------------------
while ~stop
    %FIXME: debug for fast signal
    pause(0.001);

    [T_part, V1_part, V2_part] = FRA_dev.get_VV();
    V2_part = -V2_part; % NOTE: Aster ch2 inv

    % FIXME: debug
    if isempty(T_part)
        continue
%         stop = true;
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
        disp(['Overload Ch 1: ' num2str(Overload_1.volume*100, '%0.2f') ' %']) % FIXME: disp
    end
    if Overload_2.count > 0
        disp(['Overload Ch 2: ' num2str(Overload_2.volume*100, '%0.2f') ' %']) % FIXME: disp
    end

    Underrange_force_1 = true; % FIXME: debug for low input voltage level
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

    Time_to_overrange = 0.1; % [s] FIXME: magic constant
    if Time_passed > Time_to_overrange && Overload_1.volume > Overrange_tolerance_1
        Exit_flag = 201; % NOTE: EF 201: overrange
        break;
    end

    if Time_passed > Time_to_overrange && Overload_2.volume > Overrange_tolerance_2
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


    if Strategy.do_pre_fit
        Prefit_time_scale = 0.9;
    else
        Prefit_time_scale = 1;
    end

    Fit_time_step = prefit_time_step(Period);

    if true && Time_passed > Prefit_time_scale*Min_time && ...
            ( isempty(Fit_local_timer) || (~isempty(Fit_local_timer) && ...
            toc(Fit_local_timer) > Fit_time_step) )
        
        Fit_local_timer = tic;

        Ch_data_1 = fit_core.Ch_data(T_arr, V1_arr, Outliers_range_1, Overload_1, ...
            Estimations_1, Times_conf, Accuracy_conf, Fs, Periods_counter);

        Ch_data_2 = fit_core.Ch_data(T_arr, V2_arr, Outliers_range_2, Overload_2, ...
            Estimations_2, Times_conf, Accuracy_conf, Fs, Periods_counter);

        %  FIXME: !!! nyan
        Properties_1.Amp_type = "linear";
        Properties_1.BG_type = "poly2";
        Properties_1.Phi_type = "const";

        Properties_2.Amp_type = "const";
        Properties_2.BG_type = "poly2";
        Properties_2.Phi_type = "const";

        try % nyan
            
            if Prefit_need_1 && ~Prefit_ready_1
                disp('PREFIT CHANNEL 1') % FIXME: disp
                [Result_1] = fit_one_channels(Ch_data_1, Properties_1, ...
                    Harm_num, Prefit_max_points);
                [Outliers_range_1, Outliers_volume_1] = ...
                    fit_core.find_outliers(Ch_data_1, Result_1);
                [Score_1, ~] = fit_viewer.score_calc_ch(Result_1, Accuracy_conf);
                Estimations_1 = fit_core.result2estimation(Result_1);
                if Score_1 > 0
                    Prefit_ready_1 = true;
                end
                disp(['Score: ' num2str(Score_1)]); % FIXME: disp
            end

            if Prefit_need_2 && ~Prefit_ready_2
                disp('PREFIT CHANNEL 2') % FIXME: disp
                [Result_2] = fit_one_channels(Ch_data_2, Properties_2, ...
                    Harm_num, Prefit_max_points);
                [Outliers_range_2, Outliers_volume_2] = ...
                    fit_core.find_outliers(Ch_data_2, Result_2);
                [Score_2, ~] = fit_viewer.score_calc_ch(Result_2, Accuracy_conf);
                Estimations_2 = fit_core.result2estimation(Result_2);
                if Score_2 > 0
                    Prefit_ready_2 = true;
                end
                disp(['Score: ' num2str(Score_2)]); % FIXME: disp
            end

            if Prefit_need_1 && Prefit_need_2 && Prefit_ready_1 && Prefit_ready_2
                disp('PREFIT CHANNEL 1 AND 2') % FIXME: disp
                [Result_1, ~, ~, Result_2, ~, ~] = ...
                    fit_two_channels(Ch_data_1, Ch_data_2, Properties_1, ...
                    Properties_2, Harm_num, Prefit_max_points);

                [Outliers_range_1, Outliers_volume_1] = ...
                    fit_core.find_outliers(Ch_data_1, Result_1);
                [Outliers_range_2, Outliers_volume_2] = ...
                    fit_core.find_outliers(Ch_data_2, Result_2);

                [Score_1, Score2, ~, ~] = ...
                    fit_viewer.score_calc(Result_1, Result_2, Accuracy_conf);

                disp(['--- Scores: ---' newline 'Ch1: ' num2str(Score_1) newline ...
                    'Ch2: ' num2str(Score2) newline '---------------']) % FIXME: disp

                Estimations_1 = fit_core.result2estimation(Result_1);
                Estimations_2 = fit_core.result2estimation(Result_2);

                if Score_1 > 0 && Score2 > 0
                    stop = true;
                end
            end

        catch err
            warning('fit error')
            rethrow(err);
        end
    end

    if ~isempty(Fig)
        subplot(2, 1, 1)
        hold on
        cla
        plot(T_arr, V1_arr, '-b');
        plot(T_arr(Outliers_range_1), V1_arr(Outliers_range_1), '.k');
        grid on
%         grid minor
        title(['Ch 1 (PC: ' num2str(Periods_counter, '%0.3f') ')'])
        xlabel('t, s')
        ylabel('V1, V')

        subplot(2, 1, 2)
        hold on
        cla
        plot(T_arr, V2_arr, '-b');
        plot(T_arr(Outliers_range_2), V2_arr(Outliers_range_2), '.k');
        grid on
%         grid minor
        title('Ch 2')
        xlabel('t, s')
        ylabel('V2, V')

        drawnow
    end
end

Ch_data_1 = fit_core.Ch_data(T_arr, V1_arr, Outliers_range_1, Overload_1, ...
    Estimations_1, Times_conf, Accuracy_conf, Fs, Periods_counter);

Ch_data_2 = fit_core.Ch_data(T_arr, V2_arr, Outliers_range_2, Overload_2, ...
    Estimations_2, Times_conf, Accuracy_conf, Fs, Periods_counter);

end





function Fit_time_step = prefit_time_step(Period)
    Fit_time_step = 0.1*Period;
    if Fit_time_step > 10
        Fit_time_step = 10;
    end
    
    if Fit_time_step < 1
        Fit_time_step = 1;
    end
end


function Underrange = check_underrange(V_arr, Underrange, Underrange_force)
if Underrange
    [Mean, Span, ~, ~] = fit_core.singal_stats(V_arr);
    if Underrange_force
        Underrange_level = 0; % FIXME: remake it
    else
        Underrange_level = 0.01; % FIXME: magic constant
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
        disp('Underrange') % FIXME: disp
    end
end
end


function [Estimations] = do_estimations(Estimations, T_arr, V_arr, ...
    Freq, Periods_counter)

Period = 1/Freq;

% FIXME: do we need this?
if isempty(Estimations) && Periods_counter >= 1.0
    Init_values = fit_core.do_initial_estimation(T_arr, V_arr, Period);
    Result = fit_core.simple_sin_fit_f(T_arr, V_arr, ...
        Freq, Init_values);
    Estimations = Result;
end

switch signal_per_duration(Periods_counter)
    case "invalid" % 0 : 0.45
        % DO SOMETHING:
        % - noise analysis
        % pause(0.05*Period)

    case "get_lucky" % 0.45 : 0.5
        if isempty(Estimations)
            Init_values = fit_core.do_initial_estimation(T_arr, V_arr, Period);
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
        if isempty(Estimations)
            Init_values = fit_core.do_initial_estimation(T_arr, V_arr, Period);
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
        Result = fit_core.simple_sin_fit_f(T_arr, V_arr, ...
            Freq, Estimations);
        [out_time, out_sig] = fit_core.get_one_period(T_arr, V_arr, Period, ...
            "last", 1.05);
        Result2 = fit_core.DFT_estimation(out_time, out_sig, Period);
        Estimations = [Estimations Result Result2];


    case "long" % 2 : 10
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


function state = signal_per_duration(Periods_counter)

    state = "invalid";

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


function [Result_1, Residuals_1, DEBUG_1] = ...
    fit_one_channels(Ch_data, Properties, Harm_num, Max_points)

T_arr_1 = Ch_data.time;
V1_arr = Ch_data.voltage;
Outliers_range = Ch_data.outliers_range;
Fit_range = ~Outliers_range;
Overload_1 = Ch_data.overload;
Fs = Ch_data.fs;
Period = Ch_data.time_conf.period;
freq = 1/Period;


Harm_num_1 = Harm_num;

if Overload_1.count > 0
    Harm_num_1 = [];
end

Estimations_1 = fit_core.estimation_processing(Ch_data);

Fit_settings_1.freq_dev_flag = true; % FIXME: why it is true?
Fit_settings_1.freq_dev_const = 0;
Fit_settings_1.max_points = Max_points;

[Result_1, Residuals_1, DEBUG_1] = fit_channel(T_arr_1, V1_arr, ...
    Fit_range, Fs, freq, Estimations_1, Properties, Harm_num_1, Fit_settings_1);

end








