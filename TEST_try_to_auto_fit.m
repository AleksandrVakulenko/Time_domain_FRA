% ------------------------------------------------------------------------------
%
%       ꧁⎝ 𓆩༺✧༻𓆪 ⎠꧂      ꧁⎝ 𓆩༺✧༻𓆪 ⎠꧂      ꧁⎝ 𓆩༺✧༻𓆪 ⎠꧂
%
%
% TODO:
% 1) Add second channel
% 2) Update signal gen to use two channels
% 3) [update sig_gen:] add underrange (span and mean) test signals
% 4) finish make_fs_lower()
% 5) add new data viewer
% 6) 
% 7) Add non-realtime version of fit
% 8)
% 9) use Estimations for Properties
% 10) use incoming estimations
% 11) add errors must be 3*std
% 12) use FFT or DFT for 50 Hz rejection
% 13) analize residuals more (for what?)
% 14) DFT vs fft problem (calculating many DFTs)
% 15) phase around -180[deg] problem
% 16) place fft functions to its own lib
% 17) make Fern module
% 18)
%
% ------------------------------------------------------------------------------
clc

Save_data_flag = false;
freq = 2;
Freq_dev = 0;
Duration = 3;
Fs = 10e3;
Profile = 'mid';
% Traits = ["nobg", "zerophi", 'nonoise', "lownoise", "constphi"];
Traits = ["lownoise", "", ""];
Seed = '';
% LLGUHH (small signal)
% IOTSCV (Phase test)
% VHJLJS (O_O)
% HDNPYV
% QDQFFM
% CUSAIQ ???
% AQIOEZ overload test
% YYSRCS

[Synth_time, Synth_signal, Props] = test_gen.gen_synth_sig(freq, Freq_dev, ...
    Duration, Profile, Traits, Seed, Fs);

disp(['Seed: ' char(Props.seed)]);


FRA_dev = test_gen.FRA_dummy_dev(Synth_time, Synth_signal);

figure('position', [562 434 560 420])
plot(Synth_time, Synth_signal)
grid on
grid minor
ylabel('signal, V')
xlabel('t, s')
title('Test signal')

%% Main part

%--------------------------------
Freq = freq;
Underrange_force = false;
Fig = figure('position', [564 433 560 420]);
Find_harms = true;
MAX_CH2_LIMIT = 5;
Time_to_underrange = 0.3; % [s]
Overrange_tolerance = 0; % [%]
%--------------------------------

%--------------------------------
Period = 1/Freq;
Time_settings = struct('max', 50*Period); % FIXME
Accuracy_settings = struct(...
    ...
    );
%--------------------------------


% Shared data -------------------------
T_arr = [];
V_arr = [];

% clearvars Estimations
Estimations = empty_estimation();
Estimations_extra = empty_estimation();
Estimations_low = empty_estimation();

Properties = struct(...
    'const_bg', 11, ...
    'linear_bg', 0, ...
    'const_phase', 0, ...
    'linear_phase', 0, ...
    'const_amp', 0, ...
    'linear_amp', 0);

Underrange = true;
stop = false;
Exit_flag = 0;
% -------------------------------------

clc
FRA_dev.run();
while ~stop
    pause(0.001); %FIXME: for fast signal
    [T_part, V_part] = FRA_dev.get_data_ch1();
%     [T_part, V_part, V2_part] = get_CV(obj);
    if isempty(T_part)
        stop = true;
    end
    T_arr = [T_arr T_part];
    V_arr = [V_arr V_part];

    if T_arr(1) ~= 0
        T_arr = T_arr - T_arr(1);
    end

    %--------------------------------
    Time_passed = T_arr(end);
    Periods_counter = Time_passed/Period;
    
    Overload_range = abs(V_arr) > MAX_CH2_LIMIT*0.999; % FIXME: magic constant
    Overload_count = numel(find(Overload_range));
    Overload_volume = Overload_count/numel(V_arr);
    if Overload_count > 0
        disp(['Overload: ' num2str(Overload_volume*100, '%0.2f') ' %'])
    end

    if Underrange
        [Mean, Span, Min, Max] = singal_stats(V_arr);
        if Underrange_force
            Underrange_level = 0.001*5; % FIXME: magic constant
        else
            Underrange_level = 0.0001*5; % FIXME: magic constant
        end
        Cond1 = abs(Mean) < Underrange_level;
        Cond2 = Span < Underrange_level;
        if ~Cond1 && ~Cond2
            Underrange = false;
        end
        if Underrange
            disp('Underrange') % FIXME: debug
        end
    end

    if Underrange && Time_passed > Time_to_underrange
        Exit_flag = 1; % NOTE: EF 1: underrange
        break;
    end

    if Time_passed > 0.3 && Overload_volume > Overrange_tolerance
        Exit_flag = 2; % NOTE: EF 2: overrange
        break;
    end

    if Time_passed > Time_settings.max
        Exit_flag = 3; % NOTE: EF 3: Timeout_max
        break;
    end

    if Periods_counter > 1.1
        % FIXME: ude this or Time_settings.max ?
    end

    % FIXME: do we need this?
    if no_estimations(Estimations) && Periods_counter > 1
        Init_values = do_initial_estimation(T_arr, V_arr, Period);
        Result = simple_sin_fit_f(T_arr, V_arr, ...
            Freq, Init_values);
        Estimations = Result;
    end

    switch signal_per_duration(Periods_counter)
        case "invalid" % 0 : 0.45
            % DO SOMETHING:
            % - noise analysis
            % pause(0.05*Period)

        case "get_lucky" % 0.45 : 0.5
            if no_estimations(Estimations_extra)
                Init_values = do_initial_estimation(T_arr, V_arr, Period);
                Result = simple_sin_fit_f(T_arr, V_arr, ...
                    Freq, Init_values);
                Estimations_extra = Result;
            else
                Result = simple_sin_fit_f(T_arr, V_arr, ...
                    Freq, Estimations_extra);
                Estimations_extra = [Estimations_extra Result];
            end

        case "min" % 0.5 : 1.0
            if no_estimations(Estimations_low)
                Init_values = do_initial_estimation(T_arr, V_arr, Period);
                Result = simple_sin_fit_f(T_arr, V_arr, ...
                    Freq, Init_values);
                Estimations_low = Result;
            else
                Result = simple_sin_fit_f(T_arr, V_arr, ...
                    Freq, Estimations_low);
                Estimations_low = [Estimations_low Result];
            end
            
        case "single" % 1.0 : 2
            % FIXME: we want to finish here !
            % FIXME: UNDONE (DEBUG VERSION)
%             [out_time, out_sig] = get_last_period(T_arr, V_arr, Period);
            Result = simple_sin_fit_f(T_arr, V_arr, ...
                Freq, Estimations);
            Estimations = [Estimations Result];

            BG_diff = Result.z;
            Amp_mean = Result.amp;
            Properties = update_props(Properties, Amp_mean, BG_diff);
            

        case "long" % 2 : 10
            % FIXME: UNDONE (DEBUG VERSION)
            [out_time1, out_sig1] = get_first_period(T_arr, V_arr, Period);
            Result1 = simple_sin_fit_f(out_time1, out_sig1, ...
                Freq, Estimations);
            
            Scale = Periods_counter/2; % FXIME: magic constant
            [out_time2, out_sig2] = get_last_period(T_arr, V_arr, Period, Scale);
            Result2 = simple_sin_fit_f(out_time2, out_sig2, ...
                Freq, Estimations);

%             Result = DFT_estimation(T_arr, V_arr, Period);
            Estimations = [Estimations Result2];

            BG_diff = Result2.bg - Result1.bg;
            Amp_mean = mean([Result2.amp Result1.amp]);
            Properties = update_props(Properties, Amp_mean, BG_diff);


        case "max" % 10 : inf
            % FIXME: UNDONE (DEBUG VERSION)
            Scale = 5; % FIXME: magic constant
            [out_time, out_sig] = get_last_period(T_arr, V_arr, Period, Scale);
%             Result = simple_sin_fit_f(out_time, out_sig, ...
%                 Freq, Estimations);
            Result = DFT_estimation(out_time, out_sig, Period);
            Estimations = [Estimations Result];

    end

    %--------------------------------

    if ~isempty(Fig)
        cla
        plot(T_arr, V_arr);
        title(['PC: ' num2str(Periods_counter, '%0.3f') ' '])
        drawnow
    end
end
FRA_dev.stop();

if Overload_count > 0
    Find_harms = false;
end

disp(['Exit_flag: ' num2str(Exit_flag)]);



%%
clc

if Periods_counter < 2
    Properties.const_amp = 11;
    Properties.const_bg = 0;
    Properties.const_phase = 11;
    Properties.linear_amp = 0;
    Properties.linear_bg = 11;
    Properties.linear_phase = 0;
end
Properties.linear_bg = 0;


Estimations = estimation_fix(Estimations, Periods_counter, freq);


if ~no_estimations(Estimations)
    disp('Start final fit:')
    
    % FIXME: experimental
    T_arr = T_arr(~Overload_range);
    V_arr = V_arr(~Overload_range);
    
    Start_time_fit = tic;

    [T_arr_fit, V_arr_fit, Fs_fit] = make_fs_lower(T_arr, V_arr, Fs, freq);
    
    % -FIXME: debug-
    Properties.const_bg = 0;
    Properties.linear_bg = 0;

    Properties.const_amp = 0;
    Properties.linear_amp = 11;

    Properties.const_phase = 0;
    Properties.linear_phase = 0;
    % --------------

    % NOTE: Harms estimation

    if Find_harms
        Harm_est = estimate_harmonics(freq, T_arr_fit, V_arr_fit, Fs_fit);
    else
        Harm_est = [];
    end


    % NOTE: fit with harmonics estimations
    [Result, Residuals] = any_sin_fit(T_arr_fit, V_arr_fit, Freq, ...
        Estimations, Properties, Harm_est);

    disp(['Time to fit: ' num2str(toc(Start_time_fit), '%0.2f') ' s'])
    
    disp([newline 'Finish'])
else
    disp('No estimations')
end


if Save_data_flag
    Savedata = struct( ...
        'time', T_arr, ...
        'ch1', V_arr, ...
        'ch2', [], ...
        'harm_est', Harm_est, ...
        'estimations', Estimations, ...
        'result', Result, ...
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

function Properties = update_props(Properties, Amp_mean, BG_diff)
    Value = abs(BG_diff/Amp_mean);
    % disp([num2str(BG_diff) '    ' num2str(Amp_mean)])
    % disp([num2str(Value*100, '%0.2f') ' %'])
    if Value > 0.2
        Properties.linear_bg = 0;
        Properties.const_bg = 0;
    end
    if Value < 0.2 && Value > 0.05
        Properties.linear_bg = Properties.linear_bg + 2;
        Properties.const_bg = 0;
    end
    if Value < 0.1
        Properties.linear_bg = Properties.linear_bg + 1;
        Properties.const_bg = Properties.const_bg + 1;
    end
    if Value < 0.001
        Properties.linear_bg = Properties.linear_bg - 1;
        Properties.const_bg = Properties.const_bg + 2;
    end
end


function Result = ... % do_initial_estimation
    do_initial_estimation(T_arr, V_arr, Period)

    [Mean, Span, ~, ~] = singal_stats(V_arr);
    
    Start_Phi = fit_helper.estimate_phi_part_sin(T_arr, V_arr, Period);
    if isempty(Start_Phi)
        Start_Phi = 0;
    end
    
    Result = fit_mimic(Span, Start_Phi, Mean);
end


function Result = fit_mimic(Start_Amp, Start_Phi, Start_BG)
    Result = struct(... % FIXME: magic constant at f_dev
        'amp', Start_Amp, 'phi', Start_Phi, 'bg', Start_BG, 'f_dev', 0, ...
        'a_err', NaN, 'p_err', NaN, 'c_err', NaN, 'fd_err', NaN, ...
        'fitres', NaN, ...
        't_min', NaN, 't_max', NaN, ...
        'z', NaN, ...
        'status', "mimic");
end


function Result = empty_estimation()
    Result = struct(... % FIXME: magic constant at f_dev
        'amp', NaN, 'phi', NaN, 'bg', NaN, 'f_dev', NaN, ...
        'a_err', NaN, 'p_err', NaN, 'c_err', NaN, 'fd_err', NaN, ...
        'fitres', NaN, ...
        't_min', NaN, 't_max', NaN, ...
        'z', NaN, ...
        'status', "empty");
end


function status = no_estimations(Estimations)
    if numel(Estimations) == 1 && Estimations(1).status == "empty"
        status = true;
    else
        status = false;
    end
end


function Result = combining_estimations(Estimations)
    N = numel(Estimations);
    % FIXME: UNDONE
    Result.amp = mean([Estimations.amp]);
    Result.bg = mean([Estimations.bg]);
    Result.phi = mean([Estimations.phi]);
    
end


function [out_time, out_sig] = get_last_period(Time, Signal, Period, Scale)
    % Scale = 1.3;
    if Scale > 2
        Scale = 2;
    end
    Length = Time(end) - Time(1);
    if Length <= Period*Scale
        out_time = Time;
        out_sig = Signal;
    else
        range = Time >= Time(end) - Period*Scale;
        out_time = Time(range);
        out_sig = Signal(range);
    end
end


function [out_time, out_sig] = get_first_period(Time, Signal, Period)
    Scale = 1.1;
    Length = Time(end) - Time(1);
    if Length <= Period*Scale
        out_time = Time;
        out_sig = Signal;
    else
        range = Time <= Time(1) + Period*Scale;
        out_time = Time(range);
        out_sig = Signal(range);
    end
end


function Result = ... % simple_sin_fit_f
    simple_sin_fit_f(Time, Signal, Freq, Estimations)
    
    Start_time = Time(1);
    End_time = Time(end);
    Mid_time = (End_time + Start_time)/2;
    
    if numel(Estimations) ~= 1
        Estimations = combining_estimations(Estimations);
    end
    Start_Amp = Estimations(1).amp;
    Start_Phi = Estimations(1).phi;
    Start_BG = Estimations(1).bg;
    
    Eq = [ 'A*sin(2*pi*' num2str(Freq) '*x+P/180*pi) + C + Z*x' ];
    
    ft = fittype(Eq, 'independent', 'x', 'dependent', 'y');
    opts = fitoptions('Method', 'NonlinearLeastSquares');
    opts.Display = 'Off';
    opts.TolX = 1e-6; % FIXME: default
    opts.TolFun = 1e-6; % default
    
    A = Start_Amp;
    P = Start_Phi;
    C = Start_BG;
    %                     A     C     P      Z
    opts.Lower      =  [   0   -5   -180   -inf ];
    opts.StartPoint =  [   A    C      P      0 ];
    opts.Upper      =  [  10   +5   +180   +inf ];
    
    [fitresult, gof] = fit(Time', Signal', ft, opts);
    
    % FIXME: do we need to check quality? (use gof somehow)
    
    A = fitresult.A;
    P = fitresult.P;
    C = fitresult.C;
    Z = fitresult.Z;

    C = C + Z*Mid_time;

    CI = confint(fitresult);
    CI = (CI(2, :) - CI(1, :))/2;
    
    A_err = CI(1);
    C_err = CI(2);
    P_err = CI(3);
    
    Result = struct(...
        'amp', A, 'phi', P, 'bg', C, 'f_dev', NaN, ...
        'a_err', A_err, 'p_err', P_err, 'c_err', C_err, 'fd_err', NaN, ...
        'fitres', fitresult, ...
        't_min', Start_time, 't_max', End_time, ...
        'z', Z, 'status', 'ok');

end


function Result = DFT_estimation(Time, Signal, Period)
    Start_time = Time(1);
    End_time = Time(end);
    Freq = 1/Period;

    [Amp_DFT, Phi_DFT, Mean] = DFT_single_freq(Time, Signal, Freq);

    Result = struct(...
        'amp', Amp_DFT, 'phi', Phi_DFT, 'bg', Mean, 'f_dev', NaN, ...
        'a_err', NaN, 'p_err', NaN, 'c_err', NaN, 'fd_err', NaN, ...
        'fitres', NaN, ...
        't_min', Start_time, 't_max', End_time, ...
        'z', 0, 'status', 'ok');
end


% Result = struct(...
%     'amp_poly', amp_poly_out, ...
%     'phi_poly', phi_poly_out, ...
%     'bg_poly', bg_poly_out, ...
%     'amp_poly_err', amp_poly_err, ...
%     'phi_poly_err', phi_poly_err, ...
%     'bg_poly_err', bg_poly_err, ...
%     'f_div_ppm', D, ...
%     'f_dev_ppm_err', D_err, ...
%     'fit_function', 'any_sin_fit', ...
%     'freq', Freq ...
%     );

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


function [Mean, Span, Min, Max] = singal_stats(Signal)
    Signal = medfilt1(Signal);
    
    Min = min(Signal);
    Max = max(Signal);
    Mean = mean(Signal);
    Span = abs(Max-Min);
end


function [amp_poly, phi_poly, bg_poly] = estimations_const_fit(Estimations, Period)
    Est_amp = [Estimations.amp];
    Est_phi = [Estimations.phi];
    Est_bg = [Estimations.bg];
    
    amp_poly.p1 = 0;
    amp_poly.p2 = 0;
    amp_poly.p3 = mean(Est_amp);
    
    phi_poly.p1 = 0;
    phi_poly.p2 = 0;
    phi_poly.p3 = mean(Est_phi);
    
    bg_poly.p1 = 0;
    bg_poly.p2 = 0;
    bg_poly.p3 = mean(Est_bg);
end


function Estimations = estimation_fix(Estimations, Periods_counter, freq)
    Period = 1/freq;
    % NOTE: delete early estimations
    Est_time_min = [Estimations.t_max];
    Est_time_max = [Estimations.t_max];
    if Periods_counter > 2
        range = Est_time_min < Period & Est_time_max < Period;
    else
        range = Est_time_max < Period*0.5;
    end
    Estimations(range) = [];
    
    % NOTE: Replce estimations (is none) by bad estimations
    if no_estimations(Estimations) && no_estimations(Estimations_low) && ...
            ~no_estimations(Estimations_extra)
        disp([newline '! YOLO FIT ! („• ֊ •„)' newline])
        Estimations = Estimations_extra;
    elseif no_estimations(Estimations) && ~no_estimations(Estimations_low)
        disp([newline '! FIT by bad estimations ! ⸜(｡˃ ᵕ ˂ )⸝♡' newline])
        Estimations = Estimations_low;
    else
        disp([newline '! OK, we have something ! (˶ᵔ ᵕ ᵔ˶) ‹𝟹' newline])
    end
end

%FIXME: UNDODE function
function [T_arr_fit, V_arr_fit, Fs_fit] = make_fs_lower(T_arr, V_arr, Fs, freq)
Period = 1/freq;
Time_length = T_arr(end) - T_arr(1);
Num = numel(T_arr);
if Num > 20e3
    
end

if numel(T_arr) > 200e3
    disp('Nyan!')
    T_arr_fit = interp1(1:numel(T_arr), T_arr, ...
        linspace(1, numel(T_arr), 200000));
    V_arr_fit = interp1(T_arr, V_arr, T_arr_fit);
    Fs_fit = 1/mean(diff(T_arr_fit));
else
    T_arr_fit = T_arr;
    V_arr_fit = V_arr;
    Fs_fit = Fs;
end

end


function Harm_est = estimate_harmonics(freq, T_arr, V_arr, Fs)
Harm_est = struct('n', [], 'amp', [], 'phi', []);
k = 0;

% FIXME: use full data or cut data for harm find?
[Noise_amp, nf_calc] = noise_amp_calc(freq, T_arr, V_arr, Fs);

for hn = 2:6
    [Amp_DFT, Phi_DFT] = DFT_single_freq(T_arr, V_arr, hn*freq);
    if Amp_DFT > nf_calc(hn*freq) % FIXME: magic constant
        k = k + 1;
        Harm_est(k).n = hn;
        Harm_est(k).amp = Amp_DFT;
        Harm_est(k).phi = Phi_DFT;
        disp('GOOD')
        disp(['noise  = ' num2str(nf_calc(hn*freq)) ' V'])
        disp(['Amp_H' num2str(hn) ' = ' num2str(Amp_DFT) ' V' ...
            '    ' newline ...
            'Phi_H' num2str(hn) ' = ' num2str(Phi_DFT) ' deg' newline])
    else
        disp('BAD')
        disp(['noise  = ' num2str(nf_calc(hn*freq)) ' V'])
        disp(['Amp_H' num2str(hn) ' = ' num2str(Amp_DFT) ' V' ...
            '    ' newline ...
            'Phi_H' num2str(hn) ' = ' num2str(Phi_DFT) ' deg' newline])
    end
end
if k == 0
    Harm_est = [];
end

end




