

addpath("Short_sig_period_calc\")

%%

clc

freq = 0.1;
Freq_dev = 0;
Duration = 21;
Profile = 'const';
% Traits = ["nobg", "zerophi", 'nonoise'];
Traits = ["", ""];
Seed = 'FKIFJA';
% LLGUHH (small signal)
% IOTSCV (Phase test)
% VHJLJS (O_O)
% HDNPYV
% QDQFFM

Fs = 10e3;
% Fs = 10e3/Duration;

[Synth_time, Synth_signal, Props] = gen_synth_sig(freq, Freq_dev, Duration, ...
    Profile, Traits, Seed, Fs);

disp(['Seed: ' char(Props.seed)]);

figure('position', [562 434 560 420])
plot(Synth_time, Synth_signal)

% y = 0.01*sin(2*pi*2*freq*Synth_time);
% FRA_dev = FRA_dummy_dev(Synth_time, Synth_signal+y);

FRA_dev = FRA_dummy_dev(Synth_time, Synth_signal);

%%

%--------------------------------
Freq = freq;
%--------------------------------
Period = 1/Freq;
%--------------------------------

%--------------------------------
Time_settings = struct(...
    'max', 5*Period, ...
    'fairly', 2*Period);
Accuracy_settings = struct(...
    );
%--------------------------------

clc

FRA_dev.run();

T_arr = [];
V_arr = [];

clearvars Estimations

figure
stop = false;
while ~stop
    [T_part, V_part] = FRA_dev.get_data_ch1();
    pause(0.001); %FIXME: for fast signal
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
    
    if Time_settings.max > Time_passed
        % FIXME: how to exit?
    end

    if Time_settings.fairly > Time_passed
        % FXIME: how to exit?
    end

    if Periods_counter > 1.1
%         stop = true;
    end

    % FIXME: use incoming estimations
    % FIXME: create preview with less points
    % FIXME: Check overrange
    % FIXME: Check underrange
    % FIXME: what if we miss some early parts
    % FIXME: phase around -180[deg] problem
    % FIXME: add harmonics detection

    if exist("Estimations", "var") ~= 1 && Periods_counter > 1
        Init_values = do_initial_estimation(T_arr, V_arr, Period);
        Result = simple_sin_fit_f(T_arr, V_arr, ...
            Freq, Init_values);
        Estimations = Result;
    end

    switch signal_per_duration(Periods_counter)
        case "invalid" % 0 : 0.5
            % DO SOMETHING

        case "min" % 0.5 : 1.2
            if exist("Estimations", "var") ~= 1
                Init_values = do_initial_estimation(T_arr, V_arr, Period);
                Result = simple_sin_fit_f(T_arr, V_arr, ...
                    Freq, Init_values);
                Estimations = Result;
            else
                Result = simple_sin_fit_f(T_arr, V_arr, ...
                    Freq, Estimations);
                Estimations = [Estimations Result];
            end
            
        case "single" % 1.2 : 2
            % FIXME: UNDONE (DEBUG VERSION)
%             [out_time, out_sig] = get_last_period(T_arr, V_arr, Period);
            Result = simple_sin_fit_f(T_arr, V_arr, ...
                Freq, Estimations);
            Estimations = [Estimations Result];

        case "long" % 2 : 10
            % FIXME: UNDONE (DEBUG VERSION)
            [out_time, out_sig] = get_last_period(T_arr, V_arr, Period);
            Result = simple_sin_fit_f(out_time, out_sig, ...
                Freq, Estimations);
            Estimations = [Estimations Result];

        case "max" % 10 : inf
            % FIXME: UNDONE (DEBUG VERSION)
            [out_time, out_sig] = get_last_period(T_arr, V_arr, Period);
            Result = simple_sin_fit_f(out_time, out_sig, ...
                Freq, Estimations);
            Estimations = [Estimations Result];

    end

    %--------------------------------

    cla
    plot(T_arr, V_arr);
    title(['PC: ' num2str(Periods_counter, '%0.3f') ' '])
    drawnow
%     pause(0.5)
end
FRA_dev.stop();

%
disp('Start final fit:')

tic
if numel(T_arr) > 200e3
    disp('Nyan!')
    T_arr_fit = interp1(1:numel(T_arr), T_arr, linspace(1, numel(T_arr), 200000));
    V_arr_fit = interp1(T_arr, V_arr, T_arr_fit);
else
    T_arr_fit = T_arr;
    V_arr_fit = V_arr;
end

% if Periods_counter < 2
%     disp('const fit')
%     Result = const_sin_fit_f(T_arr_fit, V_arr_fit, Freq, Estimations);
% elseif Periods_counter < 5
%     disp('line fit')
%     Result = line_sin_fit_f(T_arr_fit, V_arr_fit, Freq, Estimations);
% else
    disp('poly2 fit')
    Result = full_sin_fit_f(T_arr_fit, V_arr_fit, Freq, Estimations);
% end


disp(['Time to fit: ' num2str(toc, '%0.2f') ' s'])

disp('Finish')







%%

clc

hold on
for i = 1:numel(Estimations)
    
    A = Estimations(i).amp;
    P = Estimations(i).phi;
    C = Estimations(i).bg;
    fit_res = Estimations(i).fitres;
    
    disp(['A: ' num2str(A) ' P: ' num2str(P) ' C: ' num2str(C)])
xline(Estimations(i).t_min)
xline(Estimations(i).t_max)
end

disp('-----------------------')
disp(['A: ' num2str(Props.amp(1)) ...
      ' P: ' num2str(Props.phi(1)) ...
      ' C: ' num2str(Props.bg(1))])


ym = feval(fit_res, T_arr);

plot(Synth_time, Synth_signal, '-b')
plot(T_arr, ym, '-r', 'LineWidth', 2)

% xline(Estimations(end).t_min)
% xline(Estimations(end).t_max)


%%



function Result = ...
    do_initial_estimation(T_arr, V_arr, Period)

    [Mean, Span, ~, ~] = singal_stats(V_arr);
    
    Start_Phi = estimate_phi_part_sin(T_arr, V_arr, Period);
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
        't_min', NaN, 't_max', NaN);

end

function Result = combining_estimations(Estimations)
    N = numel(Estimations);
    % FIXME: UNDONE
    Result = Estimations(end);
end


function [out_time, out_sig] = get_last_period(Time, Signal, Period)
Scale = 1.3;
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


function Result = ...
    simple_sin_fit_f(Time, Signal, Freq, Estimations)
    
    Start_time = Time(1);
    End_time = Time(end);
    Mid_time = (End_time + Start_time)/2;
    
    % FIXME: do npt do it here (phase mismatch)
%     if Time(1) ~= 0
%         Time = Time - Time(1);
%     end
    
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
    
    % FIXME: check quality (use gof somehow)
    
    A = fitresult.A;
    P = fitresult.P;
    C = fitresult.C;
    Z = fitresult.Z;

    C = C + Z*Mid_time;
    
    % coeffnames(fitresult)
    CI = confint(fitresult);
    CI = (CI(2, :) - CI(1, :))/2;
    
    A_err = CI(1);
    C_err = CI(2);
    P_err = CI(3);
    
    Result = struct(...
        'amp', A, 'phi', P, 'bg', C, 'f_dev', NaN, ...
        'a_err', A_err, 'p_err', P_err, 'c_err', C_err, 'fd_err', NaN, ...
        'fitres', fitresult, ...
        't_min', Start_time, 't_max', End_time);

end


function state = signal_per_duration(Periods_counter)
    if Periods_counter > 0 && Periods_counter <= 0.5
        state = "invalid";
    end
    
    if Periods_counter > 0.5 && Periods_counter <= 1.2
        state = "min";
    end

    if Periods_counter > 1.2 && Periods_counter <= 2.0
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
    Span = Max-Min;
end



function [amp_poly, phi_poly, bg_poly] = estimations_poly2_fit(Estimations, Period)

Est_time = ([Estimations.t_max] + [Estimations.t_min])/2;
Est_amp = [Estimations.amp];
Est_phi = [Estimations.phi];
Est_bg = [Estimations.bg];

Est_time_norm = Est_time/Period;

amp_poly = fit(Est_time_norm', Est_amp', 'poly2');
phi_poly = fit(Est_time_norm', Est_phi', 'poly2');
bg_poly = fit(Est_time_norm', Est_bg', 'poly2');

end


function [amp_poly, phi_poly, bg_poly] = estimations_const_fit(Estimations, Period)

Est_amp = [Estimations.amp];
Est_phi = [Estimations.phi];
Est_bg = [Estimations.bg];

amp_poly.p1 = 0;
phi_poly.p1 = 0;
bg_poly.p1 = 0;
amp_poly.p2 = 0;
phi_poly.p2 = 0;
bg_poly.p2 = 0;

amp_poly.p3 = mean(Est_amp);
phi_poly.p3 = mean(Est_phi);
bg_poly.p3 = mean(Est_bg);


end


function Result = ...
    full_sin_fit_f(Time, Signal, Freq, Estimations)
    
F = Freq;
P = 1/F;

Eq = ['(a1*(x/' num2str(P) ')^2 + a2*(x/' num2str(P) ') + a3) * sin(' ...
      '2*pi*' num2str(F) '*(1+D/1e6)*x + ' ...
      '(p1*(x/' num2str(P) ')^2 + p2*(x/' num2str(P) ') + p3)/180*pi ' ...
      ' ) + c1*(x/' num2str(P) ')^2 + c2*(x/' num2str(P) ') + c3'];

ft = fittype(Eq, 'independent', 'x', 'dependent', 'y');
opts = fitoptions('Method', 'NonlinearLeastSquares');
opts.Display = 'Off';
opts.TolX = 1e-6; % FIXME: default
opts.TolFun = 1e-6; % default
opts.Display = 'Off';

[amp_poly, phi_poly, bg_poly] = estimations_poly2_fit(Estimations, P);

D = 0;
a1 = amp_poly.p1;
a2 = amp_poly.p2;
a3 = amp_poly.p3;
c1 = bg_poly.p1;
c2 = bg_poly.p1;
c3 = bg_poly.p1;
p1 = phi_poly.p1;
p2 = phi_poly.p2;
p3 = phi_poly.p3;

%                      D     a1    a2    a3    c1    c2    c3    p1    p2    p3
opts.Lower      = [ -300  -inf  -inf  -inf  -inf  -inf  -inf  -inf  -inf  -inf ];
opts.StartPoint = [    D    a1    a2    a3    c1    c2    c3    p1    p2    p3 ];
opts.Upper      = [ +300  +inf  +inf  +inf  +inf  +inf  +inf  +inf  +inf  +inf ];


[fitresult, gof] = fit(Time', Signal', ft, opts);
    
% FIXME: check quality (use gof somehow)
    
D = fitresult.D;
amp_poly_out.p1 = fitresult.a1;
amp_poly_out.p2 = fitresult.a2;
amp_poly_out.p3 = fitresult.a3;
bg_poly_out.p1 = fitresult.c1;
bg_poly_out.p2 = fitresult.c2;
bg_poly_out.p3 = fitresult.c3;
phi_poly_out.p1 = fitresult.p1;
phi_poly_out.p2 = fitresult.p2;
phi_poly_out.p3 = fitresult.p3;

Result = struct(...
    'amp_poly', amp_poly_out, ...
    'phi_poly', phi_poly_out, ...
    'bg_poly', bg_poly_out, ...
    'f_div_ppm', D);


%     A = fitresult.A;
%     P = fitresult.P;
%     C = fitresult.C;
    
%     % coeffnames(fitresult)
%     CI = confint(fitresult);
%     CI = (CI(2, :) - CI(1, :))/2;
%     
%     A_err = CI(1);
%     C_err = CI(2);
%     P_err = CI(3);
    
%     Result = struct(...
%         'amp', A, 'phi', P, 'bg', C, 'f_dev', NaN, ...
%         'a_err', A_err, 'p_err', P_err, 'c_err', C_err, 'fd_err', NaN, ...
%         'fitres', fitresult, ...
%         't_min', Start_time, 't_max', End_time);

end





function Result = ...
    line_sin_fit_f(Time, Signal, Freq, Estimations)
    
F = Freq;
P = 1/F;

Eq = ['(a2*(x/' num2str(P) ') + a3) * sin(' ...
      '2*pi*' num2str(F) '*(1+D/1e6)*x + ' ...
      '(p2*(x/' num2str(P) ') + p3)/180*pi ' ...
      ' ) + c2*(x/' num2str(P) ') + c3'];

ft = fittype(Eq, 'independent', 'x', 'dependent', 'y');
opts = fitoptions('Method', 'NonlinearLeastSquares');
opts.Display = 'Off';
opts.TolX = 1e-6; % FIXME: default
opts.TolFun = 1e-6; % default
opts.Display = 'Off';

[amp_poly, phi_poly, bg_poly] = estimations_poly2_fit(Estimations, P);

D = 0;

a2 = amp_poly.p2;
a3 = amp_poly.p3;

c2 = bg_poly.p1;
c3 = bg_poly.p1;

p2 = phi_poly.p2;
p3 = phi_poly.p3;

%                      D    a2    a3    c2    c3    p2    p3
opts.Lower      = [ -300  -inf  -inf  -inf  -inf  -inf  -inf ];
opts.StartPoint = [    D    a2    a3    c2    c3    p2    p3 ];
opts.Upper      = [ +300  +inf  +inf  +inf  +inf  +inf  +inf ];


[fitresult, gof] = fit(Time', Signal', ft, opts);
    
% FIXME: check quality (use gof somehow)
    
D = fitresult.D;
amp_poly_out.p1 = 0;
amp_poly_out.p2 = fitresult.a2;
amp_poly_out.p3 = fitresult.a3;
bg_poly_out.p1 = 0;
bg_poly_out.p2 = fitresult.c2;
bg_poly_out.p3 = fitresult.c3;
phi_poly_out.p1 = 0;
phi_poly_out.p2 = fitresult.p2;
phi_poly_out.p3 = fitresult.p3;

Result = struct(...
    'amp_poly', amp_poly_out, ...
    'phi_poly', phi_poly_out, ...
    'bg_poly', bg_poly_out, ...
    'f_div_ppm', D);

end


function Result = ...
    const_sin_fit_f(Time, Signal, Freq, Estimations)
    
F = Freq;
P = 1/F;

Eq = ['(a3) * sin(2*pi*' num2str(F) '*(1+D/1e6)*x + (p3)/180*pi  ) + c3'];

ft = fittype(Eq, 'independent', 'x', 'dependent', 'y');
opts = fitoptions('Method', 'NonlinearLeastSquares');
opts.Display = 'Off';
opts.TolX = 1e-6; % FIXME: default
opts.TolFun = 1e-6; % default
opts.Display = 'Off';

[amp_poly, phi_poly, bg_poly] = estimations_const_fit(Estimations, P);

D = 0;

a3 = amp_poly.p3;
c3 = bg_poly.p1;
p3 = phi_poly.p3;

%                      D    a3    c3    p3
opts.Lower      = [ -300  -inf  -inf  -inf ];
opts.StartPoint = [    D    a3    c3    p3 ];
opts.Upper      = [ +300  +inf  +inf  +inf ];


[fitresult, gof] = fit(Time', Signal', ft, opts);
    
% FIXME: check quality (use gof somehow)
    
D = fitresult.D;
amp_poly_out.p1 = 0;
amp_poly_out.p2 = 0;
amp_poly_out.p3 = fitresult.a3;
bg_poly_out.p1 = 0;
bg_poly_out.p2 = 0;
bg_poly_out.p3 = fitresult.c3;
phi_poly_out.p1 = 0;
phi_poly_out.p2 = 0;
phi_poly_out.p3 = fitresult.p3;

Result = struct(...
    'amp_poly', amp_poly_out, ...
    'phi_poly', phi_poly_out, ...
    'bg_poly', bg_poly_out, ...
    'f_div_ppm', D);

end