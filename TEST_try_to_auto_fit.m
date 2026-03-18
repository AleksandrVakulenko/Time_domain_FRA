% ------------------------------------------------------------------------------
%
%       ꧁⎝ 𓆩༺✧༻𓆪 ⎠꧂      ꧁⎝ 𓆩༺✧༻𓆪 ⎠꧂      ꧁⎝ 𓆩༺✧༻𓆪 ⎠꧂
%
%
% TODO:
% 1) finish make_fs_lower()
% 2) use Estimations for Properties
% 3) 
% 4) use FFT or DFT for 50 Hz rejection
% 5) add new data viewer
% 6) analize residuals more (for lost harms)
% 7) use incoming estimations
% 8) add condition for good harm measure (to use window)
% 9) [update sig_gen:] add underrange (span and mean) test signals
% 10) make Fern module
% 11) add errors must be 3*std
% 12) 
% 13) 
% 14) phase around -180[deg] problem
% 15) place fft functions to its own lib
% 16) DFT vs fft problem (calculating many DFTs) (where?)
% 17) Add non-realtime version of fit (just incoming estimations)
% 18) 
% 19) 
% ------------------------------------------------------------------------------
clc

Save_data_flag = false;
freq = 2;
Freq_dev = 0;
Duration = 10;
Fs = 10e3;
Profile_1 = 'weak';
Profile_2 = 'mid';
% Traits = ["nobg", "zerophi", 'nonoise', "lownoise", "constphi"];
Traits_1 = ["lownoise", "nobg", "lowharm"];
Traits_2 = ["", "", ""];
Seed = 'QRMFYA'; % QDNRSE

% LLGUHH (small signal)
% IOTSCV (Phase test)
% VHJLJS (O_O)
% HDNPYV
% QDQFFM
% CUSAIQ ???
% AQIOEZ overload test
% YYSRCS

[Synth_time, Synth_signal_1, Props_1, Noise_1] = test_gen.gen_synth_sig(freq, ...
    Freq_dev, Duration, Profile_1, Traits_1, Seed, Fs, 10);

Seed_2 = [char(Props_1.seed) 'A'];

[~, Synth_signal_2, Props_2, Noise_2] = test_gen.gen_synth_sig(freq, ...
    Freq_dev, Duration, Profile_2, Traits_2, Seed_2, Fs);

disp(['Seed: ' char(Props_1.seed)]);

Synth_signal_1 = test_gen.signal_digitizer(Synth_signal_1, 10, 18-1);
Synth_signal_2 = test_gen.signal_digitizer(Synth_signal_2, 6, 18-1);

FRA_dev = test_gen.FRA_dummy_dev(Synth_time, Synth_signal_1, Synth_signal_2);

test_gen.plot_test_signals(Synth_time, Synth_signal_1, Synth_signal_2);


%% Main part

%--------------------------------
Freq = freq;
Period = 1/Freq;
Underrange_force = false;
Fig = figure('position', [471 217 690 691]);
Find_harms = true;
MAX_CH1_LIMIT = 5;
MAX_CH2_LIMIT = 5;
Time_to_underrange = 0.1*Period; % [s]
Overrange_tolerance = 0; % [%]
%--------------------------------

%--------------------------------
Time_settings = struct('max', 1e6*Period); % FIXME
Accuracy_settings = struct(...
    ...
    );
%--------------------------------
if Time_to_underrange < 0.3
    Time_to_underrange = 0.3; % FIXME: magic constant
end
%--------------------------------


% Shared data -------------------------
T_arr = [];
V1_arr = [];
V2_arr = [];

% FIXME: need refactor
est_cell_arr_1 = {empty_estimation(), empty_estimation(), empty_estimation()};
est_cell_arr_2 = {empty_estimation(), empty_estimation(), empty_estimation()};

Properties_1 = struct(...
    'const_bg', 11, ...
    'linear_bg', 0, ...
    'const_phase', 0, ...
    'linear_phase', 0, ...
    'const_amp', 0, ...
    'linear_amp', 0);

Properties_2 = struct(...
    'const_bg', 11, ...
    'linear_bg', 0, ...
    'const_phase', 0, ...
    'linear_phase', 0, ...
    'const_amp', 0, ...
    'linear_amp', 0);

Underrange_1 = true;
Underrange_2 = true;

Overload_1 = struct('range', [], 'count', 0, 'volume', 0);
Overload_2 = struct('range', [], 'count', 0, 'volume', 0);
% -------------------------------------

% Common data -------------------------
stop = false;
Exit_flag = 0;
% -------------------------------------


clc
FRA_dev.run();
while ~stop
    pause(0.001); %FIXME: for fast signal
%     [T_part, V1_part] = FRA_dev.get_data_ch1();
    [T_part, V1_part, V2_part] = FRA_dev.get_CV();
    if isempty(T_part)
        stop = true;
    end
    T_arr = [T_arr T_part];
    V1_arr = [V1_arr V1_part];
    V2_arr = [V2_arr V2_part];

    Time_passed = T_arr(end);
    Periods_counter = Time_passed/Period;

    if T_arr(1) ~= 0
        T_arr = T_arr - T_arr(1);
    end

    %--------------------------------
    Overload_1.range = abs(V1_arr) > MAX_CH1_LIMIT*0.999; % FIXME: magic constant
    Overload_1.count = numel(find(Overload_1.range));
    Overload_1.volume = Overload_1.count/numel(V1_arr);
    
    Overload_2.range = abs(V2_arr) > MAX_CH2_LIMIT*0.999; % FIXME: magic constant
    Overload_2.count = numel(find(Overload_2.range));
    Overload_2.volume = Overload_2.count/numel(V2_arr);

    % FIXME: debug print
    if Overload_1.count > 0
        disp(['Overload Ch 1: ' num2str(Overload_1.volume*100, '%0.2f') ' %'])
    end
    if Overload_2.count > 0
        disp(['Overload Ch 2: ' num2str(Overload_2.volume*100, '%0.2f') ' %'])
    end

    Underrange_1 = check_underrange(V1_arr, Underrange_1, Underrange_force);
    Underrange_2 = check_underrange(V2_arr, Underrange_2, Underrange_force);

    if Underrange_1 && Time_passed > Time_to_underrange
        Exit_flag = 101; % NOTE: EF 101: underrange ch1
        break;
    end

    if Underrange_2 && Time_passed > Time_to_underrange
        Exit_flag = 102; % NOTE: EF 102: underrange ch2
        break;
    end

    if Time_passed > 0.3 && Overload_1.volume > Overrange_tolerance
        Exit_flag = 201; % NOTE: EF 201: overrange
        break;
    end

    if Time_passed > 0.3 && Overload_2.volume > Overrange_tolerance
        Exit_flag = 202; % NOTE: EF 202: overrange
        break;
    end

    if Time_passed > Time_settings.max
        Exit_flag = 30; % NOTE: EF 3: Timeout_max
        break;
    end

    if Periods_counter > 1.1
        % FIXME: ude this or Time_settings.max ?
    end

    % FIXME: refactor this function
    [est_cell_arr_1, Properties_1] = do_estimations(est_cell_arr_1, ...
        Properties_1, T_arr, V1_arr, Freq, Periods_counter);

    [est_cell_arr_2, Properties_2] = do_estimations(est_cell_arr_2, ...
        Properties_2, T_arr, V2_arr, Freq, Periods_counter);
    %--------------------------------

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
FRA_dev.stop();

if Exit_flag == 0 % FIXME: debug
        disp(['Exit_flag: ' num2str(Exit_flag)]);
else
    for i = 1:10
        disp(['Exit_flag: ' num2str(Exit_flag)]);
    end
end

if Find_harms
    Find_harms_1 = true;
    Find_harms_2 = true;
end

if Overload_1.count > 0
    Find_harms_1 = false;
end

if Overload_2.count > 0
    Find_harms_2 = false;
end

if Exit_flag == 0 && Overload_1.count > 0
    error('FIXME: undone function')
%     T_arr = T_arr(~Overload_1.range);
%     V1_arr = V1_arr(~Overload_1.range);
end


% FIXME: update (ADD SECOND CHANNEL)
Exit_status = struct('flag', Exit_flag, 'overload_1_count', Overload_1.count, ...
    'estimations_cell', est_cell_arr_1);

Estimations_1 = estimation_fix_wrapper(est_cell_arr_1, Periods_counter, freq);
Estimations_2 = estimation_fix_wrapper(est_cell_arr_2, Periods_counter, freq);

%
clc

% if Periods_counter < 2
%     Properties_1.const_amp = 11;
%     Properties_1.const_bg = 0;
%     Properties_1.const_phase = 11;
%     Properties_1.linear_amp = 0;
%     Properties_1.linear_bg = 11;
%     Properties_1.linear_phase = 0;
% end
% Properties_1.linear_bg = 0;

% -FIXME: debug-
Properties_1.const_bg = 0;
Properties_1.linear_bg = 0;

Properties_1.const_amp = 0;
Properties_1.linear_amp = 0;

Properties_1.const_phase = 0;
Properties_1.linear_phase = 0;
% --------------

% -FIXME: debug-
Properties_2.const_bg = 0;
Properties_2.linear_bg = 0;

Properties_2.const_amp = 0;
Properties_2.linear_amp = 0;

Properties_2.const_phase = 0;
Properties_2.linear_phase = 0;
% --------------


disp(['Start final fit:' newline])


disp('---- Channel 1: ----')
Time_start_1_fit = tic;
[Result_1, Residuals_1, DEBUG_1] = fit_channel(T_arr, V1_arr, Fs, freq, ...
    Estimations_1, Properties_1, Find_harms_1);
Time_ch1_fit = toc(Time_start_1_fit);

disp([newline '---- Channel 2: ----'])
Time_start_2_fit = tic;
[Result_2, Residuals_2, DEBUG_2] = fit_channel(T_arr, V2_arr, Fs, freq, ...
    Estimations_2, Properties_2, Find_harms_2);
Time_ch2_fit = toc(Time_start_2_fit);

disp(['--------------------'])

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

function [Result_1, Residuals_1, DEBUG_1] = fit_channel(T_arr, V1_arr, Fs, freq, ...
    Estimations_1, Properties_1, Find_harms_1)

if ~no_estimations(Estimations_1)

    [T_arr_fit, V_arr_fit, Fs_fit] = make_fs_lower(T_arr, V1_arr, Fs, freq);

    if Find_harms_1
        Harm_est_1 = estimate_harmonics(freq, T_arr_fit, V_arr_fit, Fs_fit);
    else
        Harm_est_1 = [];
    end

    % NOTE: fit with harmonics estimations
    [Result_1, Residuals_1, DEBUG_1] = any_sin_fit(T_arr_fit, V_arr_fit, freq, ...
        Estimations_1, Properties_1, Harm_est_1);
else
    Result_1 = [];
    Residuals_1 = [];
    DEBUG_1 = [];
end

end



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


% FIXME: unite "get_first_period" and "get_last_period"
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
        range = Time >= (Time(end) - Period*Scale);
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


%FIXME: unused - use or delete
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

function Estimations = estimation_fix_wrapper(est_cell_arr, Periods_counter, freq)
Estimations = est_cell_arr{1};
Estimations_low = est_cell_arr{2};
Estimations_extra = est_cell_arr{3};
Estimations = estimation_fix(Estimations, Estimations_low, ...
    Estimations_extra, Periods_counter, freq);
end

% FIXME: what if empty estimations?
function Estimations = estimation_fix(Estimations, Estimations_low, ...
    Estimations_extra, Periods_counter, freq)
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
[V_arr, F_lim] = apply_nuttall(V_arr, freq, Fs);
% FIXME: debug print
if ~isempty(F_lim)
    disp(['Nuttall window is used' newline]);
else
    disp(['noise calc without window' newline])
end

% FIXME: unused variable
[Noise_amp, nf_calc] = noise_amp_calc(freq, T_arr, V_arr, Fs, F_lim);

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



function [est_cell_arr, Properties] = do_estimations(est_cell_arr, ...
    Properties, T_arr, V_arr, Freq, Periods_counter)

Estimations = est_cell_arr{1};
Estimations_low = est_cell_arr{2};
Estimations_extra = est_cell_arr{3};
Period = 1/Freq;

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
%         disp(['Est te = ' num2str(Result.t_max) ' s']); % FIXME: delete
        Estimations = [Estimations Result];

end

est_cell_arr = {Estimations, Estimations_low, Estimations_extra};

end


function Underrange = check_underrange(V_arr, Underrange, Underrange_force)
if Underrange
    [Mean, Span, ~, ~] = singal_stats(V_arr);
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
end