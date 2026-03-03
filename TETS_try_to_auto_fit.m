

addpath("Short_sig_period_calc\")

%%

clc

freq = 1;
Freq_dev = 0;
Duration = 8;
Profile = 'mid';
% Traits = ["nobg", "zerophi"];
Traits = ["", ""];
Seed = 'OADSFF';

Fs = 10e3;
% Fs = 100e3/Duration;

[Synth_time, Synth_signal, Props] = gen_synth_sig(freq, Freq_dev, Duration, ...
    Profile, Traits, Seed, Fs);

disp(['Seed: ' char(Props.seed)]);

plot(Synth_time, Synth_signal)


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

est_num = 0;
Estimations = {};

stop = false;
while ~stop
    [T_part, V_part] = FRA_dev.get_data_ch1();
    if isempty(T_part)
        stop = true;
    end
    T_arr = [T_arr T_part];
    V_arr = [V_arr V_part];
    
    %--------------------------------
    Time_passed = T_arr(end);
    Periods_counter = Time_passed/Period;
    
    if Time_settings.max > Time_passed
        % FIXME: how to exit?
    end

    if Time_settings.fairly > Time_passed
        % FXIME: how to exit?
    end

    % FIXME: use incoming estimations
    % FIXME: create prview with less points
    % FIXME: Check overrange
    % FIXME: Check underrange

    switch signal_per_duration(Periods_counter)
        case "invalid" % 0 : 0.5
            continue
        case "min" % 0.5 : 1
            [Mean, Span, Min, Max] = singal_stats(V_arr);

            Start_Phi = estimate_phi_part_sin(T_arr, V_arr, Period);
            if isempty(Start_Phi)
                Start_Phi = 0;
            end

            if est_num == 0
                [A, P, C, fitresult, gof] = simple_sin_fit_f(T_arr, V_arr, ...
                    Freq, Span, Start_Phi, Mean);
                est_num = est_num + 1;
                Estimations{est_num} = struct('type', "init", 'amp', A, ...
                    'phi', P, 'bg', C, 'fitres', fitresult, ...
                    't_min', T_arr(1), 't_max', T_arr(end));
            else
                
            end
            
        case "single" % 1 : 2
            
        case "long" % 2 : 10
            
        case "max" % 10 : inf
            
    end

    
    
    
    %--------------------------------

    cla
    plot(T_arr, V_arr);
    title(['PC: ' num2str(Periods_counter, '%0.3f') ' '])
    drawnow
%     pause(0.5)
end
FRA_dev.stop();

disp('Finish')



%%

clc

hold on
for i = 1:numel(Estimations)

A = Estimations{i}.amp;
P = Estimations{i}.phi;
C = Estimations{i}.bg;
fit_res = Estimations{i}.fitres;

disp(['A: ' num2str(A) ' P: ' num2str(P) ' C: ' num2str(C)])


end
disp('-----------------------')
disp(['A: ' num2str(Props.amp(1)) ...
      ' P: ' num2str(Props.phi(1)) ...
      ' C: ' num2str(Props.bg(1))])


ym = feval(fit_res, T_arr);
plot(T_arr, ym)

xline(Estimations{1}.t_min)
xline(Estimations{1}.t_max)
%%





function [A, P, C, fitresult, gof] = ...
    simple_sin_fit_f(Time, Signal, Freq, Start_Amp, Start_Phi, Start_BG)

if Time(1) ~= 0
    Time = Time - Time(1);
end

Eq = [ 'A*sin(2*pi*' num2str(Freq) '*x+P/180*pi) + C' ];

ft = fittype(Eq, 'independent', 'x', 'dependent', 'y');
opts = fitoptions('Method', 'NonlinearLeastSquares');
opts.Display = 'Off';
opts.TolX = 1e-6; % default
opts.TolFun = 1e-6; % default

A = Start_Amp;
P = Start_Phi;
C = Start_BG;
%                     A     C     P
opts.Lower      =  [   0   -5   -180  ];
opts.StartPoint =  [   A    C      P  ];
opts.Upper      =  [  10   +5   +180  ];

[fitresult, gof] = fit(Time', Signal', ft, opts);

% FIXME: check quality

A = fitresult.A;
P = fitresult.P;
C = fitresult.C;

end


function state = signal_per_duration(Periods_counter)
    if Periods_counter > 0 && Periods_counter <= 0.5
        state = "invalid";
    end
    
    if Periods_counter > 0.5 && Periods_counter <= 1.0
        state = "min";
    end

    if Periods_counter > 1.0 && Periods_counter < 2.0
        state = "single";
    end

    if Periods_counter > 2.0 && Periods_counter < 10.0
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






